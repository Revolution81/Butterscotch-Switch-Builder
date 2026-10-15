@echo off
rem Builds your .nro in the "out" folder using devkitPro's official Docker image.
rem Needs Docker Desktop running. Put your game's files in the "game" folder and edit settings.txt first.
cd /d "%~dp0"
docker version >nul 2>&1
if errorlevel 1 (
  echo Docker isn't running. Install Docker Desktop from https://www.docker.com/products/docker-desktop/ , start it, then run this again.
  pause
  exit /b 1
)
docker run --rm -v "%cd%":/work devkitpro/devkita64:latest bash -c "tr -d '\r' < /work/docker-build.sh > /tmp/build.sh && bash /tmp/build.sh"
if errorlevel 1 (
  echo.
  echo Build failed - see the messages above.
) else (
  echo.
  echo Success! Your .nro is in the "out" folder.
)
pause
