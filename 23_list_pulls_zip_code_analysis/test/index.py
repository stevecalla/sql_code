import time
import os
import pandas as pd
from math import radians, sin, cos, sqrt, atan2

# Progress bar
from tqdm import tqdm
tqdm.pandas()

# TO GENERATE HTML MAP
import folium
from folium.plugins import MarkerCluster
import geopandas as gpd
from shapely.geometry import Point

# Haversine formula to calculate distance between two lat/lng pairs
def haversine(lat1, lon1, lat2, lon2):
    R = 3958.8  # Earth radius in miles
    dlat = radians(lat2 - lat1)
    dlon = radians(lon2 - lon1)
    a = sin(dlat / 2)**2 + cos(radians(lat1)) * cos(radians(lat2)) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c

# Load customer info
customers = pd.read_csv('./data/input/sample_customers.csv')

# Load ZIP geolocation data
# zip_locs = pd.read_csv('./data/input/sample_zip_to_lat_lon.csv')
zip_locs = pd.read_csv('./data/zip_codes/uszips.csv')

# Subset zip_locs to only include the desired columns
zip_locs_subset = zip_locs[['zip', 'lat', 'lng']]

# Merge ZIP lat/lng with customer ZIPs
customers = customers.merge(zip_locs_subset, how='left', left_on='zip_code', right_on='zip')

# Optional: drop the redundant 'zip' column if not needed
customers = customers.drop(columns=['zip'])

# Define multiple center points
centers = {
    'Frisco': (33.1434, -96.839),
    # 'DFW': (32.8998, -97.0403),       # DFW Airport approx
    'Dallas': (32.7791, -96.8003),      # Dallas Downtown
    'Fort_Worth': (32.7555, -97.3308)   # Downtown Fort Worth
}

# Compute distances and in-range flags
for name, (center_lat, center_lon) in centers.items():
    customers[f'distance_from_{name}'] = customers.apply(
        lambda row: haversine(center_lat, center_lon, row['lat'], row['lng']), axis=1
    )
    customers[f'in_40mi_of_{name}'] = customers[f'distance_from_{name}'] <= 40

# Assign radius tag using tqdm
def assign_radius_tag(row):
    distances = {name: row[f'distance_from_{name}'] for name in centers}
    closest = min(distances, key=distances.get)
    return f"inside_{closest.lower()}" if distances[closest] <= 40 else "outside"

customers['radius_tag'] = customers.progress_apply(assign_radius_tag, axis=1)

# Output filtered results
for name in centers:
    in_radius = customers[customers[f'in_40mi_of_{name}']]
    print(f"\n🗺️ Customers within 40 miles of {name.replace('_', ' ')}:")
    # print(in_radius[['customer_id', 'zip_code', f'distance_from_{name}']])
    print(in_radius[['customer_id', 'zip_code', f'distance_from_{name}']])

# Optional: Save to file
customers.to_csv('./data/output/customers_within_radius.csv', index=False)

# Filter out rows with missing lat/lng for mapping
print("Customers with missing lat/lon:", customers[customers[['lat', 'lng']].isna().any(axis=1)].shape[0])
clean_customers = customers.dropna(subset=['lat', 'lng'])

def save_geojson(clean_customers):
    gdf = gpd.GeoDataFrame(
        clean_customers,
        geometry=[Point(xy) for xy in zip(clean_customers['lng'], clean_customers['lat'])],
        crs="EPSG:4326"
    )
    gdf[['customer_id', 'radius_tag', 'geometry']].to_file("./data/output/maps/customer_map_no_clusters.geojson", driver="GeoJSON")

def plot_map_geojson(clean_customers, centers):
    # Create base map
    fmap = folium.Map(location=[33.0, -97.0], zoom_start=8)

    # Add center markers and radius circles
    for name, (lat, lng) in centers.items():
        folium.Marker(
            [lat, lng],
            tooltip=name.replace('_', ' '),
            icon=folium.Icon(color='blue')
        ).add_to(fmap)

        folium.Circle(
            radius=40 * 1609.34,
            location=(lat, lng),
            popup=f"{name.replace('_', ' ')} Radius",
            color='blue',
            fill=True,
            fill_opacity=0.1
        ).add_to(fmap)

    # Round lat/lng to reduce file size a bit
    clean_customers['lat'] = clean_customers['lat'].round(5)
    clean_customers['lng'] = clean_customers['lng'].round(5)

    # Create geometry column
    gdf = gpd.GeoDataFrame(
        clean_customers,
        geometry=[Point(xy) for xy in zip(clean_customers['lng'], clean_customers['lat'])],
        crs="EPSG:4326"
    )

    # Define color based on proximity (pre-calculate for efficiency)
    def marker_color(row):
        return 'green' if row['radius_tag'].startswith('inside') else 'red'

    gdf['marker_color'] = clean_customers.apply(marker_color, axis=1)

    # Create a simplified GeoJSON with styling
    def style_function(feature):
        return {
            'radius': 3,
            'color': feature['properties']['marker_color'],
            'fill': True,
            'fillOpacity': 0.7
        }

    folium.GeoJson(
        gdf[['geometry', 'customer_id', 'radius_tag', 'marker_color']].to_json(),
        name="Customers",
        tooltip=folium.GeoJsonTooltip(fields=['customer_id', 'radius_tag']),
        marker=folium.CircleMarker(),
        style_function=style_function
    ).add_to(fmap)

    # Save optimized map
    fmap.save("./data/output/maps/customer_map_geojson.html")
    print("🗺️ Optimized map saved as customer_map_geojson.html")

# Call the mapping function
plot_map_geojson(clean_customers, centers)
save_geojson(clean_customers)