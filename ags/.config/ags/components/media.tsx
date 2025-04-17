import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"

import Mpris from "gi://AstalMpris"
import { Logger } from "@logging";

const mpris = Mpris.get_default()

function playerToIcon(name: string) {
    let icons: {
        [key: string]: string
    } = {
        spotify: "󰓇",
        VLC: "󰓈",
        YouTube: "󰓉",
        Brave: "",
        Audacious: "󰓋",
        Rhythmbox: "󰓌",
        Chromium: "",
        Firefox: "󰈹",
        firefox: "󰈹",
    }
    return icons[name] || ""
}



const lookupIcon = (name: string) => {
    let result = Astal.Icon.lookup_icon(name) ? Astal.Icon.lookup_icon(name) : "audio-x-generic-symbolic"
    return result
}

export function WidgetMedia() {
    const progress = (player: Mpris.Player) => {
        const playerIcon = bind(player, "entry").as((e) => playerToIcon(e));
        return (
            <circularprogress
                className="progress"
                rounded={true}
                inverted={false}
                // startAt={0.25}
                borderWidth={1}
                value={bind(player, "position").as((p) =>
                    player.length > 0 ? p / player.length : 0
                )}
                halign={Gtk.Align.CENTER}
                valign={Gtk.Align.CENTER}
                child={
                    // <icon className="icon" icon={playerIcon}/>
                    <label className={"icon"} label={playerIcon} />
                }></circularprogress>
        );
    };

    const coverArtToCss = (player: Mpris.Player) =>
        bind(player, "coverArt").as(
            (c) => {
                `
        background-image: linear-gradient(
          to right,
        #000000,
        rgba(0, 0, 0, 0.5)
            ),
            url("${c}");
        `;
            });

    const title = (player: Mpris.Player) => (
        <label
            className="title"
            max_width_chars={25}
            truncate={true}
            label={bind(player, "title").as((t) => t || "Unknown Track")}></label>
    );

    const artist = (player: Mpris.Player) => (
        <label
            className="artist"
            max_width_chars={20}
            truncate={true}
            label={bind(player, "artist").as(
                (a) => `by ${a}` || "Unknown Artist"
            )}></label>
    );

    function Player(player: Mpris.Player) {
        return (
            <box
                className={bind(player, "entry").as((entry) => `media ${entry}`)}
                css={coverArtToCss(player)}
                spacing={10}>
                {title(player)}
                {artist(player)}
            </box>
        );
    }

    const activePlayer = () =>
        Player(
            mpris.players.find(
                (player) => player.playbackStatus === Mpris.PlaybackStatus.PLAYING
            ) || mpris.players[0]
        );

    return <box className="WidgetMedia">
        {activePlayer()}
    </box>
}

