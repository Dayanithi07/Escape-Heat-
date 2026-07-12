# Escape Heat — Data Status Report

This file is a dynamically generated report listing all successfully collected datasets and identifying items that require manual download.

## ✅ Successfully Collected

| Dataset Name | Category | Source | License | Format | Local Path |
| --- | --- | --- | --- | --- | --- |
| Open-Meteo Historical Weather | Weather | Open-Meteo Archive API | CC BY 4.0 | JSON, CSV | [`data/weather/open-meteo`](data/weather/open-meteo) |
| NASA POWER Daily Point Meteorology | Weather | NASA POWER API | Public Domain | JSON, CSV | [`data/weather/nasa-power`](data/weather/nasa-power) |
| OSM Hospitals & Health Clinics | Environmental | OpenStreetMap via Overpass API | ODbL 1.0 | GeoJSON, CSV | [`data/environment`](data/environment) |
| OSM Parks & Green Spaces | Environmental | OpenStreetMap via Overpass API | ODbL 1.0 | GeoJSON, CSV | [`data/environment`](data/environment) |
| OSM Water Bodies | Environmental | OpenStreetMap via Overpass API | ODbL 1.0 | GeoJSON, CSV | [`data/environment`](data/environment) |
| OSM Tree Cover / Forest Greenery | Environmental | OpenStreetMap via Overpass API | ODbL 1.0 | GeoJSON, CSV | [`data/environment`](data/environment) |
| OSM Major Roads Network | Maps | OpenStreetMap via Overpass API | ODbL 1.0 | GeoJSON | [`data/maps`](data/maps) |
| OSM Building Footprints | Maps | OpenStreetMap via Overpass API | ODbL 1.0 | GeoJSON | [`data/maps`](data/maps) |
| OSM Administrative Boundaries | Maps | OpenStreetMap via Overpass API | ODbL 1.0 | GeoJSON | [`data/maps`](data/maps) |
| Hydration Guidance Rules | Recommendations | NDMA / WHO / NOAA Public Health Guidelines | CC0 1.0 (Public Domain) | JSON | [`data/recommendations/hydration.json`](data/recommendations/hydration.json) |
| Clothing Recommendations | Recommendations | NDMA / WHO / NOAA Public Health Guidelines | CC0 1.0 (Public Domain) | JSON | [`data/recommendations/clothing.json`](data/recommendations/clothing.json) |
| Activity Safety Protocols | Recommendations | NDMA / WHO / NOAA Public Health Guidelines | CC0 1.0 (Public Domain) | JSON | [`data/recommendations/activity.json`](data/recommendations/activity.json) |
| Heat Index Risk Levels | Recommendations | NDMA / WHO / NOAA Public Health Guidelines | CC0 1.0 (Public Domain) | JSON | [`data/recommendations/risk_levels.json`](data/recommendations/risk_levels.json) |

## ❌ Manual Download Required

The following datasets require manual retrieval due to registration walls, payment requirements, or high-resolution spatial queries. Detailed retrieval guides are included in the corresponding `download_instructions.md` files.

| Dataset Name | Category | Source | Official Download URL | Reason | Expected Location |
| --- | --- | --- | --- | --- | --- |
| IMD Open Gridded Datasets | Weather | India Meteorological Department (IMD) | [https://mausam.imd.gov.in/](https://mausam.imd.gov.in/) | Requires user registration, institutional verification, or fee payment. | `data/weather/imd` |
| Land Surface Temperature (LST) | Satellite | NASA EarthData / ISRO Bhuvan / Copernicus | [https://earthdata.nasa.gov/](https://earthdata.nasa.gov/) | Requires high-volume raster searches, user accounts, and spatial bounding box selection. | `data/satellite` |
