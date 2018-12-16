#!/bin/bash
FOLDER_PREFIX="FOLDER-"
LOG_PATH=/media/menu.log
FOLDERS_RUN=/var/run/folders
FOLDERS_GAADATA=$(cat "${FOLDERS_RUN}/gaadata")
FOLDERS_PCSXDATA=$(cat "${FOLDERS_RUN}/pcsxdata")
FOLDERS_SRC=$(cat "${FOLDERS_RUN}/src")

# $1 src
# $2 dest
# folders only
link_folders () {
    echo "enter link_folders"
    echo "$@"
    for D in $1/*; do
        echo "${D}"
        if [ -d "${D}" ]; then
            echo "link!"
            ln -s "${D}" "$2"
        fi
    done
    echo "exit link_folders"
}

setup_ui () {
    echo "start setup"
    umount /gaadata/databases
    menu_folder=${1#"$FOLDER_PREFIX"}
    new_menu_path="${FOLDERS_SRC}/${menu_folder}"
    if [ -f "${new_menu_path}/gaa_redirect" ]; then
        echo "have redirect"
        folder_src_path=$(cat "${new_menu_path}/gaa_redirect")
        is_overridden=1
    else
        echo "don't have redirect"
        folder_src_path="${new_menu_path}"
        is_overridden=0
    fi
    rm -r "${FOLDERS_GAADATA}"
    mkdir -p "${FOLDERS_GAADATA}"
    echo "linking gaadata"
    link_folders "${folder_src_path}" "${FOLDERS_GAADATA}"
    if [ -f "${new_menu_path}/data_redirect" ]; then
        echo "have data redirect"
        folder_src_path=$(cat "${new_menu_path}/data_redirect")
    fi
    rm -r "${FOLDERS_PCSXDATA}"
    mkdir -p "${FOLDERS_PCSXDATA}"
    echo "linking pcsxdata"
    link_folders "${folder_src_path}" "${FOLDERS_PCSXDATA}"
    ln -s /gaadata/geninfo "${FOLDERS_GAADATA}"
    ln -s /gaadata/preferences "${FOLDERS_GAADATA}"
    ln -s /gaadata/system "${FOLDERS_GAADATA}"
    # Assume BIOS and plugins folders are there
    ln -s /gaadata/system/bios "${FOLDERS_PCSXDATA}"
    ln -s /usr/sony/bin/plugins "${FOLDERS_PCSXDATA}"
    if [ -d "${folder_src_path}/databases" ]; then
        echo "mounting database"
        mount -o bind "${folder_src_path}/databases" /gaadata/databases
    fi

    if [ "${is_overridden}" -eq 1 ]; then
        echo "linking gaadata additional"
        link_folders "${new_menu_path}" "${FOLDERS_GAADATA}"
        if [ -d "${new_menu_path}/databases" ]; then
            echo "remounting database from redirect"
            umount /gaadata/databases
            mount -o bind "${new_menu_path}/databases" /gaadata/databases
        fi
    fi
    sync
    echo "setup done"
} >> "${LOG_PATH}" 2>&1

do_folders () {
    echo "do do_folders"

    # Shut down ui_menu
    touch /data/power/prepare_suspend
    sleep 1
    rm /data/power/prepare_suspend

    setup_ui "$1"

    echo "${FOLDERS_GAADATA}:"
    ls -l "${FOLDERS_GAADATA}"
    echo "${FOLDERS_PCSXDATA}:"
    ls -l "${FOLDERS_PCSXDATA}"

    # Reset index before launching
    sed -i "s/iUiUserSettingLastSelectGameCursorPos=.*/iUiUserSettingLastSelectGameCursorPos=0/" /data/AppData/sony/ui/user.pre

    cd "${FOLDERS_PCSXDATA}"
    cur_depth=$(cat "${FOLDERS_RUN}/depth")
    if [ "${cur_depth}" -eq 1 -a $2 -ne 0 ]; then
        # First level, emulate fresh boot
        /usr/sony/bin/showLogo 1200000 200000
    fi
    /usr/sony/bin/ui_menu --power-off-enable &
} >> "${LOG_PATH}" 2>&1

launch_menu () {
    echo "do launch_menu"
    cur_depth=$(cat "${FOLDERS_RUN}/depth")
    cur_depth=$((cur_depth + 1))
    echo "${cur_depth}" > "${FOLDERS_RUN}/depth"
    echo "$1" > "${FOLDERS_RUN}/${cur_depth}"
    do_folders "$1" 1
} >> "${LOG_PATH}" 2>&1

shutdown_menu () {
    echo "do shutdown_menu"
    cur_depth=$(cat "${FOLDERS_RUN}/depth")
    rm "${FOLDERS_RUN}/${cur_depth}"
    cur_depth=$((cur_depth - 1))
    echo "${cur_depth}" > "${FOLDERS_RUN}/depth"
    echo "depth: ${cur_depth}"
    if [ "${cur_depth}" -gt 0 ]; then
        prev_folder=$(cat "${FOLDERS_RUN}/${cur_depth}")
        do_folders "${prev_folder}" 0
    else
        ${FOLDERS_SRC}/menu_cleanup.sh
    fi
} >> "${LOG_PATH}" 2>&1

launch_pcsx () {
    echo "run pcsx" >> "${LOG_PATH}"
    /usr/sony/bin/pcsx "$@"
}

# Main
echo "hello intercept $@" >> "${LOG_PATH}"
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
