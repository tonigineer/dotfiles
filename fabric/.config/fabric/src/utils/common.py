import shutil
import time
from functools import lru_cache


def ttl_lru_cache(seconds_to_live: int, maxsize: int = 128):
    def wrapper(func):
        @lru_cache(maxsize)
        def inner(__ttl, *args, **kwargs):
            return func(*args, **kwargs)

        return lambda *args, **kwargs: inner(
            time.time() // seconds_to_live, *args, **kwargs
        )
    return wrapper


@ttl_lru_cache(600, 10)
def executable_exists(executable_name):
    executable_path = shutil.which(executable_name)
    return bool(executable_path)
