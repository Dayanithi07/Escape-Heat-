# Open-Meteo Weather Dataset

## Source Name
Open-Meteo Historical Weather API

## Official URL
https://open-meteo.com/

## License
Creative Commons Attribution 4.0 International (CC BY 4.0)
Non-commercial use is free. Attribution is required.

## File Format
- `.json`: Full API responses (structured arrays of times and values).
- `.csv`: Flattened hourly weather data.

## Last Updated
Collected on 2026-07-06, contains observations for May 2026.

## Description
This dataset contains hourly and daily surface weather variables for the five target cities of Chennai, Bangalore, New Delhi, Gurgaon, and Hyderabad during a key summer month (May 2026). 

Variables collected:
- `temperature_2m` (°C): Air temperature at 2 meters above ground.
- `relative_humidity_2m` (%): Relative humidity at 2 meters.
- `apparent_temperature` (°C): Feels-like temperature combining temperature, humidity, and wind.
- `precipitation` (mm): Rain/drizzle.
- `wind_speed_10m` (km/h): Wind speed at 10 meters.
- `wind_direction_10m` (°): Wind direction at 10 meters.
- `shortwave_radiation` (W/m²): Global horizontal solar irradiance.
- `direct_normal_irradiance` (W/m²): Direct solar beam irradiance.
- `diffuse_radiation` (W/m²): Diffuse solar irradiance.

## Intended Usage
Used by the Heat Intelligence Engine to analyze historical weather patterns, calculate heat index timelines, and evaluate current weather conditions for the Heat Dashboard.
