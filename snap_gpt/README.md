# Set of SNAP gpt graphs

These are equivalent of ALUs calibration and coherence routine pipelines.

Simply call `gpt graph.xml -P<parameter>=<value> ...`

**Calibration routine graph**:
* Sentinel-1 SLC split
* Thermal noise removal
* Calibration
* Deburst
* Merge - optional when multiple subswaths selected
* Range doppler terrain correction

**Coherence estimation routine graph**:
* 2 x input SLC coregistration(split + apply orbit file + backgeocoding)
* Coherence estimation
* Deburst
* Merge (when multiple subswaths selected)
* Range doppler terrain correction  

For DEM values, use ALUs supported ones, although SNAP supports many more:
* "Copernicus 30m Global DEM"
* "SRTM 3Sec"

## calibration_1sw_bindex.xml

Single subswath calibration.

Parameters:
* `input` - SAFE.zip or .SAFE/manifest.safe
* `subswath`
* `polarisation`
* `bi1` - first burst index
* `bi2` - last burst index
* `sigma` - true/false value for calibration type
* `gamma` - true/false value for calibration type
* `beta` - true/false value for calibration type
* `dem`
* `output` - output filename (GeoTIFF)

## calibration_3sw.xml

Whole scene calibration

Parameters:
* `input` - SAFE.zip or .SAFE/manifest.safe
* `polarisation`
* `sigma` - true/false value for calibration type
* `gamma` - true/false value for calibration type
* `beta` - true/false value for calibration type
* `dem`
* `output` - output filename (GeoTIFF)

## coherence_1sw_bindex.xml

Single subswath coherence estimation

Parameters:
* `reference` - SAFE.zip or .SAFE/manifest.safe
* `secondary` - SAFE.zip or .SAFE/manifest.safe
* `subswath`
* `polarisation`
* `b_ref1` - reference scene's first burst index
* `b_ref2` - reference scene's last burst index
* `b_sec1` - secondary scene's first burst index
* `b_sec2` - secondary scene's last burst index
* `dem`
* `output` - output filename (GeoTIFF)


## coherence_3sw.xml

Whole scene coherence estimation

Parameters:
* `reference` - SAFE.zip or .SAFE/manifest.safe
* `secondary` - SAFE.zip or .SAFE/manifest.safe
* `polarisation`
* `dem`
* `output` - output filename (GeoTIFF)
