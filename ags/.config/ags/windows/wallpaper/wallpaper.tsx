import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import { Variable, bind, execAsync } from "astal";
import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib";

const WINDOW_NAME = "window_wallpaper";

const currentWallpaper = Variable<string>("");
const wallpapers = Variable<{ path: string; size: number, thumbnailPath: string }[]>([]);

const width = THUMBNAIL_WIDTH;
const height = THUMBNAIL_WIDTH * 9 / 16;

async function initCurrentWallpaper() {
    const output = await execAsync(["bash", "-c", "hyprctl hyprpaper listactive"]);
    const line = output.split("\n")[0];
    const wallpaper = line?.split(" = ")[1]?.trim() || "";
    currentWallpaper.set(wallpaper);
}

async function fetchWallpapers() {
    const output = await execAsync([
        "bash",
        "-c",
        `find ${HOME_DIR}/.config/hypr/backgrounds -type f`
    ]);

    const paths = output.trim().split("\n");
    const thumbDir = `${HOME_DIR}/.cache/hypr-thumbnails`;

    await execAsync(["bash", "-c", `mkdir -p "${thumbDir}"`]);

    const result = await Promise.all(paths.map(async (path) => {
        const sizeOutput = await execAsync(["bash", "-c", `stat -c %s "${path}"`]);
        const size = parseInt(sizeOutput.trim(), 10);

        const hash = await execAsync(["bash", "-c", `echo -n "${path}{width}" | md5sum | cut -d' ' -f1`]);
        const thumbPath = `${thumbDir}/${hash.trim()}.jpg`;

        await execAsync([
            "bash",
            "-c",
            `[ -f "${thumbPath}" ] || convert "${path}" -resize ${width}x${height}^ -gravity center -extent ${width}x${height} "${thumbPath}"`
        ]);

        return {
            path,
            size,
            thumbnailPath: thumbPath,
        };
    }));

    wallpapers.set(result);
}

async function setWallpaper(path: string) {
    const loadedOutput = await execAsync(["bash", "-c", "hyprctl hyprpaper listloaded"]);
    const isPreloaded = loadedOutput.includes(path);

    const cmd = isPreloaded
        ? `hyprctl hyprpaper wallpaper ",${path}"`
        : `hyprctl hyprpaper preload "${path}" && hyprctl hyprpaper wallpaper ",${path}"`;

    await execAsync(["bash", "-c", cmd]);
}

function renderWallpapers() {
    return wallpapers.get().map(({ path, size, thumbnailPath }) => (
        <box className="wallbox" vertical>
            <button
                className="wallpaper"
                valign={Gtk.Align.CENTER}
                css={`background-image: url('${thumbnailPath}');`}
                onClicked={() => {
                    setWallpaper(path);
                    currentWallpaper.set(path);
                }}
                onEnterNotifyEvent={() => {
                    setWallpaper(path);
                    return false;
                }}
                onLeaveNotifyEvent={() => {
                    setWallpaper(currentWallpaper.get());
                    return false;
                }}
            />
            <label label={path.split(".config/hypr/backgrounds/")[1]} />
            <label label={`[${(size / 1024 / 1024).toFixed(1)} Mbytes]`} />
        </box>
    ));
}

function createContent() {
    Logger.debug(`CreateContent called for window: ${WINDOW_NAME}`);

    const child = (
        <box vertical className="main">
            <scrollable className="scrollable" vexpand>
                <box vertical spacing={5}>
                    {bind(wallpapers).as(renderWallpapers)}
                </box>
            </scrollable>
        </box>
    );

    const keys = (window: Gdk.Window, event: Gdk.Event) => {
        const key = event.get_keyval()[1];
        if (key === Gdk.KEY_Escape) window.hide();
        if (key === Gdk.KEY_r) {
            fetchWallpapers();
            Logger.debug("Fetch wallpaper");
        }
    };

    Logger.debug(`CreateContent finished for window: ${WINDOW_NAME}`);
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

