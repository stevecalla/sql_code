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
import matplotlib.colors as mcolors  # Needed to convert colormap to hex

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

# Get unique end years across dataset
all_end_years = sorted({
    int(y)
    for val in customers['ends_year_mp'].dropna().astype(str)
    for y in val.split(',') if y.strip().isdigit()
})

# Add a column for each year
for year in all_end_years:
    customers[f'ends_{year}'] = customers['ends_year_mp'].apply(
        lambda x: 1 if pd.notna(x) and str(year) in str(x).split(',') else 0
    )
  
customers['state_flag'] = customers['member_state_code_addresses']

# Save results
customers.to_csv('./data/output/customers_within_radius.csv', index=False)

# Check missing
print("Customers with missing lat/lon:", customers[customers[['lat', 'lng']].isna().any(axis=1)].shape[0])
clean_customers = customers.dropna(subset=['lat', 'lng'])

# Save geojson
# def save_geojson(df):
    # gdf = gpd.GeoDataFrame(df, geometry=[Point(xy) for xy in zip(df['lng'], df['lat'])], crs="EPSG:4326")
    # gdf[['id_profiles', 'membership_periods', 'geometry']].to_file("./data/output/maps/customer_map_no_clusters.geojson", driver="GeoJSON")

def save_geojson(df):
    gdf = gpd.GeoDataFrame(df, geometry=[Point(xy) for xy in zip(df['lng'], df['lat'])], crs="EPSG:4326")
    gdf[['id_profiles', 'membership_periods', 'ends_2020', 'state_flag', 'geometry']].to_file(
        "./data/output/maps/customer_map_no_clusters.geojson", driver="GeoJSON"
    )

# Generate map
def plot_map_geojson(df):
    fmap = folium.Map(location=[39.8283, -98.5795], zoom_start=4)  # Centered on continental USA

    df['lat'] = df['lat'].round(5)
    df['lng'] = df['lng'].round(5)
    gdf = gpd.GeoDataFrame(df, geometry=[Point(xy) for xy in zip(df['lng'], df['lat'])], crs="EPSG:4326")

    def style_function(feature):
        return {
            'radius': 3,
            'color': feature['properties']['marker_color'],
            'fill': True,
            'fillOpacity': 0.7
        }

    folium.GeoJson(
        gdf[['geometry', 'id_profiles', 'membership_periods', 'ends_2020', 'state_flag', 'marker_color']].to_json(),
        name="Customers",
        tooltip=folium.GeoJsonTooltip(fields=['id_profiles', 'membership_periods', 'ends_2025', 'state_flag']),
        marker=folium.CircleMarker(),
        style_function=style_function
    ).add_to(fmap)

    fmap.save("./data/output/maps/customer_map_geojson.html")
    print("🗺️ Map saved to customer_map_geojson.html")

# Call the mapping function
plot_map_geojson(clean_customers)
save_geojson(clean_customers)

# Timer end
end_time = time.perf_counter()
print(f"\n✅ Finished in {end_time - start_time:.2f} seconds")

# Call the mapping function
plot_map_geojson(clean_customers)
save_geojson(clean_customers)

