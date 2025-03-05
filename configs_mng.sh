#!/bin/bash

program_path="$(dirname "$(realpath "$0")")"
target_path="/etc/tlp.d"
#echo "'$program_path'"
data_path="$program_path/data"
current_profiles_data="$data_path/current_profiles.txt"
profiles_mapping_data="$data_path/profiles_mapping.txt"

profiles_path="$program_path/profiles"
main_profiles_path="$program_path/profiles/main"
charge_threshold_profiles_path="$program_path/profiles/charge_threshold"

#main_configs=$(ls "$main_profiles_path")
#charge_threshold_configs=$(ls "$charge_threshold_profiles_path")
#echo "Список файлов в папке основных конфигов: $main_configs"
#echo "Список файлов в папке конфигов лимита заряда: $charge_threshold_configs"

#profile_params=("file" "label" "caption")

declare -A current_profiles
declare -A profiles_indexes
declare -A profiles_map

init() {
    mkdir -p "$data_path"
    if [ ! -f "$current_profiles_data" ]; then
        touch "$current_profiles_data"
    fi
    if [ ! -f "$profiles_mapping_data" ]; then
        touch "$profiles_mapping_data"
    fi
}
init

read_profiles() {
    while IFS='=' read -r key value; do
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        current_profiles["$key"]="$value"
    done < "$current_profiles_data"

    while IFS='=' read -r key value; do
        [[ -z "$key" || "$key" =~ ^# ]] && continue
        profiles_map["$key"]="$profiles_path/$value"
    done < "$profiles_mapping_data"
}
read_profiles

set_indexes() {
    for key in "${!profiles_map[@]}"; do
        profiles_indexes["$key"]=-1
        
        if [[ ! -v current_profiles[$key] || -z ${current_profiles[$key]} ]]; then
            #echo "was null: '$key' = '${current_profiles[$key]}'"
            continue
        fi

        if [[ ! -f "${profiles_map[$key]}/${current_profiles[$key]}" ]]; then
            #echo "No such file or directory."
            continue
        fi
        
        #echo "list: "
        #ls "${profiles_map[$key]}"
        #echo "end list"

        for file in "${profiles_map[$key]}"/*.conf; do
            #echo "Key type: $(declare -p key)"
            profiles_indexes["$key"]=$((profiles_indexes["$key"]+1))
            #echo "check: key: '$key' value: '${profiles_indexes[$key]}' in file '$file'"
            #echo "result: ${profiles_indexes[$key]}"
            local profile_name="$(basename "$file")"
            if [ "$profile_name" == "${current_profiles[$key]}" ]; then
                #echo "break on: '$profile_name'"
                break;
            fi
        done
    done
}
set_indexes

print_profiles_data() {
    printf "Data from current_profiles.txt:\n"
    for key in "${!current_profiles[@]}"; do
        printf "'%s' = '%s'\n"  "$key" "${current_profiles[$key]}"
    done
    printf "\nData from profiles_mapping.txt\n"
    for key in "${!profiles_map[@]}"; do
        printf "'%s' = '%s'\n"  "$key" "${profiles_map[$key]}"
    done
    printf "\n"
}
print_profiles_data

print_indexes() {
    printf "Printing indexes:\n"
    for key in "${!profiles_indexes[@]}"; do
        printf "'%s' = '%d'\n" "$key" "${profiles_indexes[$key]}"
    done
    printf "\n"
}
print_indexes

key_main="main"
key_charge_threshold="charge_threshold"



# return index profile from current data, otherwise -1
get_current_profile_index() {
    local index=-1
    local key
    local current_profile
    local profiles_path
    case "$1" in
        "main")
            key="$key_main"
            profiles_path="$main_profiles_path"
        ;;
        "charge_threshold")
            key="$key_charge_threshold"
            profiles_path="$charge_threshold_profiles_path"
        ;;

        *)
            echo "Provided key was incorrect"
            return
        ;;
    esac
    
    local current_from_data="$(grep "^$key=" "$data_file" | cut -d'=' -f2)"
    if [ -n "$current_from_data" ]; then
        echo "empty"
    fi

    if [ -f "$profiles_path/$current_from_data" ]; then
        for profile in "$profiles_path"/*.conf; do
            index=$((index + 1))
            #echo "$profile"
            local profile_short="$(basename "$profile")"
            #echo "$profile_short"
            if [ "$profile_short" == "$current_from_data" ]; then
                #echo "eq"
                break
            fi
        done
    fi

    echo "$index"
}
#echo $(get_current_profile_index)

is_current_profile() {
    if [[ -z "$1" ]]; then
        echo "The key was not provided"
        return 1
    fi
    if [[ ! -v current_profiles[$1] || -z ${current_profiles[$1]} ]]; then
        echo "Provided key '$1' was incorrect."
        return 1
    fi
    return 0
}

has_configs_with_key() { 
    if [[ -z "$1" ]]; then
        echo "The key was not provided"
        return 1
    fi
    if [[ ! -v profiles_indexes["$1"] ]]; then
        echo "Provided key '$1' was incorrect."
        return 1
    fi

    if [ ${profiles_indexes["$1"]} -eq -1 ]; then
        echo "No configs provided for key '$1'"
        return 1
    fi

    return 0
}

is_profile_active() {
    if ! is_current_profile "$1"; then
        return 1
    fi
    
    local target="$target_path/${current_profiles["$1"]}"
    if [ ! -f "$target" ]; then
        #echo "No such config in tlp.d/ with key: '$1' target: '$target'"
        return 1
    fi

    if ! has_configs_with_key "$1"; then
        return 1
    fi
    
    local source_config="${profiles_map["$1"]}/${current_profiles["$1"]}"
    if ! cmp -s "$target" "$source_config"; then
        #echo "Configs not equals. Source: '$source_config'"
        return 1
    fi
    
    return 0
}

print_active_profile_with_key() { 
    if ! is_profile_active "$1"; then
        return
    fi
    
    local source_config="${profiles_map["$1"]}/${current_profiles["$1"]}"
    printf "key: '%s' config: '%s'\n" "$1" "$source_config"
}

print_all_active_profiles() { 
    echo "---- Active configs ----"
    for key in "${!current_profiles[@]}"; do
        print_active_profile_with_key "$key"
    done
    echo "----                ----"
}
print_all_active_profiles
