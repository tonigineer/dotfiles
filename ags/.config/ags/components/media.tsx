import { App, Astal, Gtk, Gdk } from "astal/gtk3";
import { Variable, bind, exec, execAsync, GLib } from "astal";

import Mpris from "gi://AstalMpris";
import { Logger } from "@logging";

const mpris = Mpris.get_default();

const playerToIcon = (name: string): string => ({
    spotify: "󰓇",
    LibreWolf: "󰈹",
}[name] || "");

const lookupIcon = (name: string): string =>
    Astal.Icon.lookup_icon(name) || "audio-x-generic-symbolic";

function progress(player: Mpris.Player) {
    const icon = bind(player, "entry").as(playerToIcon);

    return (
        <circularprogress
            className="progress"
            rounded
            inverted={false}
            borderWidth={1}
            value={bind(player, "position").as(pos =>
                player.length > 0 ? pos / player.length : 0
            )}
            halign={Gtk.Align.CENTER}
            valign={Gtk.Align.CENTER}
            child={<label className={player.entry} label={icon} />}
        />
    );
}

function title(player: Mpris.Player) {
    return (
        <label
            className="title"
            max_width_chars={25}
            truncate
            label={bind(player, "title").as(title => title || "Unknown Track")}
        />
    );
}

function artist(player: Mpris.Player) {
    return (
        <label
            className="artist"
            max_width_chars={20}
            truncate
            label={bind(player, "artist").as(artist => artist || "Unknown Artist")}
        />
    );
}

function Player(player: Mpris.Player) {
    return (
        <box
            className={bind(player, "entry").as(() => "media")}
            spacing={10}
        >
            {progress(player)}
            {title(player)}
            <label
                css="font-size: 10px; font-style: italic;"
                label="by"
            />
            {artist(player)}
        </box>
    );
}

function activePlayer(): Mpris.Player | null {
    return (
        mpris.players.find(p => p.playbackStatus === Mpris.PlaybackStatus.PLAYING)
        || mpris.players[0]
        || null
    );
}

export function WidgetMedia() {
    return (
        <box className="WidgetMedia">
            {bind(mpris, "players").as(players =>
                players.length > 0 && activePlayer()
                    ? Player(activePlayer()!)
                    : <box />
            )}
        </box>
    );
}

