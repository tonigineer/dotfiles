from datetime import datetime
from time import sleep

import psutil
from fabric import Fabricator


def uptime():
    boot_time = psutil.boot_time()
    now = datetime.now()

    diff = now.timestamp() - boot_time

    # Convert the difference in seconds to hours and minutes
    hours, remainder = divmod(diff, 3600)
    minutes, _ = divmod(remainder, 60)

    return f"{int(hours):02}:{int(minutes):02}"


# Function to get the system stats using psutil
def stats_poll(fabricator):
    # storage_config = widget_config["storage"]
    while True:
        yield {
            "cpu_usage": round(psutil.cpu_percent(), 1),
            "cpu_freq": psutil.cpu_freq(),
            "temperature": psutil.sensors_temperatures(),
            "ram_usage": round(psutil.virtual_memory().percent, 1),
            "memory": psutil.virtual_memory(),
            "disk": psutil.disk_usage('/'),
            "uptime": uptime(),
        }
        sleep(1)

util_fabricator = Fabricator(poll_from=stats_poll, stream=True)
