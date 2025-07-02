import os
import time
import pandas as pd
import numpy as np
from tqdm import tqdm
from shapely.geometry import Point
import geopandas as gpd
import folium
from folium.plugins import MarkerCluster

# Setup tqdm for pandas apply
tqdm.pandas()

# Timer start
start_time = time.perf_counter()

# Vectorized haversine (returns numpy array of distances)
def haversine_np(lat1, lon1, lat2, lon2):
    R = 3958.8  # miles
    lat1, lon1, lat2, lon2 = map(np.radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = np.sin(dlat / 2.0)**2 + np.cos(lat1) * np.cos(lat2) * np.sin(dlon / 2.0)**2
    return R * 2 * np.arctan2(np.sqrt(a), np.sqrt(1 - a))

# Load customer and zip data
customers = pd.read_csv('./data/input/foundation_texas_list_pull_053025.csv')
zip_locs = pd.read_csv('./data/zip_codes/uszips.csv')[['zip', 'lat', 'lng']]
customers = customers.merge(zip_locs, how='left', left_on='member_postal_code_addresses_adjusted', right_on='zip')
customers = customers.drop(columns=['zip'])
customers = customers.dropna(subset=['lat', 'lng']).copy()

# Define center locations
centers = {
    'Frisco': (33.1434, -96.839),
    'Dallas': (32.7791, -96.8003),
    'Fort_Worth': (32.7555, -97.3308)
}

# Vectorized distance calculation for all centers
for name, (center_lat, center_lon) in centers.items():
    customers[f'distance_from_{name}'] = haversine_np(
        customers['lat'].values, customers['lng'].values,
        center_lat, center_lon
    )
    customers[f'in_40mi_of_{name}'] = customers[f'distance_from_{name}'] <= 40

# Assign radius tag using tqdm
def assign_radius_tag(row):
    distances = {name: row[f'distance_from_{name}'] for name in centers}
    closest = min(distances, key=distances.get)
    return f"inside_{closest.lower()}" if distances[closest] <= 40 else "outside"

customers['radius_tag'] = customers.progress_apply(assign_radius_tag, axis=1)

# Output radius counts
for name in centers:
    count = customers[customers[f'in_40mi_of_{name}']].shape[0]
    print(f"🗺️ Customers within 40 miles of {name.replace('_', ' ')}: {count}")

# Save results
customers.to_csv('./data/output/customers_within_radius.csv', index=False)

# Check missing
print("Customers with missing lat/lon:", customers[customers[['lat', 'lng']].isna().any(axis=1)].shape[0])

# Save geojson
def save_geojson(df):
    gdf = gpd.GeoDataFrame(df, geometry=[Point(xy) for xy in zip(df['lng'], df['lat'])], crs="EPSG:4326")
    gdf[['id_profiles', 'membership_periods', 'radius_tag', 'geometry']].to_file("./data/output/maps/customer_map_no_clusters.geojson", driver="GeoJSON")

# Generate map
def plot_map_geojson(df, centers):
    fmap = folium.Map(location=[33.0, -97.0], zoom_start=8)

    for name, (lat, lon) in centers.items():
        folium.Marker([lat, lon], tooltip=name.replace('_', ' '), icon=folium.Icon(color='blue')).add_to(fmap)
        folium.Circle(
            radius=40 * 1609.34,
            location=(lat, lon),
            popup=f"{name.replace('_', ' ')} Radius",
            color='blue',
            fill=True,
            fill_opacity=0.1
        ).add_to(fmap)

    df['lat'] = df['lat'].round(5)
    df['lng'] = df['lng'].round(5)
    gdf = gpd.GeoDataFrame(df, geometry=[Point(xy) for xy in zip(df['lng'], df['lat'])], crs="EPSG:4326")

    def marker_color(row):
        return 'green' if row['radius_tag'].startswith('inside') else 'red'
    gdf['marker_color'] = df.progress_apply(marker_color, axis=1)

    def style_function(feature):
        return {
            'radius': 3,
            'color': feature['properties']['marker_color'],
            'fill': True,
            'fillOpacity': 0.7
        }

    folium.GeoJson(
        gdf[['geometry', 'id_profiles', 'membership_periods', 'radius_tag', 'marker_color']].to_json(),
        name="Customers",
        tooltip=folium.GeoJsonTooltip(fields=['id_profiles', 'membership_periods', 'radius_tag']),
        marker=folium.CircleMarker(),
        style_function=style_function
    ).add_to(fmap)

    fmap.save("./data/output/maps/customer_map_geojson.html")
    print("🗺️ Map saved to customer_map_geojson.html")

# Run
plot_map_geojson(customers, centers)
save_geojson(customers)

# Timer end
end_time = time.perf_counter()
print(f"\n✅ Finished in {end_time - start_time:.2f} seconds")
