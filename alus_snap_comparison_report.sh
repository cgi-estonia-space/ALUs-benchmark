#!/bin/bash

set -e

function print_help {
    echo "Usage:"
    echo "$0 <snap gpt command> <alus command> <output directory> [optional - preprocess command]"
}

if [ $# -lt 3 ]; then
    echo "Wrong count of input arguments"
    print_help
    exit 1
fi

snap_gpt_cmd="$1"
alus_cmd="$2"
output_dir="$3"

mkdir -p $output_dir

if [ $# -eq 4 ]; then
    echo "Calling $4"
    eval "$4"
fi
snap_cmd_log=$output_dir/snap_gpt_cmd.txt
# 'eval' - in order to respect spaces in 'dem' variable
(time eval "$snap_gpt_cmd") 2>&1 | tee $snap_cmd_log 
if [ $# -eq 4 ]; then
    echo "Calling $4"
    eval "$4"
fi
alus_cmd_log=$output_dir/alus_cmd.txt
(time eval "$alus_cmd") 2>&1 | tee $alus_cmd_log

# Sort by date created
results=($(find $output_dir -maxdepth 1 -name "*.tif" -printf "%T@\t%p\n" | sort -n | cut -f2-))
# For SNAP GPT the filename is statically given, for ALUs it is derived from processed steps, use that.
product_base_name="${results[-1]%.*}"
snap_no_data_fn=${product_base_name}_snap.tif


if [[ -z "${NO_RASTCOMP}" ]]; then
    echo "creating NODATA to SNAP results..."
    gdal_calc.py -A ${results[-2]} --outfile=$snap_no_data_fn --calc="A*(A>0)" --NoDataValue=0
fi

alus_result_fn=${results[-1]}
tmp_file_stats=$output_dir/stats.tmp
combined_stats_file=${output_dir}/comp_stats.csv
result_raster=($snap_no_data_fn $alus_result_fn)
cmd_logs=($snap_cmd_log $alus_cmd_log)
for i in "${!result_raster[@]}"
do
    :
    gdalinfo -stats ${result_raster[i]} > $tmp_file_stats
    echo -n "| $(basename ${result_raster[i]}) |" >> $combined_stats_file
    stats=(STATISTICS_MINIMUM STATISTICS_MAXIMUM STATISTICS_MEAN STATISTICS_STDDEV STATISTICS_VALID_PERCENT)
    for s in "${stats[@]}"
    do
        :
        echo -n " " >> $combined_stats_file
        stat_entry=$(grep $s $tmp_file_stats | tr -d '\n' | cut -f2 -d'=')
        echo -n $stat_entry >> $combined_stats_file
        echo -n " |" >> $combined_stats_file
    done
    time_measured=$(grep "real" ${cmd_logs[i]}  | awk -F" " '{ print $2 }' | sed 's/m/:/g' | sed 's/s//g')
    echo " $time_measured |" >> $combined_stats_file
done

if [[ -z "${NO_RASTCOMP}" ]]; then
    echo "rastcomp generation..."
    rastcomp_stats_fn=$output_dir/rastcomp_overall_stats.txt
    rastcomp $snap_no_data_fn ${results[-1]} $output_dir | tee $rastcomp_stats_fn 
    bad_pixels=$(grep "bad pixels" $rastcomp_stats_fn | tail -1 | sed 's/\bppm\b//g' | cut -f2 -d'=')
    avg_rel_diff=$(grep "avg rel diff" $rastcomp_stats_fn | tail -1 | sed 's/\bppm\b//g' | cut -f1 -d',' | cut -f2 -d'=')
    median=$(grep "median" $rastcomp_stats_fn | tr -d '\n' | cut -f2 -d'=' | sed 's/\bppm\b//g')
    echo "| rastcomp | | | $avg_rel_diff | $median | $bad_pixels | |" >> $combined_stats_file
fi


