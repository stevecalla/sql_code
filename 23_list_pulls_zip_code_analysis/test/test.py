import time
import os
import pandas as pd
from math import radians, sin, cos, sqrt, atan2

# TO GENERATE HTML MAP
import folium
from folium.plugins import MarkerCluster

# TO USE PYPPETEER
# python --version
# import asyncio
# from pyppeteer import launch

# FOR STATIC MAP 
# import geopandas as gpd
# import matplotlib.pyplot as plt
# from shapely.geometry import Point
# import contextily as ctx


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
customers = pd.read_csv('./data/input/foundation_texas_list_pull_053025.csv')

# Load ZIP geolocation data
# zip_locs = pd.read_csv('./data/input/sample_zip_to_lat_lon.csv')
zip_locs = pd.read_csv('./data/zip_codes/uszips.csv')

# Subset zip_locs to only include the desired columns
zip_locs_subset = zip_locs[['zip', 'lat', 'lng']]

# Merge ZIP lat/lng with customer ZIPs
# customers = customers.merge(zip_locs_subset, how='left', left_on='zip_code', right_on='zip')
customers = customers.merge(zip_locs_subset, how='left', left_on='member_postal_code_addresses_adjusted', right_on='zip')

# Optional: drop the redundant 'zip' column if not needed
customers = customers.drop(columns=['zip'])

# Define multiple center points
centers = {
    'Frisco': (33.1434, -96.839),
    'DFW': (32.8998, -97.0403),      # DFW Airport approx
    'Fort_Worth': (32.7555, -97.3308)  # Downtown Fort Worth
}

# Compute distances and in-range flags
for name, (center_lat, center_lon) in centers.items():
    customers[f'distance_from_{name}'] = customers.apply(
        lambda row: haversine(center_lat, center_lon, row['lat'], row['lng']), axis=1
    )
    customers[f'in_40mi_of_{name}'] = customers[f'distance_from_{name}'] <= 40

# Output filtered results
for name in centers:
    in_radius = customers[customers[f'in_40mi_of_{name}']]

    print(f"\n🗺️ Customers within 40 miles of {name.replace('_', ' ')}:")

    # print(in_radius[['customer_id', 'zip_code', f'distance_from_{name}']])
    print(in_radius[['id_profiles', 'member_postal_code_addresses_adjusted', f'distance_from_{name}']])

# Optional: Save to file
customers.to_csv('./data/output/customers_within_radius.csv', index=False)

# Filter out rows with missing lat/lng for mapping
print("Customers with missing lat/lon:", customers[customers[['lat', 'lng']].isna().any(axis=1)].shape[0])
clean_customers = customers.dropna(subset=['lat', 'lng'])

# Map output with folium
def plot_map(clean_customers, centers):
    # Start map centered around Frisco, TX
    fmap = folium.Map(location=[33.0, -97.0], zoom_start=8)

    # Add 40-mile radius circle and marker for each center
    for name, (lat, lng) in centers.items():
        folium.Marker([lat, lng], tooltip=name.replace('_', ' '), icon=folium.Icon(color='blue')).add_to(fmap)
        folium.Circle(
            radius=40 * 1609.34,  # Convert miles to meters
            location=(lat, lng),
            popup=f"{name.replace('_', ' ')} Radius",
            color='blue',
            fill=True,
            fill_opacity=0.1
        ).add_to(fmap)

    # Add clustered customer markers
    marker_cluster = MarkerCluster().add_to(fmap)

    for _, row in clean_customers.iterrows():
        folium.Marker(
            location=[row['lat'], row['lng']],
            tooltip=f"{row['id_profiles']} (#{row['membership_periods']})",
            icon=folium.Icon(
                color='green' if any(row[f'in_40mi_of_{c}'] for c in centers) else 'red'
            )
        ).add_to(marker_cluster)

    # Save or display the map
    fmap.save("./data/output/maps/customer_map.html")
    print("🗺️ Map saved as customer_map.html")

    # Example usage
    # html_file = "./data/output/maps/customer_map.html"
    # png_file = "./data/output/maps/customer_map_pyppeteer.png"

    # asyncio.get_event_loop().run_until_complete(save_html_as_png(html_file, png_file))
    # save_html_as_png("./data/output/maps/customer_map.html", "./data/output/maps/customer_map_pyppeteer.png")
    
    # Example usage
    # generate_static_map(clean_customers, output_file="./data/output/maps/static_customer_map.png")

# def generate_static_map(df, lat_col='lat', lon_col='lng', output_file='static_map.png'):

#     # Convert DataFrame to GeoDataFrame
#     geometry = [Point(xy) for xy in zip(df[lon_col], df[lat_col])]
#     gdf = gpd.GeoDataFrame(df, geometry=geometry, crs='EPSG:4326')

#     # Project to Web Mercator for basemap
#     gdf = gdf.to_crs(epsg=3857)

#     # Plot
#     ax = gdf.plot(figsize=(12, 10), alpha=0.6, edgecolor='k')
#     ctx.add_basemap(ax, source=ctx.providers.Stamen.TonerLite)
#     plt.axis('off')
#     plt.savefig(output_file, bbox_inches='tight', dpi=300)
#     print(f"✅ Static map saved to {output_file}")

# Call the mapping function
plot_map(clean_customers, centers)

# async def save_html_as_png(html_path, output_path):
#     # Ensure full file URI
#     html_file_url = f"file://{os.path.abspath(html_path)}"
    
#     browser = await launch(headless=True)
#     page = await browser.newPage()
    
#     # Optional: set viewport size
#     await page.setViewport({'width': 1280, 'height': 720})

#     # Load the HTML file
#     await page.goto(html_file_url, {'waitUntil': 'networkidle2'})
    
#     # Save screenshot
#     await page.screenshot({'path': output_path, 'fullPage': True})
    
#     await browser.close()
#     print(f"✅ Screenshot saved to {output_path}")
