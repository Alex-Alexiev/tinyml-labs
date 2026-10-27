import os
from pathlib import Path

server_dir = Path(__file__).resolve().parent
workspace = server_dir.parent

c = get_config()  # noqa: F821 - supplied by Jupyter's config loader
c.ServerApp.ip = "10.80.5.207"
c.ServerApp.port = 8890
c.ServerApp.port_retries = 50
c.ServerApp.open_browser = False
c.ServerApp.allow_remote_access = True
c.ServerApp.root_dir = str(workspace)
c.ServerApp.cookie_secret_file = str(server_dir / "cookie_secret")
c.IdentityProvider.token = (server_dir / "token").read_text().strip()

# Use this lab's kernel names instead of the shared server environment's labels.
os.environ["JUPYTER_PATH"] = str(server_dir) + os.pathsep + os.environ.get("JUPYTER_PATH", "")
c.KernelSpecManager.allowed_kernelspecs = {"python3"}
