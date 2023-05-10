#!/bin/bash

set -e

function print_help {
    echo "Usage:"
    echo "$0 <alus benchmark repo dir> <datasets dir>"
}

if [ $# -lt 1 ]; then
    echo "Wrong count of input arguments"
    print_help
    exit 1
fi

benchmark_scripts_dir="$1"
datasets_dir="$2"
run_repeats=3

# These scenes' swaths contain 10 bursts
scene_ref="${datasets_dir}/S1A_IW_SLC__1SDV_20200904T111450_20200904T111520_034208_03F970_E017.SAFE"
scene_sec="${datasets_dir}/S1A_IW_SLC__1SDV_20200916T111451_20200916T111520_034383_03FF98_80D6.SAFE"
dem_files_3sw="--dem ${datasets_dir}/aux/srtm_20_11.tif --dem ${datasets_dir}/aux/srtm_20_10.tif"
dem_files_land="--dem ${datasets_dir}/aux/srtm_20_11.tif"
single_swath="IW2"
calib_type="gamma"
calib_type_snap="-Psigma=false -Pgamma=true -Pbeta=false"
polarization="VV"

cd $benchmark_scripts_dir
scenarios_results="results"
scenario="calibration_1sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Psubswath=${single_swath} -Pinput=${scene_sec}/manifest.safe ${calib_type_snap} -Pbi1=1 -Pbi2=10 -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${scene_sec} -o ${benchmark_results_dir} --sw ${single_swath} -p ${polarization} -t ${calib_type} ${dem_files_land} --ll info" $benchmark_results_dir $run_repeats

scenario="calibration_3sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_3sw.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Pinput=${scene_sec}/manifest.safe ${calib_type_snap} -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${scene_sec} -o ${benchmark_results_dir} -p ${polarization} -t ${calib_type} ${dem_files_3sw} --ll info" $benchmark_results_dir $run_repeats

scenario="coherence_1sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref}/manifest.safe -Psecondary=${scene_sec}/manifest.safe -Ppolarisation=${polarization} -Psubswath=${single_swath} -Pb_ref1=1 -Pb_ref2=10 -Pb_sec1=1 -Pb_sec2=10 -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} --sw ${single_swath} -p ${polarization} --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor ${dem_files_land} --ll info" $benchmark_results_dir $run_repeats

# About 70GB of RAM required for SNAP GPT
scenario="coherence_3sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_3sw.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref}/manifest.safe -Psecondary=${scene_sec}/manifest.safe -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} -p ${polarization} --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor ${dem_files_3sw} --ll info" $benchmark_results_dir $run_repeats

scenario="coherence_bursts_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_1sw_bindex_main.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref}/manifest.safe -Psecondary=${scene_sec}/manifest.safe -Ppolarisation=${polarization} -Psubswath=${single_swath} -Pb_ref1=5 -Pb_ref2=7 -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} -p ${polarization} --sw ${single_swath} --b_ref1 5 --b_ref2 7 --b_sec1=1 --b_sec2=10 --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor ${dem_files_land} --ll info" $benchmark_results_dir $run_repeats

scenario="coherence_aoi_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_aoi.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref} -Psecondary=${scene_sec} -Ppolarisation=${polarization} -Psubswath=${single_swath} -Paoi=\"POLYGON ((-82.189 8.612, -81.516 8.475, -81.577 8.380, -82.189 8.612))\" -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} -p ${polarization} --aoi \"POLYGON ((-82.189 8.612, -81.516 8.475, -81.577 8.380, -82.189 8.612))\" --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor ${dem_files_land} --ll info" $benchmark_results_dir $run_repeats

ram_disk_path="/mnt/ramdisk"
set -x
sudo mkdir -p ${ram_disk_path}
sudo chown $USER:$USER ${ram_disk_path}
if mountpoint -q ${ram_disk_path}; then
    sudo umount ${ram_disk_path}
fi
sudo mount -t tmpfs -o rw,size=50G tmpfs ${ram_disk_path}
cp -r ${datasets_dir}/*.SAFE ${ram_disk_path}/
cp -r ${datasets_dir}/aux ${ram_disk_path}/
set +x

datasets_dir_origin=${datasets_dir}
datasets_dir=${ram_disk_path}

scenario="calibration_1sw_srtm3_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Psubswath=${single_swath} -Pinput=${scene_sec}/manifest.safe ${calib_type_snap} -Pbi1=1 -Pbi2=10 -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${scene_sec} -o ${benchmark_results_dir} --sw ${single_swath} -p ${polarization} -t ${calib_type} ${dem_files_land} --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/.

scenario="calibration_3sw_srtm3_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_3sw.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Pinput=${scene_sec}/manifest.safe ${calib_type_snap} -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${scene_sec} -o ${benchmark_results_dir} -p ${polarization} -t ${calib_type} ${dem_files_3sw} --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/.

scenario="coherence_1sw_srtm3_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref}/manifest.safe -Psecondary=${scene_sec}/manifest.safe -Ppolarisation=${polarization} -Psubswath=${single_swath} -Pb_ref1=1 -Pb_ref2=10 -Pb_sec1=1 -Pb_sec2=10 -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} --sw ${single_swath} -p ${polarization} --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor ${dem_files_land} --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/.

# About 70GB of RAM required for SNAP GPT
scenario="coherence_3sw_srtm3_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_3sw.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref}/manifest.safe -Psecondary=${scene_sec}/manifest.safe -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} -p ${polarization} --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor ${dem_files_3sw} --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/.

rm -rf ${ram_disk_path}/*
sudo umount ${ram_disk_path}

