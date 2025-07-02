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
from shapely.geometry import Point

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

# Get unique end years
all_end_years = sorted({
    int(y)
    for val in customers['ends_year_mp'].dropna().astype(str)
    for y in val.split(',') if y.strip().isdigit()
})
for year in all_end_years:
    customers[f'ends_{year}'] = customers['ends_year_mp'].apply(
        lambda x: 1 if pd.notna(x) and str(year) in str(x).split(',') else 0
    )

# Assign region (placeholder logic, adjust as needed)
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

# Generate unique colors by state
unique_states = customers['state_flag'].dropna().unique()
color_map = plt.get_cmap('tab20', len(unique_states))  
state_colors = {state: mcolors.to_hex(color_map(i)) for i, state in enumerate(unique_states)}

# Assign marker color based on state, fallback to gender, then green
def marker_color(row):
    state = row.get('state_flag', '')
    if state in state_colors:
        return state_colors[state]
    if 'member_gender' in row and pd.notna(row['member_gender']):
        return 'blue' if row['member_gender'].lower().startswith('m') else 'pink'
    return 'green'

customers['marker_color'] = customers.progress_apply(marker_color, axis=1)

# Save CSV
customers.to_csv('./data/output/customers_within_radius.csv', index=False)

# Filter out rows with missing lat/lng for mapping
print("Customers with missing lat/lon:", customers[customers[['lat', 'lng']].isna().any(axis=1)].shape[0])
clean_customers = customers.dropna(subset=['lat', 'lng'])

def save_geojson(df):
    geometry = [Point(xy) for xy in zip(df['lng'], df['lat'])]
    gdf = gpd.GeoDataFrame(df.copy(), geometry=geometry, crs="EPSG:4326")
    
    # Ensure the dataframe is actually a GeoDataFrame
    assert isinstance(gdf, gpd.GeoDataFrame), "gdf is not a GeoDataFrame"

    # Check for missing column before saving
    required_columns = ['id_profiles', 'membership_periods', 'state_flag', 'marker_color', 'region']
    for col in required_columns:
        if col not in gdf.columns:
            raise ValueError(f"Missing required column: {col}")

    # Use the first available `ends_20xx` column instead of hardcoding ends_2020
    ends_cols = [col for col in gdf.columns if col.startswith('ends_20')]
    if not ends_cols:
        raise ValueError("No 'ends_20xx' column found in the data.")
    ends_col = ends_cols[0]

    # Save GeoJSON
    gdf[['id_profiles', 'membership_periods', ends_col, 'state_flag', 'marker_color', 'region', 'geometry']].to_file(
        "./data/output/maps/customer_map_no_clusters.geojson", driver="GeoJSON"
    )

# Generate map
# def plot_map_geojson(df):
#     fmap = folium.Map(location=[39.8283, -98.5795], zoom_start=4)

#     df['lat'] = df['lat'].round(5)
#     df['lng'] = df['lng'].round(5)

#     geometry = [Point(xy) for xy in zip(df['lng'], df['lat'])]
#     gdf = gpd.GeoDataFrame(df.copy(), geometry=geometry, crs="EPSG:4326")

#     def style_function(feature):
#         return {
#             'radius': 3,
#             'color': feature['properties']['marker_color'],
#             'fill': True,
#             'fillOpacity': 0.7
#         }

    # folium.GeoJson(
    #     gdf[['geometry', 'id_profiles', 'membership_periods', 'ends_2020', 'state_flag', 'marker_color', 'region']].to_json(),
    #     name="Customers",
    #     tooltip=folium.GeoJsonTooltip(fields=['id_profiles', 'membership_periods', 'ends_2020', 'state_flag', 'region']),
    #     marker=folium.CircleMarker(),
    #     style_function=style_function
    # ).add_to(fmap)

    # fmap.save("./data/output/maps/customer_map_geojson.html")
    # print("🗺️ Map saved to customer_map_geojson.html")


def plot_map_geojson(df):
    fmap = folium.Map(location=[39.8283, -98.5795], zoom_start=4)

    df['lat'] = df['lat'].round(5)
    df['lng'] = df['lng'].round(5)

    geometry = [Point(xy) for xy in zip(df['lng'], df['lat'])]
    gdf = gpd.GeoDataFrame(df.copy(), geometry=geometry, crs="EPSG:4326")

    # Define colormaps
    state_list = sorted(gdf['state_flag'].dropna().unique())
    region_list = sorted(gdf['region'].dropna().unique())
    end_cols = [col for col in gdf.columns if col.startswith('ends_20')]

    state_colors = {state: mcolors.to_hex(plt.cm.tab20(i % 20)) for i, state in enumerate(state_list)}
    region_colors = {region: mcolors.to_hex(plt.cm.Set3(i % 12)) for i, region in enumerate(region_list)}
    end_colors = {col: mcolors.to_hex(plt.cm.viridis(i / len(end_cols))) for i, col in enumerate(end_cols)}

    # Add layers for each view
    def add_layer(color_type, color_map):
        layer = folium.FeatureGroup(name=f'Color: {color_type}', show=(color_type == "state_flag"))
        for _, row in gdf.iterrows():
            color_key = row.get(color_type)
            if pd.isna(color_key): continue
            color = color_map.get(color_key, "gray")

            folium.CircleMarker(
                location=[row['lat'], row['lng']],
                radius=4,
                color=color,
                fill=True,
                fill_opacity=0.6,
                popup=folium.Popup(f"ID: {row['id_profiles']}<br>State: {row['state_flag']}<br>Region: {row['region']}"),
                tooltip=row['membership_periods']
            ).add_to(layer)
        layer.add_to(fmap)

    # Add state and region color layers
    add_layer('state_flag', state_colors)
    add_layer('region', region_colors)

    # Add layers for each ends_20xx column where value == 1
    for end_col in end_cols:
        color = end_colors[end_col]
        layer = folium.FeatureGroup(name=f'Color: {end_col}', show=False)
        filtered = gdf[gdf[end_col] == 1]
        for _, row in filtered.iterrows():
            folium.CircleMarker(
                location=[row['lat'], row['lng']],
                radius=4,
                color=color,
                fill=True,
                fill_opacity=0.6,
                popup=folium.Popup(f"ID: {row['id_profiles']}<br>{end_col}=1<br>State: {row['state_flag']}"),
                tooltip=row['membership_periods']
            ).add_to(layer)
        layer.add_to(fmap)

    folium.LayerControl(collapsed=False).add_to(fmap)
    fmap.save("./data/output/maps/customer_map_geojson.html")
    print("🗺️ Map saved to customer_map_geojson.html")

# Execute
plot_map_geojson(clean_customers)
save_geojson(clean_customers)

# Timer end
end_time = time.perf_counter()
print(f"\n✅ Finished in {end_time - start_time:.2f} seconds")
