#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# Description:
#   This script mirrors the current FFT project (parallel_fft/parallel_fft) into
#   the shared folder used by the Docker/X11 IC design tools environment. It
#   excludes common build artifacts, simulation dumps, and (optionally) LibreLane
#   run directories so you don’t copy heavy generated data every time.
#   After syncing, it starts the Docker tool environment by running `make start`
#   in the uniccass-icdesign-tools repository.
#
# Project layout assumed (relative to PROJECT_SRC):
#   design/           RTL, models
#   verification/     testbenches
#   docs/             diagrams
#   librelane/        LibreLane config + scripts (your PD study folder)
#
# Usage:
#   ./sync_and_start.sh
#
# Optional environment overrides:
#   PROJECT_SRC=/path/to/parallel_fft/parallel_fft \
#   TOOLS_DIR=/path/to/uniccass-icdesign-tools \
#   SHARED_DIR=/path/to/shared_xserver \
#   DEST_DIR=/path/to/shared_xserver/FFT/parallel_fft \
#   ./sync_and_start.sh
# ------------------------------------------------------------------------------

# ==== CONFIG (adjust if your paths differ) ====
# Host path to your repository root (the folder that contains design/, docs/, librelane/, etc.)
PROJECT_SRC="${PROJECT_SRC:-$HOME/Escritorio/parallel_fft/parallel_fft}"

# Path to the toolchain repo that provides the Docker environment (contains Makefile with `start`)
TOOLS_DIR="${TOOLS_DIR:-$HOME/uniccass-icdesign-tools}"

# Shared directory (usually bind-mounted into the container for file exchange)
SHARED_DIR="${SHARED_DIR:-$TOOLS_DIR/shared_xserver}"

# Destination where the project will be mirrored inside the shared folder
DEST_DIR="${DEST_DIR:-$SHARED_DIR/FFT/parallel_fft}"

# ==== CHECKS ====
if [[ ! -d "$PROJECT_SRC" ]]; then
  echo "ERROR: PROJECT_SRC does not exist: $PROJECT_SRC"
  echo "Fix PROJECT_SRC or move the project to that path."
  exit 1
fi

# Basic sanity check: ensure this looks like the right repo
if [[ ! -d "$PROJECT_SRC/design" || ! -d "$PROJECT_SRC/librelane" ]]; then
  echo "ERROR: PROJECT_SRC does not look like the expected repo layout."
  echo "Expected to find: $PROJECT_SRC/design and $PROJECT_SRC/librelane"
  exit 1
fi

if [[ ! -d "$TOOLS_DIR" ]]; then
  echo "ERROR: TOOLS_DIR does not exist: $TOOLS_DIR"
  echo "Fix TOOLS_DIR (it should point to uniccass-icdesign-tools)."
  exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
  echo "ERROR: rsync is not installed. Install it with:"
  echo "  sudo apt-get update && sudo apt-get install -y rsync"
  exit 1
fi

# ==== SYNC ====
echo "==> Syncing project into shared directory..."
mkdir -p "$DEST_DIR"

# Mirror PROJECT_SRC into DEST_DIR:
#   -a        : archive mode (recursive, preserve perms/timestamps, etc.)
#   --delete  : delete files in DEST that no longer exist in SRC
#   --exclude : skip heavy/temporary artifacts (build outputs, waves, etc.)
#
# Notes:
# - We exclude LibreLane `runs/` to avoid copying large generated runs. If you
#   want runs synced too, remove that exclude.
# - We also exclude typical simulator outputs (*.vcd, *.vvp) and Python caches.
rsync -a --delete \
  --exclude 'build/' \
  --exclude 'runs/' \
  --exclude 'librelane/runs/' \
  --exclude '*.vcd' \
  --exclude '*.vvp' \
  --exclude '__pycache__/' \
  --exclude '.pytest_cache/' \
  --exclude '.ipynb_checkpoints/' \
  "$PROJECT_SRC"/ "$DEST_DIR"/

echo "==> Done. Project is now at: $DEST_DIR"
echo "==> Starting Docker environment (make start)..."

# ==== RUN DOCKER ====
cd "$TOOLS_DIR"
make start
