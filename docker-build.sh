#!/usr/bin/env bash
# Runs INSIDE the devkitpro/devkita64 container (started by build.bat / build.sh).
# Builds a self-contained .nro: the patched Butterscotch runner with your game's files bundled in romfs.
set -euo pipefail

BUTTERSCOTCH_REPO="https://github.com/ButterscotchRunner/Butterscotch.git"
BUTTERSCOTCH_COMMIT="0a36f376270087a229bf268591582af4760607fe"   # the commit the patch was made and tested against

KIT=/work
SRC=/tmp/butterscotch
OUT="$KIT/out"
G="$KIT/game"

say() { printf '\n==> %s\n' "$*"; }
die() { printf '\nERROR: %s\n' "$*" >&2; exit 1; }

# --- Settings ----------------------------------------------------------------
TITLE="My Game"; AUTHOR="Unknown"; VERSION="1.0.0"; FOLDER="MyGame"; EXACT_POINTS="no"
if [ -f "$KIT/settings.txt" ]; then
  while IFS='=' read -r key value; do
    key="$(echo "$key" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    value="$(echo "$value" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    case "$key" in
      TITLE) TITLE="$value" ;;
      AUTHOR) AUTHOR="$value" ;;
      VERSION) VERSION="$value" ;;
      FOLDER) FOLDER="$value" ;;
      EXACT_POINTS) EXACT_POINTS="$value" ;;
    esac
  done < <(grep -v '^[[:space:]]*#' "$KIT/settings.txt" | grep '=' || true)
fi
[[ "$FOLDER" =~ ^[A-Za-z0-9_-]+$ ]] || die "FOLDER in settings.txt may only use letters, numbers, - and _ (got: '$FOLDER')."
case "$(echo "$EXACT_POINTS" | tr 'A-Z' 'a-z')" in
  yes|on|true|1) EXACT=ON ;;
  *) EXACT=OFF ;;
esac
say "Building \"$TITLE\" by $AUTHOR, version $VERSION -> out/$FOLDER.nro (EXACT_POINTS=$EXACT)"

# --- Check the game files ----------------------------------------------------
[ -f "$G/data.win" ] || die "game/data.win is missing. Copy ALL of your game's files (data.win, any .dat/.ogg files and folders) directly into the game folder."

# --- Tools (the devkitPro image normally has these already) -----------------
if ! command -v git >/dev/null || ! command -v ninja >/dev/null; then
  say "Installing git/ninja"
  apt-get update -qq && apt-get install -y -qq --no-install-recommends git ninja-build ca-certificates >/dev/null
fi

# --- Source + patch ----------------------------------------------------------
say "Fetching Butterscotch ($BUTTERSCOTCH_COMMIT)"
rm -rf "$SRC"
git clone -q "$BUTTERSCOTCH_REPO" "$SRC"
git -C "$SRC" checkout -q "$BUTTERSCOTCH_COMMIT"

say "Applying the Switch builder patch"
tr -d '\r' < "$KIT/butterscotch-switch.patch" > /tmp/switch.patch
git -C "$SRC" apply --whitespace=nowarn /tmp/switch.patch

# --- romfs: the game files bundled inside the .nro ----------------------------
# Windows-only files (.exe, .dll) are left out; everything else in game/ is bundled.
say "Bundling game files into romfs"
BUILD="$SRC/build"
mkdir -p "$BUILD/romfs"
( cd "$G" && find . -mindepth 1 -maxdepth 1 ! -iname '*.exe' ! -iname '*.dll' ! -name 'PUT_YOUR_GAME_FILES_HERE.txt' -exec cp -r {} "$BUILD/romfs/" \; )
du -sh "$BUILD/romfs"

ICON_ARG=()
[ -f "$KIT/icon.jpg" ] && ICON_ARG=(-DNX_APP_ICON="$KIT/icon.jpg")

# --- Build -------------------------------------------------------------------
say "Configuring"
cmake -S "$SRC" -B "$BUILD" -G Ninja \
  -DPLATFORM=switch \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
  -DNX_APP_TITLE="$TITLE" \
  -DNX_APP_AUTHOR="$AUTHOR" \
  -DNX_APP_VERSION="$VERSION" \
  -DNX_APP_DIR="sdmc:/switch/$FOLDER" \
  -DBS_EXACT_POINTS="$EXACT" \
  ${ICON_ARG[@]+"${ICON_ARG[@]}"}

say "Compiling (a few minutes)"
cmake --build "$BUILD"

mkdir -p "$OUT"
cp "$BUILD/butterscotch.nro" "$OUT/$FOLDER.nro"
say "Done: out/$FOLDER.nro ($(du -h "$OUT/$FOLDER.nro" | cut -f1))"
echo "Copy it to the SD card as  /switch/$FOLDER/$FOLDER.nro"
