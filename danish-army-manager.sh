#!/data/data/com.termux/files/usr/bin/bash

# ======================================
#       DANISH ARMY TMP MANAGER
# ======================================

GREEN='\033[1;32m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
PURPLE='\033[1;35m'
RESET='\033[0m'

TMP_DIR="/data/local/tmp"
CHANNEL="https://whatsapp.com/channel/0029Vb9KKE9EQIas4fPYVG1c"
TERMUX_BASH="/data/data/com.termux/files/usr/bin/bash"
TERMUX_PATH="/data/data/com.termux/files/usr/bin:/system/bin:/system/xbin"

FILES=()
SELECTED=""

# ONLINE UPDATE SETTINGS
# Set OWNER and REPO to the existing GitHub repository used for this tool.
GITHUB_OWNER="Amir03218321"
GITHUB_REPO="FREE-FIRE-PANEL"
GITHUB_BRANCH="main"
APP_VERSION="1.0.1"

# DRIVER DOWNLOAD SETTINGS
DRIVER_API="https://api.github.com/repos/Amir03218321/DANISH-DRIVERS/contents"
DRIVER_RAW="https://raw.githubusercontent.com/Amir03218321/DANISH-DRIVERS/main"
DRIVER_LIST_TEMP="$HOME/danish-driver-list.json"
DRIVER_TEMP="$HOME/danish-driver-download.tmp"
DRIVER_FILES=()

# PANEL DOWNLOAD SETTINGS
PANEL_API="https://api.github.com/repos/Amir03218321/DANISH-ARMY-PANEL/contents?ref=main"
PANEL_RAW="https://raw.githubusercontent.com/Amir03218321/DANISH-ARMY-PANEL/main"
PANEL_LIST_TEMP="$HOME/danish-panel-list.json"
PANEL_TEMP="$HOME/danish-panel-download.tmp"
PANEL_FILES=()

banner() {
    clear
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════╗"
    echo "║    DANISH ARMY TMP MANAGER         ║"
    echo "╚════════════════════════════════════╝"
    echo -e "${RESET}"
}

file_control_style() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${YELLOW}║         FILE CONTROL PANEL         ║${RESET}"
    echo -e "${RED}╠════════════════════════════════════╣${RESET}"
    printf "${GREEN}║ SELECTED: %-25.25s ║${RESET}\n" "${SELECTED##*/}"
    echo -e "${YELLOW}╠════════════════════════════════════╣${RESET}"
    echo -e "${GREEN}║  1. EXECUTE FILE ▶                 ║${RESET}"
    echo -e "${CYAN}║  2. CHANGE PERMISSION              ║${RESET}"
    echo -e "${WHITE}║  3. VIEW FILE                      ║${RESET}"
    echo -e "${RED}║  4. DELETE FILE                    ║${RESET}"
    echo -e "${YELLOW}║  5. BACK TO FILE LIST              ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo
}

main_menu_style() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${YELLOW}║          MAIN CONTROL PANEL        ║${RESET}"
    echo -e "${RED}╠════════════════════════════════════╣${RESET}"
    echo -e "${GREEN}║  1. SHOW ALL TMP FILES             ║${RESET}"
    echo -e "${CYAN}║  2. SELECT FILE                    ║${RESET}"
    echo -e "${WHITE}║  3. REFRESH FILE LIST              ║${RESET}"
    echo -e "${YELLOW}║  4. JOIN WHATSAPP CHANNEL          ║${RESET}"
    echo -e "${GREEN}║  5. PANEL DOWNLOAD                 ║${RESET}"
    echo -e "${CYAN}║  6. DRIVER DOWNLOAD                ║${RESET}"
    echo -e "${RED}║  7. EXIT                           ║${RESET}"
    echo -e "${YELLOW}║  8. CHECK FOR UPDATES              ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo
}

pause() {
    echo
    read -r -p "Press ENTER to continue..."
}

quote_path() {
    local s="${1//\'/\'\\\'\'}"
    printf "'%s'" "$s"
}

open_channel() {
    if command -v termux-open-url >/dev/null 2>&1; then
        termux-open-url "$CHANNEL"
    elif command -v am >/dev/null 2>&1; then
        am start -a android.intent.action.VIEW -d "$CHANNEL"
    else
        echo "Open this channel manually: $CHANNEL"
    fi
}

channel_gate() {
    banner
    echo -e "${CYAN}OPENING WHATSAPP CHANNEL...${RESET}"
    open_channel
    echo
    echo -e "${YELLOW}HAVE YOU JOINED OUR CHANNEL?${RESET}"
    echo
    echo -e "${GREEN}1. YES${RESET}"
    echo -e "${RED}2. NO${RESET}"
    echo
    read -r -p "SELECT: " answer
    answer="$(printf '%s' "$answer" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')"
    case "$answer" in
        1|YES)
            echo -e "${GREEN}WELCOME TO DANISH ARMY!${RESET}"
            sleep 1
            ;;
        2|NO)
            echo -e "${RED}CHANNEL JOIN SKIPPED. EXITING.${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}INVALID SELECTION!${RESET}"
            exit 0
            ;;
    esac
}

root_check() {
    if ! command -v su >/dev/null 2>&1 || ! su -c "test -d '$TMP_DIR'"; then
        echo -e "${RED}ROOT ACCESS REQUIRED OR ROOT MANAGER UNAVAILABLE!${RESET}"
        exit 1
    fi
}

refresh_files() {
    mapfile -d '' -t FILES < <(su -c "find '$TMP_DIR' -maxdepth 1 -type f -print0" 2>/dev/null)
}

show_files() {
    refresh_files
    echo
    echo -e "${CYAN}══════════ TMP FILE DATABASE ══════════${RESET}"
    if [ "${#FILES[@]}" -eq 0 ]; then
        echo -e "${YELLOW}NO FILES FOUND!${RESET}"
        return
    fi
    for i in "${!FILES[@]}"; do
        echo
        echo -e "${GREEN}[$((i+1))]${RESET} ${WHITE}${FILES[$i]##*/}${RESET}"
    done
    echo
    echo -e "${CYAN}TOTAL FILES: ${#FILES[@]}${RESET}"
}

select_file() {
    show_files
    [ "${#FILES[@]}" -gt 0 ] || return 1
    echo
    read -r -p "ENTER FILE NUMBER: " number
    if ! [[ "$number" =~ ^[0-9]+$ ]] || [ "$number" -lt 1 ] || [ "$number" -gt "${#FILES[@]}" ]; then
        echo -e "${RED}INVALID FILE SELECTION!${RESET}"
        return 1
    fi
    SELECTED="${FILES[$((number-1))]}"
    if ! su -c "test -f $(quote_path "$SELECTED")"; then
        echo -e "${RED}FILE NO LONGER EXISTS!${RESET}"
        return 1
    fi
}

view_file() {
    echo
    echo -e "${CYAN}FILE PREVIEW${RESET}"
    echo -e "${WHITE}FILE: ${SELECTED##*/}${RESET}"
    echo
    su -c "sed -n '1,60p' $(quote_path "$SELECTED")"
    echo
    echo -e "${YELLOW}FIRST 60 LINES SHOWN${RESET}"
}

execute_file() {
    if [[ "$SELECTED" != *.sh ]]; then
        echo -e "${RED}ONLY .SH FILES ARE SUPPORTED!${RESET}"
        return
    fi
    if ! su -c "test -r $(quote_path "$SELECTED")"; then
        echo -e "${RED}FILE CANNOT BE READ!${RESET}"
        return
    fi
    if ! su -c "test -x $(quote_path "$TERMUX_BASH")"; then
        echo -e "${RED}TERMUX BASH NOT FOUND OR NOT EXECUTABLE!${RESET}"
        return
    fi
    echo
    echo -e "${RED}WARNING: THIS FILE WILL RUN WITH ROOT PRIVILEGES!${RESET}"
    echo -e "${YELLOW}Only run scripts you personally trust and have inspected.${RESET}"
    view_file
    read -r -p "TYPE YES TO CONFIRM: " confirm
    if [ "$confirm" = "YES" ]; then
        local dir="${SELECTED%/*}"
        local base="${SELECTED##*/}"
        su -c "cd $(quote_path "$dir") && export PATH=$(quote_path "$TERMUX_PATH") && exec $(quote_path "$TERMUX_BASH") $(quote_path "$base")"
        local result=$?
        if [ "$result" -eq 0 ]; then
            echo -e "${GREEN}EXECUTION COMPLETED SUCCESSFULLY!${RESET}"
        else
            echo -e "${RED}EXECUTION FAILED! EXIT CODE: $result${RESET}"
        fi
    else
        echo -e "${YELLOW}EXECUTION CANCELLED!${RESET}"
    fi
}

permission_menu() {
    echo
    echo -e "${CYAN}════════ PERMISSION CONTROL ════════${RESET}"
    echo -e "${GREEN}1. 700 - OWNER ONLY${RESET}"
    echo -e "${GREEN}2. 755 - OWNER WRITE, ALL EXECUTE${RESET}"
    echo -e "${WHITE}3. BACK${RESET}"
    echo
    read -r -p "SELECT PERMISSION: " perm
    case "$perm" in
        1) mode="700" ;;
        2) mode="755" ;;
        3) return ;;
        *) echo -e "${RED}INVALID PERMISSION!${RESET}"; return ;;
    esac
    if su -c "chmod $mode $(quote_path "$SELECTED")"; then
        echo -e "${GREEN}PERMISSION CHANGED: $mode${RESET}"
    else
        echo -e "${RED}PERMISSION CHANGE FAILED!${RESET}"
    fi
}

delete_file() {
    echo
    echo -e "${RED}SELECTED FILE: ${SELECTED##*/}${RESET}"
    read -r -p "TYPE DELETE TO CONFIRM: " confirm
    if [ "$confirm" = "DELETE" ]; then
        if su -c "rm -f $(quote_path "$SELECTED")"; then
            echo -e "${GREEN}FILE DELETED SUCCESSFULLY!${RESET}"
            SELECTED=""
        else
            echo -e "${RED}DELETE FAILED!${RESET}"
        fi
    else
        echo -e "${YELLOW}DELETE CANCELLED!${RESET}"
    fi
}

download_repo_script() {
    local kind="$1" api="$2" raw="$3" list_temp="$4" temp_file="$5"
    local -n names_ref="$6"
    local label="$7"

    banner
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    printf "${YELLOW}║ %-34s ║${RESET}\n" "$label"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"

    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}CURL NOT FOUND! Install: pkg install curl -y${RESET}"
        pause
        return
    fi

    echo -e "${CYAN}FETCHING FILE LIST FROM GITHUB...${RESET}"
    rm -f "$list_temp"
    if ! curl -fsSL --retry 2 -H "Accept: application/vnd.github+json" "$api" -o "$list_temp"; then
        echo -e "${RED}COULD NOT FETCH FILE LIST!${RESET}"
        rm -f "$list_temp"
        pause
        return
    fi

    mapfile -t names_ref < <(grep -oE '"name"[[:space:]]*:[[:space:]]*"[^"]+\.sh"' "$list_temp" | sed -E 's/.*"([^"]+)"$/\1/' | sort)
    rm -f "$list_temp"

    if [ "${#names_ref[@]}" -eq 0 ]; then
        echo -e "${RED}NO $kind FILES FOUND!${RESET}"
        pause
        return
    fi

    echo
    for i in "${!names_ref[@]}"; do
        printf "${YELLOW}[%02d]${RESET} ${WHITE}%s${RESET}\n" "$((i+1))" "${names_ref[$i]}"
    done
    echo
    printf "TOTAL %s FILES: %s\n" "$kind" "${#names_ref[@]}"
    read -r -p "SELECT $kind NUMBER: " chosen
    if ! [[ "$chosen" =~ ^[0-9]+$ ]] || [ "$chosen" -lt 1 ] || [ "$chosen" -gt "${#names_ref[@]}" ]; then
        echo -e "${RED}INVALID SELECTION!${RESET}"
        pause
        return
    fi

    local filename="${names_ref[$((chosen-1))]}"
    local dest="$TMP_DIR/$filename"
    local encoded="${filename//%/%25}"
    encoded="${encoded// /%20}"
    encoded="${encoded//+/%2B}"
    encoded="${encoded//(/%28}"
    encoded="${encoded//)/%29}"
    encoded="${encoded//#/%23}"

    echo
    echo -e "${YELLOW}SELECTED: $filename${RESET}"
    echo -e "${CYAN}DESTINATION: $dest${RESET}"
    if su -c "test -e $(quote_path "$dest")"; then
        read -r -p "Already exists. Type YES to overwrite: " overwrite
        [ "$overwrite" = "YES" ] || { echo "Download cancelled."; pause; return; }
    fi

    rm -f "$temp_file"
    if ! curl -fL --retry 2 "$raw/$encoded" -o "$temp_file" || [ ! -s "$temp_file" ]; then
        echo -e "${RED}DOWNLOAD FAILED OR EMPTY FILE!${RESET}"
        rm -f "$temp_file"
        pause
        return
    fi

    echo
    echo -e "${YELLOW}Review downloaded script before executing it.${RESET}"
    if su -c "mkdir -p $(quote_path "$TMP_DIR") && cp $(quote_path "$temp_file") $(quote_path "$dest") && chmod 700 $(quote_path "$dest")"; then
        echo -e "${GREEN}$kind DOWNLOAD SUCCESS!${RESET}"
        echo "FILE: $filename"
        echo "LOCATION: $dest"
        echo "PERMISSION: 700"
    else
        echo -e "${RED}INSTALLATION FAILED!${RESET}"
    fi
    rm -f "$temp_file"
    pause
}

panel_download() {
    download_repo_script "PANEL" "$PANEL_API" "$PANEL_RAW" "$PANEL_LIST_TEMP" "$PANEL_TEMP" PANEL_FILES "PANEL DOWNLOADER"
}

driver_download() {
    download_repo_script "DRIVER" "$DRIVER_API" "$DRIVER_RAW" "$DRIVER_LIST_TEMP" "$DRIVER_TEMP" DRIVER_FILES "DRIVER DOWNLOAD"
}

file_control() {
    while [ -n "$SELECTED" ]; do
        if ! su -c "test -f $(quote_path "$SELECTED")"; then
            echo -e "${RED}FILE NOT FOUND!${RESET}"
            SELECTED=""
            break
        fi
        file_control_style
        read -r -p "SELECT ACTION: " action
        case "$action" in
            1) execute_file ;;
            2) permission_menu ;;
            3) view_file ;;
            4) delete_file ;;
            5) SELECTED="" ;;
            *) echo -e "${RED}INVALID OPTION!${RESET}" ;;
        esac
    done
}


check_for_updates() {
    banner
    echo -e "${CYAN}CHECKING ONLINE UPDATES...${RESET}"

    if [[ "$GITHUB_OWNER" == "YOUR_GITHUB_USERNAME" || "$GITHUB_REPO" == "YOUR_EXISTING_REPOSITORY" ]]; then
        echo -e "${RED}GITHUB SETTINGS ARE NOT CONFIGURED.${RESET}"
        echo "Set GITHUB_OWNER and GITHUB_REPO near the top of this script."
        pause
        return
    fi
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}CURL NOT FOUND. RUN: pkg install curl -y${RESET}"
        pause
        return
    fi

    local base="https://raw.githubusercontent.com/$GITHUB_OWNER/$GITHUB_REPO/$GITHUB_BRANCH"
    local version_tmp script_tmp dest backup remote_version embedded_version
    version_tmp="$(mktemp)" || return
    script_tmp="$(mktemp)" || { rm -f "$version_tmp"; return; }
    dest="${PREFIX:-/data/data/com.termux/files/usr}/bin/danish-army-manager"
    backup="$dest.backup"

    if ! curl -fsSL --retry 2 "$base/VERSION" -o "$version_tmp"; then
        echo -e "${RED}COULD NOT READ VERSION FROM GITHUB.${RESET}"
        rm -f "$version_tmp" "$script_tmp"; pause; return
    fi
    remote_version="$(tr -d '[:space:]' < "$version_tmp")"
    if ! [[ "$remote_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}INVALID VERSION FILE ON GITHUB.${RESET}"
        rm -f "$version_tmp" "$script_tmp"; pause; return
    fi

    echo -e "${WHITE}INSTALLED VERSION: $APP_VERSION${RESET}"
    echo -e "${WHITE}ONLINE VERSION:    $remote_version${RESET}"

    local -a current_parts remote_parts
    IFS=. read -r -a current_parts <<< "$APP_VERSION"
    IFS=. read -r -a remote_parts <<< "$remote_version"
    local newer=0 i current online
    for i in 0 1 2; do
        current="${current_parts[$i]:-0}"
        online="${remote_parts[$i]:-0}"
        if (( 10#$online > 10#$current )); then newer=1; break
        elif (( 10#$online < 10#$current )); then break
        fi
    done
    if [[ "$newer" -eq 0 ]]; then
        echo -e "${GREEN}YOU ARE USING THE LATEST VERSION.${RESET}"
        rm -f "$version_tmp" "$script_tmp"; pause; return
    fi

    echo -e "${YELLOW}NEW VERSION FOUND: $remote_version${RESET}"
    if ! curl -fsSL --retry 2 "$base/danish-army-manager.sh" -o "$script_tmp" ||
       [[ ! -s "$script_tmp" ]] || ! bash -n "$script_tmp"; then
        echo -e "${RED}DOWNLOAD OR SHELL CHECK FAILED. NO CHANGES MADE.${RESET}"
        rm -f "$version_tmp" "$script_tmp"; pause; return
    fi

    embedded_version="$(sed -n 's/^APP_VERSION="\([0-9.]*\)"$/\1/p' "$script_tmp" | head -n 1)"
    if [[ "$embedded_version" != "$remote_version" ]]; then
        echo -e "${RED}VERSION DOES NOT MATCH THE DOWNLOADED SCRIPT. UPDATE CANCELLED.${RESET}"
        rm -f "$version_tmp" "$script_tmp"; pause; return
    fi
    if [[ ! -f "$dest" ]]; then
        echo -e "${RED}INSTALLED MANAGER NOT FOUND: $dest${RESET}"
        rm -f "$version_tmp" "$script_tmp"; pause; return
    fi
    if ! cp -p "$dest" "$backup"; then
        echo -e "${RED}BACKUP FAILED. UPDATE CANCELLED.${RESET}"
        rm -f "$version_tmp" "$script_tmp"; pause; return
    fi
    if install -m 700 "$script_tmp" "$dest"; then
        rm -f "$backup"
        echo -e "${GREEN}UPDATE INSTALLED SUCCESSFULLY.${RESET}"
        echo -e "${CYAN}CLOSE AND REOPEN THE TOOL TO USE VERSION $remote_version.${RESET}"
    else
        mv -f "$backup" "$dest"
        echo -e "${RED}UPDATE FAILED. PREVIOUS VERSION RESTORED.${RESET}"
    fi
    rm -f "$version_tmp" "$script_tmp"
    pause
}

main_menu() {
    while true; do
        banner
        main_menu_style
        read -r -p "SELECT OPTION: " option
        case "$option" in
            1) banner; show_files; pause ;;
            2) if select_file; then file_control; fi; pause ;;
            3) refresh_files; echo -e "${GREEN}FILE LIST REFRESHED!${RESET}"; pause ;;
            4) open_channel; pause ;;
            5) panel_download ;;
            6) driver_download ;;
            7) echo -e "${YELLOW}DANISH ARMY TMP MANAGER CLOSED!${RESET}"; exit 0 ;;
            8) check_for_updates ;;
            *) echo -e "${RED}INVALID OPTION!${RESET}"; pause ;;
        esac
    done
}

channel_gate
root_check
main_menu
