import os
import time
import pandas as pd
import numpy as np
from tqdm import tqdm
from shapely.geometry import Point
import geopandas as gpd
import folium
from folium.plugins import MarkerCluster
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors

# Setup tqdm for pandas apply
tqdm.pandas()

# Timer start
start_time = time.perf_counter()

# Load customer and zip data
customers = pd.read_csv('./data/input/usa_list_pull_053025.csv')
zip_locs = pd.read_csv('./data/zip_codes/uszips.csv')[['zip', 'lat', 'lng']]
customers = customers.merge(zip_locs, how='left', left_on='member_postal_code_addresses_adjusted', right_on='zip')
customers = customers.drop(columns=['zip'])
customers = customers.dropna(subset=['lat', 'lng']).copy()

# Add state_flag
customers['state_flag'] = customers['member_state_code_addresses']

# Extract all unique end years from ends_year_mp column
all_end_years = sorted({
    int(y)
    for val in customers['ends_year_mp'].dropna().astype(str)
    for y in val.split(',') if y.strip().isdigit()
})

# Create binary columns for each ends_20xx year
for year in all_end_years:
    customers[f'ends_{year}'] = customers['ends_year_mp'].apply(
        lambda x: 1 if pd.notna(x) and str(year) in str(x).split(',') else 0
    )

# Assign region (adjust your logic as needed)
def assign_region(state):
    west = {'CA', 'OR', 'WA', 'NV', 'AZ'}
    south = {'TX', 'FL', 'GA', 'NC', 'AL'}
    midwest = {'IL', 'OH', 'MI', 'WI', 'IN'}
    northeast = {'NY', 'NJ', 'MA', 'PA', 'CT'}
    if state in west:
        return 'West'
    elif state in south:
        return 'South'
    elif state in midwest:
        return 'Midwest'
    elif state in northeast:
        return 'Northeast'
    return 'Other'

customers['region'] = customers['state_flag'].apply(assign_region)

# Generate color maps
unique_states = sorted(customers['state_flag'].dropna().unique())
unique_regions = sorted(customers['region'].dropna().unique())
end_cols = [col for col in customers.columns if col.startswith('ends_20')]

state_cmap = plt.get_cmap('tab20', len(unique_states))
region_cmap = plt.get_cmap('Set3', len(unique_regions))
end_cmap = plt.get_cmap('viridis', len(end_cols))

state_colors = {state: mcolors.to_hex(state_cmap(i)) for i, state in enumerate(unique_states)}
region_colors = {region: mcolors.to_hex(region_cmap(i)) for i, region in enumerate(unique_regions)}
end_colors = {col: mcolors.to_hex(end_cmap(i)) for i, col in enumerate(end_cols)}

# Add color columns based on mappings
customers['color_by_state'] = customers['state_flag'].map(state_colors)
customers['color_by_region'] = customers['region'].map(region_colors)
for col in end_cols:
    color = end_colors[col]
    # Color if ends_20xx == 1 else None (transparent)
    customers[f'color_by_{col}'] = customers[col].apply(lambda x: color if x == 1 else None)

# Save CSV with added color columns
customers.to_csv('./data/output/customers_with_colors.csv', index=False)

# Filter for valid lat/lng rows
print("Customers with missing lat/lon:", customers[customers[['lat', 'lng']].isna().any(axis=1)].shape[0])
clean_customers = customers.dropna(subset=['lat', 'lng'])

def save_geojson(df):
    print("📦 Preparing GeoJSON data...")
    geometry = [Point(xy) for xy in tqdm(zip(df['lng'], df['lat']), total=len(df), desc="Creating geometries")]
    gdf = gpd.GeoDataFrame(df.copy(), geometry=geometry, crs="EPSG:4326")

    color_cols = ['color_by_state', 'color_by_region'] + [f'color_by_{col}' for col in end_cols]
    columns_to_save = [
        'id_profiles', 'membership_periods', 'state_flag', 'region'
    ] + end_cols + color_cols + ['geometry']

    missing_cols = [c for c in columns_to_save if c not in gdf.columns]
    if missing_cols:
        raise ValueError(f"Missing columns for GeoJSON: {missing_cols}")

    print("💾 Saving GeoJSON...")
    gdf[columns_to_save].to_file(
        "./data/output/maps/customer_map_with_colors.geojson",
        driver="GeoJSON"
    )

def plot_map_geojson(df):
    print("🗺️ Building interactive map...")
    fmap = folium.Map(location=[39.8283, -98.5795], zoom_start=4)

    df['lat'] = df['lat'].round(5)
    df['lng'] = df['lng'].round(5)

    geometry = [Point(xy) for xy in tqdm(zip(df['lng'], df['lat']), total=len(df), desc="Creating geometries")]
    gdf = gpd.GeoDataFrame(df.copy(), geometry=geometry, crs="EPSG:4326")

    state_list = sorted(gdf['state_flag'].dropna().unique())
    region_list = sorted(gdf['region'].dropna().unique())
    end_cols = [col for col in gdf.columns if col.startswith('ends_20')]

    state_colors = {state: mcolors.to_hex(plt.cm.tab20(i % 20)) for i, state in enumerate(state_list)}
    region_colors = {region: mcolors.to_hex(plt.cm.Set3(i % 12)) for i, region in enumerate(region_list)}
    end_colors = {col: mcolors.to_hex(plt.cm.viridis(i / max(len(end_cols), 1))) for i, col in enumerate(end_cols)}

    def add_layer(color_type, color_map):
        layer = folium.FeatureGroup(name=f'Color: {color_type}', show=(color_type == "state_flag"))
        print(f"🧩 Adding markers for '{color_type}'...")
        for _, row in tqdm(gdf.iterrows(), total=len(gdf), desc=f"Layer: {color_type}"):
            color_key = row.get(color_type)
            if pd.isna(color_key):
                continue
            color = color_map.get(color_key, "gray")
            folium.CircleMarker(
                location=[row['lat'], row['lng']],
                radius=4,
                color=color,
                fill=True,
                fill_opacity=0.6,
                popup=folium.Popup(
                    f"ID: {row['id_profiles']}<br>"
                    f"State: {row['state_flag']}<br>"
                    f"Region: {row['region']}<br>"
                    f"{color_type}: {color_key}"
                ),
                tooltip=row['membership_periods']
            ).add_to(layer)
        layer.add_to(fmap)

    add_layer('state_flag', state_colors)
    add_layer('region', region_colors)

    for end_col in end_cols:
        color = end_colors[end_col]
        filtered = gdf[gdf[end_col] == 1]
        print(f"📍 Adding markers for '{end_col}'...")
        layer = folium.FeatureGroup(name=f'Color: {end_col}', show=False)
        for _, row in tqdm(filtered.iterrows(), total=len(filtered), desc=f"Layer: {end_col}"):
            folium.CircleMarker(
                location=[row['lat'], row['lng']],
                radius=4,
                color=color,
                fill=True,
                fill_opacity=0.6,
                popup=folium.Popup(
                    f"ID: {row['id_profiles']}<br>"
                    f"{end_col}=1<br>"
                    f"State: {row['state_flag']}<br>"
                    f"Region: {row['region']}"
                ),
                tooltip=row['membership_periods']
            ).add_to(layer)
        layer.add_to(fmap)

    folium.LayerControl(collapsed=False).add_to(fmap)
    fmap.save("./data/output/maps/customer_map_geojson.html")
    print("✅ Map saved to customer_map_geojson.html")

# Run
plot_map_geojson(clean_customers)
save_geojson(clean_customers)

# Timer end
end_time = time.perf_counter()
print(f"\n✅ Finished in {end_time - start_time:.2f} seconds")
