#!/bin/bash

set -e

function print_help {
    echo "Usage:"
    echo "$0 <snap gpt command> <alus command> <output directory> <N times to run>"
}

if [ $# -lt 4 ]; then
    echo "Wrong count of input arguments"
    print_help
    exit 1
fi

snap_gpt_cmd="$1"
alus_cmd="$2"
output_dir="$3"
loop_times=$4

./alus_snap_comparison_report.sh "$snap_gpt_cmd" "$alus_cmd" "$output_dir" "sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'"
for ((i=1; i<$loop_times; i++)); do
    NO_RASTCOMP=1 NO_SNAP_NODATA_CONVERT=1 ./alus_snap_comparison_report.sh "$snap_gpt_cmd" "$alus_cmd" "$output_dir"  
done

