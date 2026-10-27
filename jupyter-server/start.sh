#!/usr/bin/env bash
set -euo pipefail

server_dir="$(cd "$(dirname "$0")" && pwd)"
workspace="$(cd "$server_dir/.." && pwd)"
venv="/home/aalexiev/.conda/envs/tinyml-labs"
export PYTHONNOUSERSITE=1
export PATH="$venv/bin:$PATH"
pid_file="$server_dir/jupyter.pid"
log_file="$server_dir/jupyter.log"

print_url() {
  "$venv/bin/python" - "$server_dir/runtime" "$1" <<'PYTHON'
import json
import os
from pathlib import Path
import sys
import time
from urllib.parse import urlencode, urlsplit, urlunsplit

info_file = Path(sys.argv[1]) / f"jpserver-{sys.argv[2]}.json"
for _ in range(300):
    try:
        os.kill(int(sys.argv[2]), 0)
    except ProcessLookupError:
        sys.exit("JupyterLab exited before becoming ready. Check jupyter.log.")
    try:
        info = json.loads(info_file.read_text())
        parts = urlsplit(info["url"])
        path = parts.path.rstrip("/") + "/lab"
        query = urlencode({"token": info["token"]}) if info.get("token") else ""
        print("Open: " + urlunsplit((parts.scheme, parts.netloc, path, query, "")))
        break
    except (FileNotFoundError, json.JSONDecodeError, KeyError):
        time.sleep(0.1)
else:
    sys.exit("JupyterLab URL is not available yet. Check jupyter.log.")
PYTHON
}

if [[ -f "$pid_file" ]] && kill -0 "$(<"$pid_file")" 2>/dev/null; then
  echo "JupyterLab is already running (PID $(<"$pid_file"))."
  print_url "$(<"$pid_file")"
  exit 0
fi

mkdir -p "$server_dir/runtime"
chmod 700 "$server_dir" "$server_dir/runtime"
chmod 600 "$server_dir/token"
export JUPYTER_RUNTIME_DIR="$server_dir/runtime"
export IPYTHONDIR="$server_dir/ipython"

cd "$workspace"
nohup setsid "$venv/bin/jupyter" lab \
  --config="$server_dir/jupyter_server_config.py" \
  >"$log_file" 2>&1 < /dev/null &
pid=$!
echo "$pid" > "$pid_file"
sleep 2

if ! kill -0 "$pid" 2>/dev/null; then
  echo "JupyterLab failed to start. See $log_file" >&2
  exit 1
fi

print_url "$pid"
echo "JupyterLab started (PID $pid)."
