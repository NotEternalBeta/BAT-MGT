#!/bin/bash

program_path="$(dirname "$(realpath "$0")")"
#echo "'$program_path'"

main_profiles_path="$program_path/profiles/main"
charge_threshold_profiles_path="$program_path/profiles/charge_threshold"

main_configs=$(ls "$main_profiles_path")
charge_threshold_configs=$(ls "$charge_threshold_profiles_path")
#echo "Список файлов в папке основных конфигов: $main_configs"
#echo "Список файлов в папке конфигов лимита заряда: $charge_threshold_configs"


