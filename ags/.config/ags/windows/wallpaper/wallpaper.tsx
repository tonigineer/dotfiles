import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import { Variable, bind, execAsync } from "astal";
import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib";

import Hyprland from "gi://AstalHyprland";

const WINDOW_NAME = "window_wallpaper";

const currentWallpaper = Variable<string>("");
const wallpapers = Variable<{ path: string; isVideo: boolean; resolution: string; size: number, thumbnailPath: string }[]>([]);

const width = THUMBNAIL_WIDTH;
const height = THUMBNAIL_WIDTH * 9 / 16;

async function initCurrentWallpaper() {
    const output = await execAsync(["bash", "-c", "hyprctl hyprpaper listactive"]);
    const line = output.split("\n")[0];
    const wallpaper = line?.split(" = ")[1]?.trim() || "";
    currentWallpaper.set(wallpaper);
}

async function fetchWallpapers() {
    // hyprpaper: 
    // mpvpaper: https://motionbgs.com/
    const output = await execAsync([
        "bash",
        "-c",
        `find ${HOME_DIR}/.config/hypr/backgrounds -type f`
    ]);

    const paths = output.trim().split("\n");
    const thumbDir = `${HOME_DIR}/.cache/ags-thumbnails`;

    await execAsync(["bash", "-c", `mkdir -p "${thumbDir}"`]);

    const result = await Promise.all(paths.map(async (path) => {
        const ext = path.split(".").pop()?.toLowerCase() || "";
        const isVideo = ["mp4", "webm", "mov", "mkv"].includes(ext);

        const sizeOutput = await execAsync(["bash", "-c", `stat -c %s "${path}"`]);
        const size = parseInt(sizeOutput.trim(), 10);

        let resolution: string | null = null;
        if (isVideo) {
            const resolutionOutput = await execAsync([
                "bash",
                "-c",
                `ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "${path}"`
            ]);
            resolution = resolutionOutput.trim();
        } else {
            const resolutionOutput = await execAsync([
                "bash",
                "-c",
                `identify -format "%wx%h" "${path}"`
            ]);
            resolution = resolutionOutput.trim();
        }

        const hash = await execAsync(["bash", "-c", `echo -n "${path}{width}" | md5sum | cut -d' ' -f1`]);
        const thumbPath = `${thumbDir}/${hash.trim()}.jpg`;

        Logger.warn(hash);
        Logger.warn(thumbPath);

        if (!isVideo) {
            await execAsync([
                "bash",
                "-c",
                `[ -f "${thumbPath}" ] || convert "${path}" -resize ${width}x${height}^ -gravity center -extent ${width}x${height} "${thumbPath}"`
            ]);
        } else {
            await execAsync([
                "bash",
                "-c",
                `[ -f "${thumbPath}" ] || ffmpeg -y -i "${path}" -vframes 1 -vf "scale=${width}:${height}:force_original_aspect_ratio=decrease,pad=${width}:${height}:(ow-iw)/2:(oh-ih)/2" "${thumbPath}"`
            ]);
        }

        return {
            path,
            isVideo,
            size,
            resolution,
            thumbnailPath: thumbPath,
        };
    }));

    wallpapers.set(result);
}

// let lastSetWallpaperCall = 0;
async function programIsRunning(name: string): Promise<boolean> {
    try {
        const output = await execAsync(["bash", "-c", `pgrep -x ${name}`]);
        return output.trim().length > 0;
    } catch {
        return false;
    }
}

async function killProgram(name: string): Promise<boolean> {
    try {
        await execAsync(["bash", "-c", `pkill -x ${name}`]);
        return true;
    } catch {
        return false;
    }
}

async function setWallpaper(path: string) {
    if (await programIsRunning("mpvpaper")) {
        killProgram("mpvpaper")
    }

    if (!await programIsRunning("hyprpaper")) {
        await execAsync(["bash", "-c", "hyprpaper&"]);
    }

    const loadedOutput = await execAsync(["bash", "-c", "hyprctl hyprpaper listloaded"]);
    const isPreloaded = loadedOutput.includes(path);

    const cmd = isPreloaded
        ? `hyprctl hyprpaper wallpaper ",${path}"`
        : `hyprctl hyprpaper preload "${path}" && hyprctl hyprpaper wallpaper ",${path}"`;

    await execAsync(["bash", "-c", cmd]);
}

async function setMpvpaper(path: string) {
    if (await programIsRunning("mpvpaper")) {
        killProgram("mpvpaper")
    }

    if (await programIsRunning("hyprpaper")) {
        killProgram("hyprpaper")
    }

    const hypr = Hyprland.get_default();

    for (const monitor of hypr.monitors) {
        const cmd = `mpvpaper -p -f -o --loop ${monitor.name} "${path}"`;
        await execAsync(["bash", "-c", cmd]);
    }
}

function renderWallpapers() {
    return wallpapers.get().map(({ path, isVideo, resolution, size, thumbnailPath }) => (
        <box className="wallbox" vertical>
            <button
                className="wallpaper"
                valign={Gtk.Align.CENTER}
                css={`
                        background-image: url('${thumbnailPath}');
                        min-height: ${height * 0.9}px;

                    `}
                onClicked={() => {
                    isVideo ? setMpvpaper(path) : setWallpaper(path);
                    currentWallpaper.set(path);
                }}
            />
            <label className={`filename ${isVideo ? "gif" : "image"}`} label={path.split("/").at(-1)} />
            <label className="size" label={`${resolution} ${(size / 1024 / 1024).toFixed(1)}Mbytes`} />
        </box>
    ));
}

function createContent() {
    const child = (
        <box vertical
            className="main"
            css={`min-width: ${width * 1.25}px;`} >
            <label css="font-size: 18px; margin-bottom: 10px;" label="Change background" />
            <scrollable className="scrollable" vexpand>
                <box vertical spacing={5}>
                    {bind(wallpapers).as(renderWallpapers)}
                </box>
            </scrollable>
        </box >
    );

    const keys = (window: Gdk.Window, event: Gdk.Event) => {
        const key = event.get_keyval()[1];
        if (key === Gdk.KEY_Escape) window.hide();
        if (key === Gdk.KEY_r) {
            fetchWallpapers();
            Logger.debug("Fetch wallpaper");
        }
    };

    return { child, keys };
}

export function WindowWallpaper() {
    initCurrentWallpaper();
    fetchWallpapers();

    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM,
        createContent,
        true
    );
}

