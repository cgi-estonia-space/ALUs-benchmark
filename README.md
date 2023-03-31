
# ALUs benchmark

Various scripts/utilities are gathered here to facilitate benchmarking and validation and comparisons of the ALUs results

Validation datasets can be easily fetched (along with necessary aux files):
`aws s3 sync s3://alus-goods-set/validation . --no-sign-request`

For SNAP based comparisons it is necessary to increase JAI cache size.
In `~/snap/etc/snap.properties` set `snap.jai.tileCacheSize=10240` to something large, like 10GB in this example, 
less can work well too, but default 1GB will prolong coherence results ALOT, might even get stuck.
Also SNAP requires about 70GB of RAM in order to process all 3 subswaths for coherence, less for other routines/areas.
`snap.parallelism` is left default (commented out), since JAVA can detect available cores correct.

## alus_snap_comparison_report.sh

First a SNAP GPT command and then the respective ALUs command shall be supplied. The directory for the output results as well.
As an optional argument could be some command that shall be called before each tools invocation (for example clearing the cache - `sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'`)

If environment variable `NO_RASTCOMP` is set, the raster comparison is not invoked. This is meant to purely run series of time measurements

Example:
```
./alus_snap_comparison_report.sh "gpt snap_gpt/calibration_1sw_bindex.xml -Poutput=/tmp/alus_validation/snap_cal.tif -Psubswath=IW1 -Pinput=/tmp/flood_in_belgium_germany/S1A_IW_SLC__1SDV_20210703T055050_20210703T055117_038609_048E45_35F7.SAFE/manifest.safe -Psigma=true -Pgamma=false -Pbeta=false -Pbi1=1 -Pbi2=9 -Ppolarisation=VV" "alus-cal -i /tmp/flood_in_belgium_germany/S1A_IW_SLC__1SDV_20210703T055050_20210703T055117_038609_048E45_35F7.SAFE  -o /tmp/alus_validation/ --sw IW1 -p VV --bi1 1 --bi2 9 -t sigma --dem /tmp/validation_datasets/flood_in_belgium_germany/aux/srtm_37_02.tif --dem /tmp/validation_datasets/flood_in_belgium_germany/aux/srtm_37_03.tif --dem /tmp/validation_datasets/flood_in_belgium_germany/aux/srtm_38_02.tif --dem /tmp/validation_datasets/flood_in_belgium_germany/aux/srtm_38_03.tif" /tmp/alus_validation
```

Its descendant `alus_snap_comparison_report_loop.sh` simply relays the command and iterates up to a specified count.
While on a first invocation a cache clean command is used and rastcomp is called. In subsequent calls these additional calls are not done.
This is simply to faster evaluate some averages of the processing time.
