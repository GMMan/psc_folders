#!/bin/bash

FOLDER_PREFIX="FOLDER-"

# $1 src
# $2 dest
# folders only
link_folders () {
    rm -r "$2/"
    for D in "$1"; do
        if [ -d "${D}"]; then
            ln -s "${D}" "$2"
        fi
    done
}

setup_ui () {
    menu_folder=${1#"$FOLDER_PREFIX"}
    new_menu_path="${FOLDERS_SRC}/${menu_folder}"
    if [ -f "${new_menu_path}/gaa_redirect" ]; then
        folder_src_path=$(cat "${new_menu_path}/gaa_redirect")
    else
        folder_src_path="${new_menu_path}"
        is_overridden=1
    fi
    rm -r "${FOLDERS_GAADATA}"
    link_folders "${folder_src_path}" "${FOLDERS_GAADATA}"
    if [ -f "${new_menu_path}/data_redirect" ]; then
        folder_src_path=$(cat "${new_menu_path}/data_redirect")
    fi
    rm -r "${FOLDERS_PCSXDATA}"
    link_folders "${folder_src_path}" "${FOLDERS_PCSXDATA}"
    ln -s /gaadata/geninfo "${FOLDERS_GAADATA}"
    ln -s /gaadata/preferences "${FOLDERS_GAADATA}"
    ln -s /gaadata/system "${FOLDERS_GAADATA}"
    # Assume BIOS and plugins folders are there
    ln -s /gaadata/system/bios "${FOLDERS_PCSXDATA}"
    ln -s /usr/sony/bin/plugins "${FOLDERS_PCSXDATA}"
    if [ "${is_overridden}" -eq 1 ]; then
        link_folders "${new_menu_path}" "${FOLDERS_GAADATA}"
        if [ -d "${new_menu_path}/databases" ]; then
            # Unlink original DB and link to the one in the menu folder that
            # we've added a back option to
            rm "${FOLDERS_GAADATA}/databases"
            ln -s "${new_menu_path}/databases" "${FOLDERS_GAADATA}"
        fi
    fi
}

launch_menu () {
    cur_depth=$(cat "${FOLDERS_RUN}/depth")
    cur_depth=$((cur_depth + 1))
    echo "${cur_depth}" > "${FOLDERS_RUN}/depth"
    echo "$1" > "${FOLDERS_RUN}/${cur_depth}"
    killall -9 ui_menu
    setup_ui "$1"
    if [ "${cur_depth}" -gt 1 ]; then
        cd "${FOLDERS_PCSXDATA}"
        /usr/sony/bin/ui_menu --power-off-enable &
    else
        systemctl start sonyapp.service &
    fi
}

shutdown_menu () {
    cur_depth=$(cat "${FOLDERS_RUN}/depth")
    prev_folder="${FOLDERS_RUN}/${cur_depth}"
    rm "${FOLDERS_RUN}/${cur_depth}"
    cur_depth=$((cur_depth - 1))
    echo "${cur_depth}" > "${FOLDERS_RUN}/depth"
    if [ "${cur_depth}" -gt 0 ]; then
        launch_menu "${prev_folder}"
    fi
}

launch_pcsx () {
    /usr/sony/bin/pcsx "$@"
}

# Main
for ((i=1; i < $#; i++)); do
    if [ "x${!i}" = "x-cdfile" ]; then
        # Is -cdfile argument, get next
        j=$((i + 1))
        cue_name=$(basename ${!j} .cue)
        if [[ ${cue_name} == ${FOLDER_PREFIX}* ]]; then
            launch_menu ${cue_name}
            exit
        elif [[ ${cue_name} = "FOLDEREXIT" ]]; then
            shutdown_menu
            exit
        fi
    fi
done

launch_pcsx "$@"
