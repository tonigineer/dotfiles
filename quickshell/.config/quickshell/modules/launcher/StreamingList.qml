pragma Singleton

import "root:/utils/scripts/fuzzysort.js" as Fuzzy
import "root:/config"
import Quickshell
import QtQuick
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property list<Variant> list: [
        Variant {
            // URL source -- https://gist.github.com/Axel-Erfurt/b40584d152e1c2f13259590a135e05f4
            url: "https://daserste-live.ard-mcdn.de/daserste/live/hls/de/master.m3u8"
            icon: "live_tv"
            name: "ARD Livestream"
            description: "Live stream of Das Erste (ARD), Germany's primary public‑service television channel."
        },
        Variant {
            url: "https://www.zdf.de/sender/zdf/zdf-live-beitrag-100.html"
            icon: "live_tv"
            name: "ZDF Livestream"
            description: "Live stream of ZDF, Germany's second national public‑service broadcaster."
        },
        Variant {
            url: "https://zdf-hls-19.akamaized.net/hls/live/2016502/de/high/master.m3u8"
            icon: "public"
            name: "Phoenix Livestream"
            description: "Live stream of Phoenix, a German public‑service channel focusing on politics, documentaries, and special events."
        },
        Variant {
            url: ""
            icon: "movie"
            name: "Netflix"
            description: "Launch Netflix—the subscription streaming service for films and series."
            command: "brave --app=https://netflix.com"
        }
    ]

    readonly property list<var> preppedVariants: list.map(v => ({
                name: Fuzzy.prepare(v.variant),
                variant: v
            }))

    function fuzzyQuery(search: string): var {
        return Fuzzy.go(search.slice(`${Config.launcher.actionPrefix}streaming `.length), preppedVariants, {
            all: true,
            key: "name"
        }).map(r => r.obj.variant);
    }

    component Variant: QtObject {
        required property string url
        required property string icon
        required property string name
        required property string description
        property string command: ""

        function onClicked(list: AppList): void {
            list.visibilities.launcher = false;
            const dispatch_param = "[workspace 4; float; size 50% 50%; move 48.75% 5%]";
            // Prefer custom command when provided
            if (command && command.length) {
                Hyprland.dispatch(`exec ${dispatch_param} ${command}`);
            } else {
                Hyprland.dispatch(`exec ${dispatch_param} mpv --keepaspect --keepaspect-window ${url}`);
            }
        }
    }
}
