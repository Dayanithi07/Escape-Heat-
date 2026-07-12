# NASA POWER Meteorology Dataset

## Source Name
NASA Prediction Of Worldwide Energy Resources (POWER) Daily Point API

## Official URL
https://power.larc.nasa.gov/

## License
Public Domain / Free to Use.
Attribution is requested: "These data were obtained from the NASA Langley Research Center POWER Project funded by the NASA Earth Science Directorate Applied Science Program."

## File Format
- `.json`: Raw daily API response.
- `.csv`: Daily meteorology features.

## Last Updated
Collected on 2026-07-06, contains daily parameters for May 2026.

## Description
This dataset contains daily meteorology and solar radiation data for the five target cities (Chennai, Bangalore, New Delhi, Gurgaon, and Hyderabad).

Variables collected:
- `T2M` (°C): Temperature at 2 meters (daily average).
- `T2M_MAX` (°C): Maximum temperature at 2 meters.
- `T2M_MIN` (°C): Minimum temperature at 2 meters.
- `RH2M` (%): Relative humidity at 2 meters.
- `ALLSKY_SFC_SW_DWN` (kW-hr/m²/day): All Sky Surface Shortwave Downward Irradiance (daily sum).

## Intended Usage
Used by the Heat Intelligence Engine to analyze baseline solar exposure, evaluate climatological solar loading on urban environments, and compute daily heat indexes.
