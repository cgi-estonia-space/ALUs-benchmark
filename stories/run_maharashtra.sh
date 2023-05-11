#!/bin/bash

set -e

function print_help {
    echo "Usage:"
    echo "$0 <alus benchmark repo dir> <datasets dir>"
}

if [ $# -lt 2 ]; then
    echo "Wrong count of input arguments"
    print_help
    exit 1
fi

benchmark_scripts_dir="$1"
datasets_dir="$2"
run_repeats=1

scene="${datasets_dir}/S1A_IW_SLC__1SDV_20210722T005537_20210722T005604_038883_049695_2E58.SAFE"
dem_files_3sw_srtm="--dem ${datasets_dir}/aux/srtm_51_09.tif --dem ${datasets_dir}/aux/srtm_52_09.tif"
dem_files_3sw_copdem="--dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N17_00_E073_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N17_00_E074_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N17_00_E075_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N16_00_E073_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N16_00_E074_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N16_00_E075_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N15_00_E074_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N15_00_E075_00_DEM.tif"
dem_file_single_swath_srtm="--dem ${datasets_dir}/aux/srtm_51_09.tif"
dem_files_single_swath_copdem="--dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N17_00_E073_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N17_00_E074_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N16_00_E073_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N16_00_E074_00_DEM.tif --dem ${datasets_dir}/aux/Copernicus_DSM_COG_10_N15_00_E074_00_DEM.tif"
single_swath="IW2"
calib_type="sigma"
calib_type_snap="-Psigma=true -Pgamma=false -Pbeta=false"
polarization="VH"

cd $benchmark_scripts_dir
scenarios_results="results"

scenario="calibration_1sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Psubswath=${single_swath} -Pinput=${scene}/manifest.safe ${calib_type_snap} -Pbi1=1 -Pbi2=10 -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${scene} -o ${benchmark_results_dir} --sw ${single_swath} -p ${polarization} -t ${calib_type} ${dem_file_single_swath_srtm} --ll info" $benchmark_results_dir $run_repeats

scenario="calibration_1sw_copdem30"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Psubswath=${single_swath} -Pinput=${scene}/manifest.safe ${calib_type_snap} -Pbi1=1 -Pbi2=10 -Ppolarisation=${polarization} -Pdem=\"Copernicus 30m Global DEM\"" "alus-cal -i ${scene} -o ${benchmark_results_dir} --sw ${single_swath} -p ${polarization} -t ${calib_type} ${dem_files_single_swath_copdem} --ll info" $benchmark_results_dir $run_repeats

scenario="calibration_3sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_3sw.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Pinput=${scene}/manifest.safe ${calib_type_snap} -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${scene} -o ${benchmark_results_dir} -p ${polarization} -t ${calib_type} ${dem_files_3sw_srtm} --ll info" $benchmark_results_dir $run_repeats

scenario="calibration_3sw_copdem30"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_3sw.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Pinput=${scene}/manifest.safe ${calib_type_snap} -Ppolarisation=${polarization} -Pdem=\"Copernicus 30m Global DEM\"" "alus-cal -i ${scene} -o ${benchmark_results_dir} -p ${polarization} -t ${calib_type} ${dem_files_3sw_copdem} --ll info" $benchmark_results_dir $run_repeats

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
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Psubswath=${single_swath} -Pinput=${scene}/manifest.safe ${calib_type_snap} -Pbi1=1 -Pbi2=10 -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${scene} -o ${benchmark_results_dir} --sw ${single_swath} -p ${polarization} -t ${calib_type} ${dem_file_single_swath_srtm} --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/${scenarios_results}/.

scenario="calibration_1sw_copdem_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Psubswath=${single_swath} -Pinput=${scene}/manifest.safe ${calib_type_snap} -Pbi1=1 -Pbi2=10 -Ppolarisation=${polarization} -Pdem=\"Copernicus 30m Global DEM\"" "alus-cal -i ${scene} -o ${benchmark_results_dir} --sw ${single_swath} -p ${polarization} -t ${calib_type} ${dem_files_single_swath_copdem} --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/${scenarios_results}/.

scenario="calibration_3sw_srtm3_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_3sw.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Pinput=${scene}/manifest.safe ${calib_type_snap} -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${scene} -o ${benchmark_results_dir} -p ${polarization} -t ${calib_type} ${dem_files_3sw_srtm} --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/${scenarios_results}/.

scenario="calibration_3sw_copdem_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_3sw.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Pinput=${scene}/manifest.safe ${calib_type_snap} -Ppolarisation=${polarization} -Pdem=\"Copernicus 30m Global DEM\"" "alus-cal -i ${scene} -o ${benchmark_results_dir} -p ${polarization} -t ${calib_type} ${dem_files_3sw_copdem} --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/${scenarios_results}/.

rm -rf ${ram_disk_path}/*
sudo umount ${ram_disk_path}

