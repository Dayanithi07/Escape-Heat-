# OpenStreetMap Environmental Assets Dataset

## Source Name
OpenStreetMap (OSM) via Overpass API

## Official URL
https://www.openstreetmap.org/
Overpass API: https://overpass-turbo.eu/

## License
Open Database License (ODbL) 1.0.
Attribution required: "© OpenStreetMap contributors".

## File Format
- `.geojson`: Geospatial vector features containing geometries (Points, LineStrings, Polygons) and properties.
- `.csv`: Tabular extraction with name, ID, category tags, and representative coordinates (latitude, longitude).

## Last Updated
Collected on 2026-07-06.

## Description
This directory contains vector environmental layers extracted around Chennai, Bangalore, and New Delhi (5km radius around downtown centers):
- `hospitals.geojson` & `hospitals.csv`: Healthcare facilities (`amenity=hospital`), essential for hot spots emergency response.
- `parks.geojson` & `parks.csv`: Public parks and gardens (`leisure=park`), which act as urban cooling islands.
- `water_bodies.geojson` & `water_bodies.csv`: Lakes, rivers, reservoirs, and ponds (`natural=water`), providing cooling and relief.
- `tree_cover.geojson` & `tree_cover.csv`: Forest patches, woodlands, and garden greenery (`landuse=forest`, `natural=wood`, `leisure=garden`), showing natural canopy shade resources.

## Intended Usage
Used by the Interactive Heat Map component to overlay hospitals, cooling areas (parks/forests), and water bodies. This helps citizens find cooling centers and shelter during extreme heat events.
