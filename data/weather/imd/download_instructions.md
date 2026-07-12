# IMD Gridded Weather Data Download Instructions

To download the gridded daily temperature and precipitation datasets from the India Meteorological Department:

## Step 1: Access the IMD Data Portal
1. Navigate to the official IMD Pune Data Portal: [IMD Pune](https://www.imdpune.gov.in/) or [National Data Center (NDC)](https://ndc.imd.gov.in/).
2. Alternatively, check the Open Government Data Platform India: [data.gov.in](https://data.gov.in/).

## Step 2: Register/Sign In
1. If using the NDC portal, click on **Register** to create a user account.
2. Complete the registration form with your organization details (academic, research, or commercial).
3. Activate your account using the verification link sent to your email.

## Step 3: Request/Purchase Gridded Data
1. Log in to the NDC portal.
2. Go to the **Services / Data Request** section.
3. Select **Gridded Data** from the list of products:
   - *Daily Temperature (Max, Min, Mean)*: Available at 1° x 1° (1969-present) and 0.5° x 0.5° (1969-present) resolution.
   - *Daily Rainfall*: Available at 0.25° x 0.25° (1901-present) resolution.
4. Specify the spatial bounds (bounding box for India or target states) and temporal range (e.g., last 5 years).
5. Add the request to the cart and submit.

## Step 4: Payment and Retrieval
1. IMD gridded datasets are free for academic/research purposes (upon submitting an official request letter) but carry fee charges for commercial organizations.
2. Once the request is approved or payment is processed, you will receive an email containing a link to download the data in **binary (.GRD)** or **netCDF (.nc)** format.

## Step 5: Placement
Once downloaded, place the files inside the `data/weather/imd/` directory.
