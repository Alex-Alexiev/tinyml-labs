#!/usr/bin/env bash
set -euo pipefail

server_dir="$(cd "$(dirname "$0")" && pwd)"
pid_file="$server_dir/jupyter.pid"

if [[ ! -f "$pid_file" ]]; then
  echo "No JupyterLab PID file found."
  exit 0
fi

pid="$(<"$pid_file")"
if kill -0 "$pid" 2>/dev/null; then
  kill "$pid"
  echo "Stopped JupyterLab (PID $pid)."
else
  echo "JupyterLab was not running."
fi
rm -f "$pid_file"
