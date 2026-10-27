#!/usr/bin/env bash
set -euo pipefail

server_dir="$(cd "$(dirname "$0")" && pwd)"
workspace="$(cd "$server_dir/.." && pwd)"
venv="/home/aalexiev/Documents/Codex/2026-10-01/can-x20/work/jupyter-runtime-venv"

mkdir -p "$server_dir/runtime" "$server_dir/ipython"
chmod 700 "$server_dir" "$server_dir/runtime" "$server_dir/ipython"
chmod 600 "$server_dir/token"
export JUPYTER_RUNTIME_DIR="$server_dir/runtime"
export IPYTHONDIR="$server_dir/ipython"

cd "$workspace"
exec "$venv/bin/jupyter" lab --config="$server_dir/jupyter_server_config.py"
