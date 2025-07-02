import os
import time
import pandas as pd
import numpy as np
import swifter
from tqdm import tqdm
from shapely.geometry import Point
import geopandas as gpd
import folium
from folium.plugins import MarkerCluster
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import multiprocessing

# --- Config ---
INPUT_CUSTOMERS_PATH = './data/input/usa_list_pull_053025_v3.csv'
INPUT_ZIPCODES_PATH = './data/zip_codes/uszips.csv'
OUTPUT_CUSTOMERS_CSV = './data/output/customers_with_colors.csv'
OUTPUT_GEOJSON = './data/output/maps/customer_map_with_colors.geojson'
OUTPUT_MAP_HTML = './data/output/maps/customer_map_geojson.html'
DEFAULT_MAP_CENTER = [39.8283, -98.5795]
DEFAULT_ZOOM_START = 4

def main():
    start_time = time.perf_counter()

    # --- Load Data ---
    customers = pd.read_csv(INPUT_CUSTOMERS_PATH)
    zip_locs = pd.read_csv(INPUT_ZIPCODES_PATH)[['zip', 'lat', 'lng']]
    customers = customers.merge(zip_locs, how='left',
                                left_on='member_postal_code_addresses_adjusted', right_on='zip')
    customers = customers.drop(columns=['zip']).dropna(subset=['lat', 'lng'])

    # --- State and Region ---
    customers['state_flag'] = customers['member_state_code_addresses']
    region_map = {
        'West': {'CA', 'OR', 'WA', 'NV', 'AZ'},
        'South': {'TX', 'FL', 'GA', 'NC', 'AL'},
        'Midwest': {'IL', 'OH', 'MI', 'WI', 'IN'},
        'Northeast': {'NY', 'NJ', 'MA', 'PA', 'CT'}
    }

    def assign_region(state):
        for region, states in region_map.items():
            if state in states:
                return region
        return 'Other'

    customers['region'] = customers['state_flag'].swifter.apply(assign_region)

    # --- Extract End Years <= 2023 & Create Columns ---
    all_end_years = sorted({
        int(y) for val in customers['ends_year_mp'].dropna().astype(str)
        for y in val.split(',') if y.strip().isdigit() and int(y) <= 2030
    })
    end_cols = [f'ends_{year}' for year in all_end_years]

    for year in all_end_years:
        col = f'ends_{year}'
        customers[col] = customers['ends_year_mp'].swifter.apply(
            lambda x: 1 if pd.notna(x) and str(year) in str(x).split(',') else 0
        )

    # --- Color Maps ---
    def generate_color_map(unique_items, cmap_name, max_colors=20):
        cmap = plt.get_cmap(cmap_name, min(len(unique_items), max_colors))
        return {item: mcolors.to_hex(cmap(i)) for i, item in enumerate(unique_items)}

    state_colors = generate_color_map(sorted(customers['state_flag'].dropna().unique()), 'tab20')
    region_colors = generate_color_map(sorted(customers['region'].dropna().unique()), 'Set3')
    end_colors = generate_color_map(end_cols, 'viridis', max_colors=256)

    # --- Assign Colors ---
    customers['color_by_state'] = customers['state_flag'].map(state_colors)
    customers['color_by_region'] = customers['region'].map(region_colors)

    # Bulk create end year color columns to avoid fragmentation and ambiguous truth errors
    new_color_cols = {}
    for col in end_cols:
        # Avoid swifter here to prevent ambiguous truth errors
        new_color_cols[f'color_by_{col}'] = customers[col].apply(lambda x: end_colors[col] if x == 1 else None)
    customers = pd.concat([customers, pd.DataFrame(new_color_cols, index=customers.index)], axis=1)

    # --- Export Colored CSV ---
    customers.to_csv(OUTPUT_CUSTOMERS_CSV, index=False)

    # --- Filter Non-Geo ---
    missing_geo_count = customers[['lat', 'lng']].isna().any(axis=1).sum()
    print(f"Customers with missing lat/lon: {missing_geo_count}")
    geo_customers = customers.dropna(subset=['lat', 'lng']).copy()

    # --- GeoJSON Export ---
    def save_geojson(df):
        print("📦 Preparing GeoJSON data...")
        geometry = [Point(xy) for xy in tqdm(zip(df['lng'], df['lat']), total=len(df), desc="Creating geometries")]
        gdf = gpd.GeoDataFrame(df.copy(), geometry=geometry, crs="EPSG:4326")

        color_cols = ['color_by_state', 'color_by_region'] + [f'color_by_{col}' for col in end_cols]
        required_cols = ['id_profiles', 'membership_periods', 'state_flag', 'region'] + end_cols + color_cols + ['geometry']

        missing = [col for col in required_cols if col not in gdf.columns]
        if missing:
            raise ValueError(f"Missing columns for GeoJSON export: {missing}")

        gdf[required_cols].to_file(OUTPUT_GEOJSON, driver="GeoJSON")
        print("✅ GeoJSON saved.")

    def save_geojson_in_chunks(df, chunk_size=50000):
        print("📦 Preparing GeoJSON data in chunks...")

        output_dir = os.path.dirname(OUTPUT_GEOJSON)
        os.makedirs(output_dir, exist_ok=True)
        temp_files = []

        color_cols = ['color_by_state', 'color_by_region'] + [f'color_by_{col}' for col in end_cols]
        required_cols = ['id_profiles', 'membership_periods', 'state_flag', 'region'] + end_cols + color_cols + ['geometry']

        for i in range(0, len(df), chunk_size):
            chunk = df.iloc[i:i + chunk_size].copy()
            print(f"Processing rows {i} to {i + len(chunk)}")

            geometry = [Point(xy) for xy in zip(chunk['lng'], chunk['lat'])]
            gdf = gpd.GeoDataFrame(chunk, geometry=geometry, crs="EPSG:4326")

            missing = [col for col in required_cols if col not in gdf.columns]
            if missing:
                raise ValueError(f"Missing columns in chunk {i // chunk_size + 1}: {missing}")

            temp_path = os.path.join(output_dir, f"temp_chunk_{i//chunk_size + 1}.geojson")
            gdf[required_cols].to_file(temp_path, driver="GeoJSON")
            temp_files.append(temp_path)

        # Optional: Merge all GeoJSON chunks into a single one
        print("🧩 Merging chunks...")
        merged = gpd.GeoDataFrame(pd.concat([
            gpd.read_file(temp_file) for temp_file in temp_files
        ], ignore_index=True), crs="EPSG:4326")

        merged.to_file(OUTPUT_GEOJSON, driver="GeoJSON")
        print(f"✅ Final GeoJSON saved: {OUTPUT_GEOJSON}")

        # Optional cleanup
        for temp_file in temp_files:
            os.remove(temp_file)

    import subprocess

    def generate_vector_tiles_from_geojson(geojson_path, mbtiles_output_path):
        """
        Converts a GeoJSON file to vector tiles (MBTiles) using tippecanoe.
        """
        print("🗂️ Converting GeoJSON to MBTiles with Tippecanoe...")

        try:
            subprocess.run([
                "tippecanoe",
                "-o", mbtiles_output_path,
                "-zg",  # Auto zoom
                "--drop-densest-as-needed",
                "--extend-zooms-if-still-dropping",
                "--read-parallel",
                geojson_path
            ], check=True)
            print(f"✅ MBTiles saved at: {mbtiles_output_path}")
        except subprocess.CalledProcessError as e:
            print(f"❌ Tippecanoe failed: {e}")


    # --- Interactive Map ---
    def plot_map_geojson(df):
        print("🗺️ Building interactive map...")
        fmap = folium.Map(location=DEFAULT_MAP_CENTER, zoom_start=DEFAULT_ZOOM_START)

        df['lat'] = df['lat'].round(5)
        df['lng'] = df['lng'].round(5)
        geometry = [Point(xy) for xy in zip(df['lng'], df['lat'])]
        gdf = gpd.GeoDataFrame(df.copy(), geometry=geometry, crs="EPSG:4326")

        def add_cluster_layer(gdf, color_key, color_map, name_prefix, show=True):
            print(f"🧩 Adding cluster: {name_prefix}")
            layer = folium.FeatureGroup(name=name_prefix, show=show)
            cluster = MarkerCluster().add_to(layer)
            for row in tqdm(gdf.itertuples(), total=len(gdf), desc=name_prefix):
                key = getattr(row, color_key)
                color = color_map.get(key, "gray")
                folium.CircleMarker(
                    location=[row.lat, row.lng],
                    radius=4,
                    color=color,
                    fill=True,
                    fill_opacity=0.6,
                    popup=folium.Popup(
                        f"ID: {row.id_profiles}<br>"
                        f"State: {row.state_flag}<br>"
                        f"Region: {row.region}<br>"
                        f"{color_key}: {key}"
                    ),
                    tooltip=row.membership_periods
                ).add_to(cluster)
            layer.add_to(fmap)

        # Add state and region layers
        add_cluster_layer(gdf, 'state_flag', state_colors, 'State', show=True)
        add_cluster_layer(gdf, 'region', region_colors, 'Region', show=False)

        # Add year-end overlays
        for col in end_cols:
            filtered = gdf[gdf[col] == 1]
            layer = folium.FeatureGroup(name=col, show=False)
            for row in tqdm(filtered.itertuples(), total=len(filtered), desc=col):
                folium.CircleMarker(
                    location=[row.lat, row.lng],
                    radius=4,
                    color=end_colors[col],
                    fill=True,
                    fill_opacity=0.6,
                    popup=folium.Popup(
                        f"ID: {row.id_profiles}<br>"
                        f"{col}=1<br>"
                        f"State: {row.state_flag}<br>"
                        f"Region: {row.region}"
                    ),
                    tooltip=row.membership_periods
                ).add_to(layer)
            layer.add_to(fmap)

        folium.LayerControl(collapsed=False).add_to(fmap)
        fmap.save(OUTPUT_MAP_HTML)
        print("✅ Map saved.")

    # --- Run processing functions ---
    # plot_map_geojson(geo_customers)
    # save_geojson(geo_customers)

    # CSV FILE AT 700k ROWS WAS TOO LARGE USED THE CHUNKS FUNCTION BELOW
    # save_geojson_in_chunks(geo_customers)
    mbtiles_path = os.path.join(OUTPUT_GEOJSON, "customer_map_with_colors.mbtiles")
    generate_vector_tiles_from_geojson(OUTPUT_GEOJSON, mbtiles_path)

    # --- Timer End ---
    print(f"\n✅ Finished in {time.perf_counter() - start_time:.2f} seconds")


if __name__ == "__main__":
    multiprocessing.freeze_support()
    main()
