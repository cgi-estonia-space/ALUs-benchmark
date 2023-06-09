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

cd $benchmark_scripts_dir
scenarios_results="results"
scenario="calibration_1sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Psubswath=IW1 -Pinput=${datasets_dir}/S1A_IW_SLC__1SDV_20210703T055050_20210703T055117_038609_048E45_35F7.SAFE/manifest.safe -Psigma=true -Pgamma=false -Pbeta=false -Pbi1=1 -Pbi2=9 -Ppolarisation=VV -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${datasets_dir}/S1A_IW_SLC__1SDV_20210703T055050_20210703T055117_038609_048E45_35F7.SAFE  -o ${benchmark_results_dir} --sw IW1 -p VV --bi1 1 --bi2 9 -t sigma --dem ${datasets_dir}/aux/srtm_38_02.tif --dem ${datasets_dir}/aux/srtm_38_03.tif --ll info" $benchmark_results_dir $run_repeats

scenario="calibration_3sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_3sw.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Pinput=${datasets_dir}/S1A_IW_SLC__1SDV_20210703T055050_20210703T055117_038609_048E45_35F7.SAFE/manifest.safe -Psigma=true -Pgamma=false -Pbeta=false -Ppolarisation=VV -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${datasets_dir}/S1A_IW_SLC__1SDV_20210703T055050_20210703T055117_038609_048E45_35F7.SAFE  -o ${benchmark_results_dir} -p VV -t sigma --dem ${datasets_dir}/aux/srtm_38_02.tif --dem ${datasets_dir}/aux/srtm_38_03.tif --dem ${datasets_dir}/aux/srtm_37_02.tif --dem ${datasets_dir}/aux/srtm_37_03.tif --ll info" $benchmark_results_dir $run_repeats

scenario="coherence_1sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE/manifest.safe -Psecondary=${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE/manifest.safe -Ppolarisation=VV -Psubswath=IW1 -Pb_ref1=1 -Pb_ref2=9 -Pb_sec1=1 -Pb_sec2=9 -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE -s ${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE -o ${benchmark_results_dir} --sw IW1 -p VV --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor --dem ${datasets_dir}/aux/srtm_38_02.tif --dem ${datasets_dir}/aux/srtm_38_03.tif --ll info" $benchmark_results_dir $run_repeats

# About 70GB of RAM required for SNAP GPT
scenario="coherence_3sw_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_3sw.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE/manifest.safe -Psecondary=${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE/manifest.safe -Ppolarisation=VV -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE -s ${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE -o ${benchmark_results_dir} -p VV --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor --dem ${datasets_dir}/aux/srtm_38_02.tif --dem ${datasets_dir}/aux/srtm_38_03.tif --dem ${datasets_dir}/aux/srtm_37_02.tif --dem ${datasets_dir}/aux/srtm_37_03.tif --ll info" $benchmark_results_dir $run_repeats

scenario="coherence_bursts_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_1sw_bindex_main.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE/manifest.safe -Psecondary=${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE/manifest.safe -Ppolarisation=VV -Psubswath=IW3 -Pb_ref1=4 -Pb_ref2=7 -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE -s ${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE -o ${benchmark_results_dir} -p VV --b_ref1 4 --sw IW3 --b_ref2 7 --b_sec1=1 --b_sec2=9 --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor  --dem ${datasets_dir}/aux/srtm_37_02.tif --dem ${datasets_dir}/aux/srtm_37_03.tif --ll info" $benchmark_results_dir $run_repeats

scenario="coherence_aoi_srtm3"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
./alus_snap_comparison_report_loop.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_aoi.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE/manifest.safe -Psecondary=${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE/manifest.safe -Ppolarisation=VV -Psubswath=IW3 -Paoi=\"POLYGON ((3.686 50.373, 4.689 50.291, 4.638 50.042, 3.686 50.373))\" -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE -s ${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE -o ${benchmark_results_dir} -p VV --aoi \"POLYGON ((3.686 50.373, 4.689 50.291, 4.638 50.042, 3.686 50.373))\" --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor --dem ${datasets_dir}/aux/srtm_37_02.tif --dem ${datasets_dir}/aux/srtm_37_03.tif --ll info" $benchmark_results_dir $run_repeats

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
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Psubswath=IW1 -Pinput=${datasets_dir}/S1A_IW_SLC__1SDV_20210703T055050_20210703T055117_038609_048E45_35F7.SAFE/manifest.safe -Psigma=true -Pgamma=false -Pbeta=false -Pbi1=1 -Pbi2=9 -Ppolarisation=VV -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${datasets_dir}/S1A_IW_SLC__1SDV_20210703T055050_20210703T055117_038609_048E45_35F7.SAFE  -o ${benchmark_results_dir} --sw IW1 -p VV --bi1 1 --bi2 9 -t sigma --dem ${datasets_dir}/aux/srtm_38_02.tif --dem ${datasets_dir}/aux/srtm_38_03.tif --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/${scenarios_results}/.

scenario="calibration_3sw_srtm3_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/calibration_3sw.xml -Poutput=${benchmark_results_dir}/snap_cal.tif -Pinput=${datasets_dir}/S1A_IW_SLC__1SDV_20210703T055050_20210703T055117_038609_048E45_35F7.SAFE/manifest.safe -Psigma=true -Pgamma=false -Pbeta=false -Ppolarisation=VV -Pdem=\"SRTM 3Sec\"" "alus-cal -i ${datasets_dir}/S1A_IW_SLC__1SDV_20210703T055050_20210703T055117_038609_048E45_35F7.SAFE  -o ${benchmark_results_dir} -p VV -t sigma --dem ${datasets_dir}/aux/srtm_38_02.tif --dem ${datasets_dir}/aux/srtm_38_03.tif --dem ${datasets_dir}/aux/srtm_37_02.tif --dem ${datasets_dir}/aux/srtm_37_03.tif --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/${scenarios_results}/.

scenario="coherence_1sw_srtm3_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_1sw_bindex.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE/manifest.safe -Psecondary=${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE/manifest.safe -Ppolarisation=VV -Psubswath=IW1 -Pb_ref1=1 -Pb_ref2=9 -Pb_sec1=1 -Pb_sec2=9 -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE -s ${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE -o ${benchmark_results_dir} --sw IW1 -p VV --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor --dem ${datasets_dir}/aux/srtm_38_02.tif --dem ${datasets_dir}/aux/srtm_38_03.tif --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/${scenarios_results}/.

# About 70GB of RAM required for SNAP GPT
scenario="coherence_3sw_srtm3_ramdisk"
benchmark_results_dir="${datasets_dir}/${scenarios_results}/${scenario}"
rm -rf ${benchmark_results_dir}/*
NO_RASTCOMP=1 ./alus_snap_comparison_report.sh "gpt ${benchmark_scripts_dir}/snap_gpt/coherence_3sw.xml -Poutput=${benchmark_results_dir}/snap_coh.tif -Preference=${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE/manifest.safe -Psecondary=${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE/manifest.safe -Ppolarisation=VV -Pdem=\"SRTM 3Sec\"" "alus-coh -r ${datasets_dir}/S1B_IW_SLC__1SDV_20210615T054959_20210615T055026_027363_0344A0_83FE.SAFE -s ${datasets_dir}/S1B_IW_SLC__1SDV_20210721T055001_20210721T055028_027888_0353E2_E1B5.SAFE -o ${benchmark_results_dir} -p VV --az_win 4 --orbit_dir ${datasets_dir}/aux --no_mask_cor --dem ${datasets_dir}/aux/srtm_38_02.tif --dem ${datasets_dir}/aux/srtm_38_03.tif --dem ${datasets_dir}/aux/srtm_37_02.tif --dem ${datasets_dir}/aux/srtm_37_03.tif --ll info" $benchmark_results_dir
cp -r $benchmark_results_dir ${datasets_dir_origin}/${scenarios_results}/.

rm -rf ${ram_disk_path}/*
sudo umount ${ram_disk_path}

