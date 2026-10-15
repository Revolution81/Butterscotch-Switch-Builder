# Butterscotch Switch Builder (unofficial)

Turn a GameMaker: Studio game you own into a single homebrew `.nro` file for a modded Nintendo Switch.

This is an **unofficial fork/add-on** for [Butterscotch](https://github.com/ButterscotchRunner/Butterscotch), the open-source re-implementation of GameMaker: Studio's runner. It is **not made, endorsed or supported by the Butterscotch team.** All the hard work of running GameMaker games belongs to them. This kit adds:

- **A one-click builder** (Docker) that packs the Butterscotch runner *and* your game's files into one `.nro`, with your own title, author, version, icon and save folder.
- **A patch with engine fixes**, mostly for older GameMaker: Studio 1.4 games, plus Switch-specific improvements (faster loading, streamed music, ZL/ZR as buttons, and more). See [CHANGES.md](CHANGES.md).

**No game files are included.** You need your own copy of the game you want to build.

> **Honesty note:** the changes in this kit were made with the help of an AI assistant (Claude, by Anthropic) and tested on a real Switch Lite. It has mainly been tested with one game (see "Tested games"), so other games may hit bugs that were never seen. It is provided as-is.

---

## Tested games

| Game | Status | Settings needed |
|---|---|---|
| **ZALiA** (v1.7.12.01) | Playable on Switch. All 597 rooms load; the first palaces have been played through on a Switch Lite. | `EXACT_POINTS=yes` |

The engine fixes in this kit were made so that **ZALiA runs on Butterscotch**, and they also help other GameMaker: Studio 1.4 games. This kit is **not affiliated with or endorsed by ZALiA's creator**, and it contains no ZALiA files. Use your own copy of the game, from the official ZALiA download.

Example `settings.txt` for ZALiA:

```
TITLE=ZALiA
AUTHOR=HoverBat
VERSION=1.7.12.01
FOLDER=ZALiA
EXACT_POINTS=yes
```

## What you need

- A **Windows, Mac or Linux PC** with about 3 GB of free space
- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** (free; no account needed)
- **Your game's files** (the folder that contains `data.win`)
- A Switch running custom firmware (Atmosphere) with the homebrew menu

## Build your .nro

1. **Install Docker Desktop** and start it. On Windows, say yes if it asks to enable WSL 2, and restart if asked. Wait until Docker says it is running.
2. **Download this repository** (green **Code** button → **Download ZIP**) and unzip it somewhere easy, like your Desktop.
3. **Copy all of your game's files into the `game` folder.** `data.win` must sit directly inside `game` (not in a subfolder). Copy everything next to it too: `.dat`, `.ogg`, other folders and so on. `.exe` and `.dll` files are skipped automatically.
4. **Edit `settings.txt`** in Notepad: set the title, author, version and folder name. Optionally replace `icon.jpg` with your own 256×256 JPEG.
5. **Build:**
   - Windows: double-click **`build.bat`**. If Windows says "Windows protected your PC", click **More info → Run anyway**. The `.bat` file is a short text script you can read in Notepad.
   - Mac/Linux: open a terminal in the folder and run **`./build.sh`**.

   The first build downloads devkitPro's official Switch compiler image (about 1 GB), so it takes a while. Later builds are much faster.
6. When it says **Success**, your file is in the **`out`** folder, named `<FOLDER>.nro`.

## Put it on the Switch

1. Copy the file to your SD card as `SD:/switch/<FOLDER>/<FOLDER>.nro` (for example `SD:/switch/MyGame/MyGame.nro`).
2. Open the homebrew menu by **holding R while launching any installed game** (title override). **Don't use the Album button**: album mode gives homebrew much less memory and big games may not run.
3. Pick your game and press A. Press HOME to quit.

**Saves** go to `SD:/switch/<FOLDER>/`. To bring a save over from Windows, copy the game's save files from `%LOCALAPPDATA%\<game name>\` into that folder.

**Updating:** when a new version of this kit comes out, build again and copy the new `.nro` over the old one. Your saves are kept, because they're stored in the folder, not in the `.nro`.

## If something goes wrong

| Problem | What to do |
|---|---|
| "Docker isn't running" | Start Docker Desktop, wait for it to say it's running, and try again. |
| "game/data.win is missing" | The game files must sit directly inside `game` (not `game/SomeFolder/data.win`). |
| Colours look completely wrong (for example everything red and blue) | Set `EXACT_POINTS=yes` in `settings.txt` and build again. Some GameMaker: Studio 1.4 games build their colour palette pixel by pixel and need this. |
| Black screen, crash or stuck loading | Make sure you launched with **hold R** (title override), not the Album button. |
| It's slow | Butterscotch interprets the game's code, so heavy scenes can be slow at stock clocks. An overclock module such as sys-clk helps. |
| Anything else | The game may use something Butterscotch doesn't support yet. Check the [Butterscotch compatibility list](https://github.com/ButterscotchRunner/Butterscotch). This kit can't promise every game works. |

## Rules for sharing

- **Only build games you own.** A finished `.nro` contains the whole game, so **don't upload or share `.nro` files.** Share this kit instead, and let people build from their own copy.
- Please don't report problems with this kit to the Butterscotch developers; it's an unofficial add-on.

## How it works (for the curious)

`docker-build.sh` runs inside devkitPro's official `devkitpro/devkita64` image. It:

1. downloads Butterscotch at a fixed commit (`0a36f37`);
2. applies `butterscotch-switch.patch`;
3. copies your game files into the `.nro`'s built-in file system (romfs);
4. builds with your settings.

Nothing is installed on your PC apart from Docker.

## License

Butterscotch is licensed under the **GNU Affero General Public License v3.0**. The patch and scripts in this repository are released under the same license (see [LICENSE](LICENSE)). The full source of every change is the patch file in this repository, applied to the Butterscotch commit named above.

Game files you put in the `game` folder belong to their creators and are **not** covered by this license.
