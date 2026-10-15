#!/usr/bin/env bash
# Builds your .nro in the "out" folder using devkitPro's official Docker image (macOS / Linux).
# Needs Docker running. Put your game's files in the "game" folder and edit settings.txt first.
set -e
cd "$(dirname "$0")"
docker version >/dev/null 2>&1 || { echo "Docker isn't running. Install/start Docker, then run this again."; exit 1; }
# --platform keeps Apple Silicon Macs happy (the devkitPro image is x86_64)
docker run --rm --platform linux/amd64 -v "$PWD":/work devkitpro/devkita64:latest \
  bash -c "tr -d '\r' < /work/docker-build.sh > /tmp/build.sh && bash /tmp/build.sh"
echo "Success! Your .nro is in the out folder."
