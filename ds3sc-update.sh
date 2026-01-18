#!/bin/bash

# ==============================================================================
# Dark Souls 3 Seamless Co-op Installer/Updater for Linux
#
# Description:
# This script automates installing/updating the "Dark Souls 3 Seamless Co-op" mod
# on Linux. Since the mod is hosted on Nexus Mods (no public API), you must
# download the zip file manually and provide it to this script.
#
# Usage:
#   ./ds3sc-update.sh [path-to-zip-file]
#
# If no zip path is provided, it will look in ~/Downloads for a file matching
# "DS3 Seamless Co-op*.zip"
#
# Mod: https://www.nexusmods.com/darksouls3/mods/1895
# Based on: Elden Ring Seamless Co-op Updater by youp211
# ==============================================================================

# --- Script Configuration ---

set -e
set -u
set -o pipefail

# --- Global Variables ---
readonly GAME_DIR="/run/media/votton/Data/SteamLibrary/steamapps/common/DARK SOULS III/Game"
readonly DOWNLOADS_DIR="$HOME/Downloads"

# --- Helper Functions ---

log_info() {
    echo -e "\n[INFO] $1" >&2
}

log_success() {
    echo -e "\n[✓] $1" >&2
}

die() {
    echo -e "\n[ERROR] $1" >&2
    echo "[FATAL] Script aborted." >&2
    exit 1
}

# --- Core Functions ---

check_not_root() {
    if [[ "$EUID" -eq 0 ]]; then
        die "This script cannot be run as root. Please run it as your normal user."
    fi
}

find_mod_zip() {
    local provided_path="${1:-}"

    # If a path was provided as an argument, use it
    if [[ -n "$provided_path" ]]; then
        if [[ -f "$provided_path" ]]; then
            echo "$provided_path"
            return
        else
            die "Provided zip file not found: $provided_path"
        fi
    fi

    # Otherwise, search in Downloads folder
    log_info "No zip path provided. Searching in $DOWNLOADS_DIR..."

    local found_zip
    found_zip=$(find "$DOWNLOADS_DIR" -maxdepth 1 -name "DS3 Seamless Co-op*.zip" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)

    if [[ -n "$found_zip" && -f "$found_zip" ]]; then
        echo "$found_zip"
        log_info "Found mod zip: $found_zip"
    else
        die "Could not find a 'DS3 Seamless Co-op*.zip' file in $DOWNLOADS_DIR. Please download the mod from https://www.nexusmods.com/darksouls3/mods/1895 or provide the path as an argument."
    fi
}

verify_game_directory() {
    log_info "Verifying Dark Souls III installation directory..."

    if [[ ! -d "$GAME_DIR" ]]; then
        die "Dark Souls III 'Game' directory not found at: $GAME_DIR"
    fi

    # Check for the game executable to confirm it's the right directory
    if [[ ! -f "$GAME_DIR/DarkSoulsIII.exe" ]]; then
        die "DarkSoulsIII.exe not found in $GAME_DIR. Is this the correct game directory?"
    fi

    log_info "Game directory verified: $GAME_DIR"
}

manage_settings_backup() {
    log_info "Checking for existing mod settings..."
    local settings_file="SeamlessCoop/ds3sc_settings.ini"
    local backup_file="ds3sc_settings.ini.backup"

    # If there's no current settings file, there's nothing to back up.
    if [[ ! -f "$settings_file" ]]; then
        log_info "No existing '$settings_file' found to back up. Skipping."
        return
    fi

    # If a backup doesn't exist, create one from the current settings.
    if [[ ! -f "$backup_file" ]]; then
        log_info "Creating initial backup of '$settings_file'..."
        cp -v "$settings_file" "$backup_file" || die "Failed to create initial settings backup."
        return
    fi

    # If a backup exists, compare it with the current settings.
    if ! diff -q "$backup_file" "$settings_file" >/dev/null; then
        echo
        echo "Your current settings file is different from your backup."
        echo
        echo "--- Differences (Backup vs. Current) ---"
        diff -y --suppress-common-lines "$backup_file" "$settings_file" || true
        echo "----------------------------------------"
        echo

        while true; do
            read -p "Do you want to replace your backup with your current settings? (y/n) " yn
            case "$yn" in
                [Yy]*)
                    log_info "Updating settings backup..."
                    cp -v "$settings_file" "$backup_file" || die "Failed to update settings backup."
                    break
                    ;;
                [Nn]*)
                    log_info "Keeping existing backup. The current settings file will be overwritten by the new download."
                    break
                    ;;
                *)
                    echo "Please answer yes (y) or no (n)."
                    ;;
            esac
        done
    else
        log_info "Current settings match the backup. No action needed."
    fi
}

install_mod_files() {
    local zip_path="$1"
    log_info "Extracting mod files from '$zip_path'..."
    unzip -o "$zip_path" || die "Failed to extract mod files from zip archive."
    log_info "Extraction complete."
}

verify_mod_files() {
    log_info "Verifying mod installation..."
    
    if [[ ! -f "ds3sc_launcher.exe" ]]; then
        die "Mod launcher 'ds3sc_launcher.exe' not found. Installation may have failed."
    fi
    
    if [[ ! -f "SeamlessCoop/ds3sc.dll" ]]; then
        die "Mod DLL 'SeamlessCoop/ds3sc.dll' not found. Installation may have failed."
    fi
    
    log_success "Mod files installed successfully."
}

restore_settings() {
    log_info "Restoring settings..."
    local settings_file="SeamlessCoop/ds3sc_settings.ini"
    local backup_file="ds3sc_settings.ini.backup"

    if [[ -f "$backup_file" ]]; then
        log_info "Restoring settings from '$backup_file'..."
        cp -v "$backup_file" "$settings_file" || die "Failed to restore settings."
    else
        log_info "No settings backup found to restore. The default mod settings will be used."
    fi
}

show_launch_instructions() {
    echo
    echo "╔════════════════════════════════════════════════════════════════════════╗"
    echo "║                           HOW TO PLAY                                  ║"
    echo "╠════════════════════════════════════════════════════════════════════════╣"
    echo "║  1. Edit your co-op password in:                                       ║"
    echo "║     SeamlessCoop/ds3sc_settings.ini                                    ║"
    echo "║                                                                        ║"
    echo "║  2. In Steam, right-click Dark Souls III → Properties → Launch Options ║"
    echo "║     Add this command:                                                  ║"
    echo "║                                                                        ║"
    echo "║     cmd=(%command%); cmd[-1]=ds3sc_launcher.exe; \"\${cmd[@]}\"           ║"
    echo "║                                                                        ║"
    echo "║  3. Launch Dark Souls III via Steam as normal!                         ║"
    echo "╚════════════════════════════════════════════════════════════════════════╝"
    echo
    echo "Game directory: $GAME_DIR"
    echo
    echo "To disable the mod: Remove the launch options in Steam."
    echo
}

# --- Main Execution ---

main() {
    echo
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║   Dark Souls 3 Seamless Co-op Installer/Updater - Linux  ║"
    echo "╚═══════════════════════════════════════════════════════════╝"

    check_not_root

    # Find the mod zip file
    local zip_path
    zip_path=$(find_mod_zip "${1:-}")

    verify_game_directory

    # Change to the game directory
    cd "$GAME_DIR" || die "Could not change to game directory: $GAME_DIR"
    log_info "Operating in game directory: $(pwd)"

    # Back up settings BEFORE unzipping (unzip will overwrite them)
    manage_settings_backup

    install_mod_files "$zip_path"

    verify_mod_files

    # Restore settings AFTER the new mod files are in place
    restore_settings

    echo
    log_success "Installation complete!"

    show_launch_instructions
}

main "$@"
