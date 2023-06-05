#!/bin/bash

# Same repo's root directory
benchmark_dir=$1
# Dir where all S3 validation datasets have been copied to
datasets_dir=$2

./run_typhoon_haishen.sh $benchmark_dir ${datasets_dir}/typhoon_haishen_in_japan/
./run_earthquake_sulawesi.sh $benchmark_dir ${datasets_dir}/earthquake_damage_at_west_sulawesi/
./run_disaster_beirut.sh $benchmark_dir ${datasets_dir}/land_destruction_at_beirut/
./run_flood_in_belgium_germany.sh $benchmark_dir ${datasets_dir}/flood_in_belgium_germany/
./run_flood_in_panama.sh $benchmark_dir ${datasets_dir}/flood_in_panama/
./run_maharashtra.sh $benchmark_dir ${datasets_dir}/flood_in_maharashtra/

