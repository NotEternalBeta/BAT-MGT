#!/bin/bash

program_path="$(dirname "$(realpath "$0")")"
#echo "'$program_path'"

main_profiles_path="$program_path/profiles/main"
charge_threshold_profiles_path="$program_path/profiles/charge_threshold"

main_configs=$(ls "$main_profiles_path")
charge_threshold_configs=$(ls "$charge_threshold_profiles_path")
#echo "Список файлов в папке основных конфигов: $main_configs"
#echo "Список файлов в папке конфигов лимита заряда: $charge_threshold_configs"

mkdir -p "$program_path/data"
data_file="$program_path/data/data.txt"
if [ ! -f "$program_path/data/data.txt" ]; then
    touch $data_file
fi

current_profile=$(cat $data_file)
current_profile_index=-1

# return index profile from current data, otherwise -1
get_current_main_profile_index() {
    #current_profile_index=$((current_profile_index + 1))
    local index=-1
    if [ -f "$main_profiles_path/$current_profile" ]; then
        for profile in "$main_profiles_path"/*.conf; do
            index=$((index + 1))
            #echo "$profile"
            local profile_short="$(basename "$profile")"
            #echo "$profile_short"
            if [ "$profile_short" == "$current_profile" ]; then
                #echo "eq"
                break
            fi
        done
    fi

    echo "$index"
}

#echo $(get_current_main_profile_index)
