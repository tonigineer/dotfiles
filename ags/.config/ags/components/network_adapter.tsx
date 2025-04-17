import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { Variable, bind, exec, execAsync, GLib } from "astal"
import Network from "gi://AstalNetwork"
import { Logger } from "@logging";
import { InteractiveWindow } from "@windows/lib"

const WINDOW_NAME = "window_network";
const network = Network.get_default();

function getConnectivityLabel(): string {
    const AstalNetworkConnectivity: Record<number, string> = {
        0: "UNKNOWN",
        1: "NONE",
        2: "PORTAL",
        3: "LIMITED",
        4: "FULL",
    } as const;

    return AstalNetworkConnectivity[network.connectivity] ?? "Unknown";
}

const AstalNetworkDeviceState: Record<number, string> = {
    0: "UNKNOWN",
    10: "UNMANAGED",
    20: "UNAVAILABLE",
    30: "DISCONNECTED",
    40: "PREPARE",
    50: "CONFIG",
    60: "NEED_AUTH",
    70: "IP_CONFIG",
    80: "IP_CHECK",
    90: "SECONDARIES",
    100: "ACTIVATED",
    110: "DEACTIVATING",
    120: "FAILED",
} as const;

function getIpAddress(): string {
    const command = [
        "bash",
        "-c",
        `nmcli -g IP4.ADDRESS device show | grep -m1 . | cut -d'/' -f1`
    ];

    try {
        return exec(command).trim();
    } catch (error) {
        Logger.error(`Failed to get IP address: ${error}`);
        return "N/A";
    }
}

const tooltipWired = bind(network.wired, "state", "speed").as((_: any) => {
    return [
        `Connectivity:\t${getConnectivityLabel()}`,
        `Speed:\t\t${network.wired.speed} MBit/s`,
        `IP Address:\t${getIpAddress()}`
    ].join("\n");
});

const tooltipWifi = bind(network.wifi, "state").as(() => {
    return [
        `Connectivity:\t${getConnectivityLabel()}`,
        `SSID:\t\t${network.wifi.ssid}`,
        `Signal:\t\t${network.wifi.strength}`,
        `IP Address:\t${getIpAddress()}`
    ].join("\n");
});

export function WidgetNetwork() {
    return <button
        onClicked={() => {
            const win = App.get_window(WINDOW_NAME);
            if (win) {
                win.visible ? win.hide() : win.show();
            }
        }}>
        <stack visibleChildName={bind(network.wired, "state").as((state: any) => state > 30 ? "wired" : "wifi")}>
            <box name="wired">
                {bind(network, "wired").as(wired => wired && (
                    <icon
                        tooltipText={tooltipWired}
                        className="Wired"
                        icon={bind(network.wired, "iconName")}
                    />
                ))}
            </box>
            <box name="wifi">
                {bind(network, "wifi").as(wifi => wifi && (
                    <icon
                        tooltipText={tooltipWifi}
                        className="Wifi"
                        icon={bind(network.wifi, "iconName")}
                    />
                ))}
            </box>
        </stack>
    </button>;
}

function wiredAdapter(): Box {
    return <box className="wired" vertical>
        <box spacing={10}>
            <label label="Wired" hexpand={true} xalign={0} />
            {bind(network.wired, "state").as((state: any) =>
                <label className="state" label={AstalNetworkDeviceState[state]} halign="center" />
            )}
            <switch
                halign="end"
                active={bind(network.wired, "state").as((state: any) => state === 100)}
                onButtonPressEvent={() => {
                    exec([
                        "bash", "-c",
                        `nmcli device ${network.wired.state !== 100 ? "connect" : "disconnect"} $(nmcli device | grep ethernet | cut -d" " -f1)`
                    ]);
                }}
            />
        </box>
    </box>;
}

function wifiAdapter(): Box {
    return <box className="wifi" vertical>
        <box spacing={10}>
            <label label="Wifi" hexpand={true} xalign={0} />
            {bind(network.wifi, "state").as((state: any) =>
                <label className="state" label={AstalNetworkDeviceState[state]} halign="center" />
            )}
            <switch
                halign="end"
                active={network.wifi.state === 100}
                onButtonPressEvent={() => {
                    exec([
                        "bash", "-c",
                        `nmcli device ${network.wifi.state !== 100 ? "connect" : "disconnect"} $(nmcli device | grep 'wifi ' | cut -d" " -f1)`
                    ]);
                }}
            />
        </box>
    </box>;
}

function createContent() {
    Logger.debug(`CreateContent called for window: ${WINDOW_NAME}`);

    const child = <box className="network" vertical spacing={5} homogeneous={true}>
        <label className="header" label="Network Adapters" />
        <box spacing={10} className="ipaddress">
            <label label="IP Address" hexpand={true} xalign={0} />
            {bind(network.wired, "state").as(() =>
                <label className="ip" label={getIpAddress()} hexpand={true} />
            )}
        </box>
        {wiredAdapter()}
        {wifiAdapter()}
    </box>;

    const keys = function(window: Gdk.Window, event: Gdk.Event) {
        if (event.get_keyval()[1] === Gdk.KEY_Escape) {
            window.hide();
        }
    };

    return { child, keys };
}

export function WindowNetwork() {
    return InteractiveWindow(
        WINDOW_NAME,
        Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
        createContent,
        false
    );
}

