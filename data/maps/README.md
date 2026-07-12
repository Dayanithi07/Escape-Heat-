# OpenStreetMap Base Map Layers

## Source Name
OpenStreetMap (OSM) via Overpass API

## Official URL
https://www.openstreetmap.org/

## License
Open Database License (ODbL) 1.0.
Attribution required: "© OpenStreetMap contributors".

## File Format
- `.geojson`: Geospatial vector features (Polygons, LineStrings, Relations).

## Last Updated
Collected on 2026-07-06.

## Description
This directory contains vector base map layers for building the interactive web maps:
- `roads.geojson`: Major road networks (highways, trunks, primary, secondary, and tertiary roads) within a 2km radius around central Chennai (T. Nagar) and New Delhi (Connaught Place).
- `buildings.geojson`: Building footprints (within a 500m radius around city centers) used to visualize dense urban surfaces that contribute to the Urban Heat Island effect.
- `boundaries.geojson`: Administrative city and district boundaries (`boundary=administrative` with `admin_level=6` or `admin_level=8`) within an 8km radius, displaying the limits of metropolitan city zones.

## Intended Usage
Used by the Frontend Map component (Leaflet / OpenStreetMap) to render basic vector layers, calculate spatial relationships, and display building densities for heat vulnerability index calculations.
