# Recommendation Rules Dataset

## Source Name
Escape Heat Expert Panel (Compiled from WHO, Indian National Disaster Management Authority (NDMA), and NOAA guidelines).

## License
Creative Commons Zero (CC0 1.0 Universal) - Public Domain Dedication.
This data is free to copy, modify, distribute, and perform.

## File Format
- `.json`: Rule lookup files mapping weather indices to specific recommendations.

## Last Updated
Authoritative version updated on 2026-07-06.

## Description
This directory contains deterministic rule-based files used to generate advice and risk assessments without relying on AI hallucinations:
- `hydration.json`: Hourly water intake guidelines (in liters) mapped by temperature ranges, activity levels, and vulnerable demographic groups.
- `clothing.json`: Recommended fabrics (breathability/sweat absorption), color choices (albedo effects), and protective gear specifications.
- `activity.json`: Safety protocols for outdoor exercise and heavy labor, acclimatization plans for workers, and first-aid measures for heat exhaustion and heat stroke.
- `risk_levels.json`: Definitions of Heat Index risk levels (Low, Moderate, High, Extreme) and Wet Bulb Globe Temperature (WBGT) work-rest thresholds.

## Intended Usage
Used by the Recommendation Engine and the FastAPI Backend to fetch and display deterministic advice. The Escape AI Assistant also references these files as ground-truth context to answer natural language user prompts (e.g. "Can I jog now?").
