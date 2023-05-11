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
run_repeats=3

# These scenes' swaths contain 10 bursts
scene_ref="${datasets_dir}/S1B_IW_SLC__1SDV_20200730T034254_20200730T034321_022695_02B131_E8DD.SAFE"
scene_sec="${datasets_dir}/S1A_IW_SLC__1SDV_20200805T034334_20200805T034401_033766_03E9F9_52F6.SAFE"
dem_files_3sw="--dem ${datasets_dir}/aux/srtm_43_05.tif --dem ${datasets_dir}/aux/srtm_43_06.tif --dem ${datasets_dir}/aux/srtm_44_06.tif"
dem_files_land="--dem ${datasets_dir}/aux/srtm_44_06.tif"
single_swath="IW1"
polarization="VV"

cd $benchmark_scripts_dir
scenarios_results="results"

scenario="coherence_1sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref}/manifest.safe -Psecondary=${scene_sec}/manifest.safe -Ppolarisation=${polarization} -Psubswath=${single_swath} -Pb_ref1=1 -Pb_ref2=10 -Pb_sec1=1 -Pb_sec2=10 -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} --sw ${single_swath} -p ${polarization} --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor ${dem_files_land} --ll info" $benchmark_results_dir $run_repeats

# About 70GB of RAM required for SNAP GPT
scenario="coherence_3sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_3sw.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref}/manifest.safe -Psecondary=${scene_sec}/manifest.safe -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} -p ${polarization} --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor ${dem_files_3sw} --ll info" $benchmark_results_dir $run_repeats

scenario="coherence_burst_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_1sw_bindex_main.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref}/manifest.safe -Psecondary=${scene_sec}/manifest.safe -Ppolarisation=${polarization} -Psubswath=${single_swath} -Pb_ref1=5 -Pb_ref2=5 -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} -p ${polarization} --sw ${single_swath} --b_ref1 5 --b_ref2 5 --b_sec1=1 --b_sec2=10 --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor ${dem_files_land} --ll info" $benchmark_results_dir $run_repeats

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

scenario="coherence_1sw_srtm3_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref}/manifest.safe -Psecondary=${scene_sec}/manifest.safe -Ppolarisation=${polarization} -Psubswath=${single_swath} -Pb_ref1=1 -Pb_ref2=10 -Pb_sec1=1 -Pb_sec2=10 -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} --sw ${single_swath} -p ${polarization} --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor ${dem_files_land} --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/${scenarios_results}/.

# About 70GB of RAM required for SNAP GPT
scenario="coherence_3sw_srtm3_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_3sw_mask_cor.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${scene_ref}/manifest.safe -Psecondary=${scene_sec}/manifest.safe -Ppolarisation=${polarization} -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${scene_ref} -s ${scene_sec} -o ${benchmark_results_dir} -p ${polarization} --az_win 4 --orbit_dir ${datasets_dir}/aux ${dem_files_3sw} --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/${scenarios_results}/.

rm -rf ${ram_disk_path}/*
sudo umount ${ram_disk_path}

