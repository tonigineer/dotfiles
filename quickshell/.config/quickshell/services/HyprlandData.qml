pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

/**
 * Provides access to some Hyprland data not available in Quickshell.Hyprland.
 */
Singleton {
    id: root
    property var windowList: []
    property var addresses: []
    property var windowByAddress: ({})
    property var monitors: []
    property var layers: ({})
    property bool hypridleIsRunning

    function updateWindowList() {
        getClients.running = true;
        getMonitors.running = true;
    }

    function updateLayers() {
        getLayers.running = true;
    }

    function updateHypridle() {
        getHypridle.running = true;
    }

    Component.onCompleted: {
        updateWindowList();
        updateLayers();
        updateHypridle();
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            // Filter out redundant old v1 events for the same thing
            if (event.name in ["activewindow", "focusedmon", "monitoradded", "createworkspace", "destroyworkspace", "moveworkspace", "activespecial", "movewindow", "windowtitle"])
                return;
            updateWindowList();
        }
    }

    Process {
        id: getClients
        command: ["bash", "-c", "hyprctl clients -j | jq -c"]
        stdout: SplitParser {
            onRead: data => {
                root.windowList = JSON.parse(data);
                let tempWinByAddress = {};
                for (var i = 0; i < root.windowList.length; ++i) {
                    var win = root.windowList[i];
                    tempWinByAddress[win.address] = win;
                }
                root.windowByAddress = tempWinByAddress;
                root.addresses = root.windowList.map(win => win.address);
            }
        }
    }

    Process {
        id: getMonitors
        command: ["bash", "-c", "hyprctl monitors -j | jq -c"]
        stdout: SplitParser {
            onRead: data => {
                root.monitors = JSON.parse(data);
            }
        }
    }

    Process {
        id: getLayers
        command: ["bash", "-c", "hyprctl layers -j | jq -c"]
        stdout: SplitParser {
            onRead: data => {
                root.layers = JSON.parse(data);
            }
        }
    }

    Process {
        id: getHypridle
        // TODO: better implementation than the sleep is needed here :)
        command: ["bash", "-c", "sleep 0.5; systemctl --user is-active hypridle.service"]
        stdout: SplitParser {
            onRead: data => {
                root.hypridleIsRunning = data.trim() === "active";
            }
        }
    }
}
