# Satellite Land Surface Temperature (LST) Download Instructions

To download Land Surface Temperature datasets for Escape Heat:

---

## Option A: USGS EarthExplorer (Landsat 8/9 LST - 30m resolution)

### Step 1: Access USGS EarthExplorer
1. Go to the [USGS EarthExplorer Portal](https://earthexplorer.usgs.gov/).
2. Create a free **EROS Registration System (ERS)** account or log in if you already have one.

### Step 2: Set Search Criteria
1. Under **Address/Place**, enter your target city (e.g., `Chennai, India`) and click **Show**.
2. Select the location marker to set coordinates.
3. Under **Date Range**, specify summer months (e.g., `May 1, 2026` to `June 30, 2026`).

### Step 3: Select Data Set
1. Expand **Landsat** → **Landsat Collection 2 Level-2 (Science Products)**.
2. Check the box for **Landsat 8-9 OLI/TIRS C2 L2** (this includes pre-calculated Land Surface Temperature bands).

### Step 4: Add Filter & Search
1. Go to **Additional Criteria** and set **Land Cloud Cover** to **Less than 10%** to avoid clouds.
2. Click **Results** at the bottom.

### Step 5: Download LST
1. Find a clear image, click the **Download Options** icon.
2. Select **Product Options** → Download the **ST_B10** (Surface Temperature Band 10) file in GeoTIFF format.
3. Rename the file to `<city>_landsat_lst.tif` and place it in the `data/satellite/` directory.

---

## Option B: ISRO Bhuvan (Bhuvan LST - Regional)

### Step 1: Access Bhuvan
1. Go to the [ISRO Bhuvan Portal](https://bhuvan.nrsc.gov.in/).
2. Navigate to **Open Data Archive** → **Bhuvan Thematic Services** or **Bhuvan Land Archive**.
3. Register or sign in.

### Step 2: Select Data Product
1. Select the category **Land Surface Temperature (LST)**.
2. Choose the sensor (e.g., AWiFS or INSAT-3D/3DR for high temporal resolution).

### Step 3: Choose Area & Download
1. Select by **Bounding Box**, **Map Sheet**, or **Administrative Boundary**.
2. Select the date and click **Download** to obtain the TIFF files. Place these files in `data/satellite/`.

---

## Option C: Copernicus Data Space Ecosystem (Sentinel-3 SLSTR LST - 1km resolution)

### Step 1: Open Copernicus Browser
1. Go to the [Copernicus Data Space Browser](https://dataspace.copernicus.eu/browser/).
2. Log in (free registration required).

### Step 2: Filter by Dataset
1. Set the search area to your target city coordinates.
2. Under **Search**, select **Sentinel-3** → **SLSTR** sensor.
3. Choose the **LST (Land Surface Temperature)** product.
4. Set cloud filter to `< 10%`.

### Step 3: Download
1. Select a scene, click **Download Product**.
2. Extract the archive and copy the LST measurement files to the `data/satellite/` directory.
