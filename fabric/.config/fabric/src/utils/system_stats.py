from __future__ import annotations

import platform
import subprocess
from datetime import datetime, timedelta
from time import sleep
from typing import Optional

import psutil
from fabric import Fabricator

from src.utils.config import Config


def uptime_hm() -> str:
    """Return system uptime in HH:MM."""
    elapsed = timedelta(seconds=int(datetime.now().timestamp() - psutil.boot_time()))
    hours, minutes = divmod(elapsed.seconds // 60, 60)
    return f"{hours:02}:{minutes:02}"


def find_process(name: str) -> Optional[psutil.Process]:
    """First process whose .name() matches *name* (case-sensitive)."""
    for p in psutil.process_iter(["name"]):
        if p.info["name"] == name:
            return p
    return None

def get_gpu_stats() -> tuple[int | None, int | None]:
    """Return (usage %, temp °C) for NVIDIA via nvidia-smi, or (None, None)."""
    try:
        out = subprocess.check_output(
            ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu",
             "--format=csv,noheader,nounits"],
            text=True,
            timeout=1.0,
        ).strip()
        usage, temp = (int(x) for x in out.split(","))
        return usage, temp
    except Exception:
        return None, None


def stats_poll(fabricator):
    tracked: Optional[psutil.Process] = None
    # psutil.cpu_percent(None)  # prime CPU counters

    while True:
        if tracked is None or not tracked.is_running():
            tracked = find_process(Config.application_name)

        app_cpu = app_mem = ""
        if tracked:
            app_cpu = f"{tracked.cpu_percent(interval=0.0):.1f}"
            app_mem = f"{tracked.memory_info().rss / 2 ** 20:.0f}"

        gpu_usage, gpu_temp = get_gpu_stats()

        yield {
            "cpu_usage": round(psutil.cpu_percent(), 1),
            "cpu_freq": psutil.cpu_freq(),
            "cpu_temp": psutil.sensors_temperatures()['nvme'][0].current,
            "ram_usage": round(psutil.virtual_memory().percent, 1),
            "ram_free": round(psutil.virtual_memory().free / (1024 ** 3), 1),
            "gpu_usage": gpu_usage,
            "gpu_temp": gpu_temp,
            "disk": psutil.disk_usage('/').percent,
            "disk_home": psutil.disk_usage(f"/home/{Config.General.username}").percent,
            "disk_swap": psutil.swap_memory().percent,
            "uptime": uptime_hm(),
            "datetime": datetime.now().strftime("%d.%m.%Y  %H:%M"),
            "app_memory": app_mem,
            "app_cpu": app_cpu,
            "kernel": platform.uname().release
        }
        sleep(1)

util_fabricator = Fabricator(poll_from=stats_poll, stream=True)
