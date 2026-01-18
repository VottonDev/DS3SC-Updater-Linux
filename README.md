# Dark Souls 3 Seamless Co-op Linux Installer/Updater

This script automates the process of installing and updating the [Dark Souls 3 Seamless Co-op mod](https://www.nexusmods.com/darksouls3/mods/1895) on Linux systems. It simplifies the installation by extracting the mod files, backing up your existing settings, and providing clear launch instructions.

## Features

* **Automatic Zip Detection:** If no path is provided, automatically finds the most recent `DS3 Seamless Co-op*.zip` file in your `~/Downloads` folder.
* **Settings Backup:** Preserves your `ds3sc_settings.ini` file across updates, prompting you if changes are detected.
* **Installation Verification:** Confirms that all essential mod files are in place after extraction.
* **Clear Launch Instructions:** Provides the exact Steam launch options needed to play.

## Prerequisites

Before running the script, ensure you have the following installed:

* `unzip`

This is typically pre-installed on most Linux distributions.

**Note:** Since the mod is hosted on Nexus Mods (which has no public API), you must download the mod zip file manually before running this script.

## How to Use

### 1. Download the Mod

Visit the [Dark Souls 3 Seamless Co-op Nexus page](https://www.nexusmods.com/darksouls3/mods/1895) and download the latest release zip file.

### 2. Download the Script

Save the `ds3sc-update.sh` script to a convenient location on your computer (e.g., `~/Downloads` or `~/Scripts`).

### 3. Make the Script Executable

The script needs executable permissions to run. Choose one of the methods below:

#### Via Terminal

Open your terminal, navigate to the directory where you saved the script, and run:

```bash
chmod +x ./ds3sc-update.sh
```

#### Via Desktop Environment (GUI)

* **Note:** The exact steps and terminology may vary slightly depending on your specific desktop environment (e.g., GNOME, KDE Plasma, XFCE, MATE).

* **Example (GNOME):**
    1. Open your file manager (e.g., "Files").
    2. Navigate to the script's location.
    3. Right-click on `ds3sc-update.sh` and select "Properties" (or "Permissions").
    4. Go to the "Permissions" tab.
    5. Check the box labeled "Allow executing file as a program" or similar.
    6. Click "Close" or "OK".

### 4. Configure the Game Directory

**Important:** Before running the script, you need to edit it to set your Dark Souls III game directory path. Open `ds3sc-update.sh` in a text editor and modify this line:

```bash
readonly GAME_DIR="/run/media/votton/Data/SteamLibrary/steamapps/common/DARK SOULS III/Game"
```

Replace the path with your actual Dark Souls III `Game` directory location. Common paths include:

* Native Steam: `~/.steam/steam/steamapps/common/DARK SOULS III/Game`
* Flatpak Steam: `~/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/common/DARK SOULS III/Game`
* Custom library: `/path/to/your/SteamLibrary/steamapps/common/DARK SOULS III/Game`

### 5. Run the Script

Once configured, you can run the script:

```bash
# Auto-detect zip in ~/Downloads
./ds3sc-update.sh

# Or specify a zip file path directly
./ds3sc-update.sh /path/to/your/downloaded/mod.zip
```

The script will:
1. Find the mod zip file (auto-detect or use provided path)
2. Verify your Dark Souls III installation
3. Back up your existing settings (if any)
4. Extract the mod files
5. Restore your settings
6. Display launch instructions

## How to Play

After installation, you need to configure Steam to launch the mod:

1. **Set your co-op password** in `SeamlessCoop/ds3sc_settings.ini` (located in your game directory)

2. **Add Steam launch options:**
   - Right-click Dark Souls III in Steam → Properties → Launch Options
   - Add this command:
   ```
   cmd=(%command%); cmd[-1]=ds3sc_launcher.exe; "${cmd[@]}"
   ```

3. **Launch Dark Souls III** via Steam as normal!

## Disabling the Mod

To disable the mod and play vanilla Dark Souls III:

* Simply remove the launch options you added in Steam (right-click Dark Souls III → Properties → Launch Options → delete the command).

## Troubleshooting

### 1. Script not running or "Permission denied"

* **Issue:** When you try to run the script, you get an error like "Permission denied."
* **Solution:** You likely forgot to make the script executable. Follow the steps in the "Make the Script Executable" section above using `chmod +x`.

### 2. "command not found" error for `unzip`

* **Issue:** The script exits with an error indicating `unzip` is not found.
* **Solution:** Install unzip using your package manager:
    * **Debian/Ubuntu:** `sudo apt install unzip`
    * **Fedora:** `sudo dnf install unzip`
    * **Arch Linux:** `sudo pacman -S unzip`

### 3. "Dark Souls III 'Game' directory not found"

* **Issue:** The script cannot locate your Dark Souls III installation.
* **Solution:**
    * Ensure Dark Souls III is installed via Steam.
    * Edit the `GAME_DIR` variable in the script to match your actual installation path (see step 4 above).

### 4. "Could not find a 'DS3 Seamless Co-op*.zip' file"

* **Issue:** The script cannot find the mod zip in your Downloads folder.
* **Solution:**
    * Make sure you've downloaded the mod from [Nexus Mods](https://www.nexusmods.com/darksouls3/mods/1895).
    * Ensure the zip file name starts with "DS3 Seamless Co-op" and is in your `~/Downloads` folder.
    * Alternatively, provide the full path to the zip file as an argument: `./ds3sc-update.sh /path/to/mod.zip`

### 5. Game not launching with mod

* **Issue:** The game launches vanilla instead of the modded version.
* **Solution:**
    * Double-check that the Steam launch options are set correctly.
    * Verify that `ds3sc_launcher.exe` exists in your game directory.
    * Ensure you're launching the game through Steam.

### 6. "This script cannot be run as root"

* **Issue:** You get an error about running as root.
* **Solution:** Run the script as your normal user, not with `sudo`.

## Credits

* **Mod:** [Dark Souls 3 Seamless Co-op](https://www.nexusmods.com/darksouls3/mods/1895) on Nexus Mods
* **Script:** Based on the [Elden Ring Seamless Co-op Updater](https://github.com/youp211/ERSC-Updater-Linux/) by youp211
