import "root:/widgets"
import "root:/services"
import "root:/config"
import Quickshell
import QtQuick
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Qt.labs.platform
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

Item {
    id: updateTable

    property var updates: SystemStats.updatesList
    property var isImportant: Config.barpopouts.updates.filterFunction
    property var updatesImportant: updates.filter(l => isImportant(l) && l.includes("->"))
    property var updatesRemaining: updates.filter(l => !isImportant(l) && l.includes("->"))

    property string fontFamily: Appearance.font.family.mono
    property int fontSize: Appearance.font.size.small

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    component Fill: AnchorChanges {
        required property Item item

        target: indicator
        anchors.left: item.left
        anchors.right: item.right
        anchors.top: item.top
        anchors.bottom: item.bottom
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        spacing: Appearance.spacing.large

        RowLayout {
            // Layout.fillWidth: true
            // Layout.alignment: Qt.AlignVCenter
            spacing: Appearance.spacing.smaller

            ColumnLayout {
                // Layout.fillWidth: true
                spacing: Appearance.spacing.small
                // anchors.horizontalCenter: parent.horizontalCenter

                visible: updatesImportant.length > 0

                ColumnLayout {
                    id: information
                    property var infoModel: [
                        {
                            label: qsTr("Uptime"),
                            cmd: "uptime -p",
                            transform: function (raw) {
                                var clean = raw.trim().replace(/^up\s+/, "").replace(/,/g, "");

                                var hours = 0;
                                var minutes = 0;
                                var dMatch = clean.match(/(\d+)\s+day/);
                                if (dMatch)
                                    hours += parseInt(dMatch[1], 10) * 24;
                                var hMatch = clean.match(/(\d+)\s+hour/);
                                if (hMatch)
                                    hours += parseInt(hMatch[1], 10);
                                var mMatch = clean.match(/(\d+)\s+minute/);
                                if (mMatch)
                                    minutes = parseInt(mMatch[1], 10);

                                hours += Math.floor(minutes / 60);
                                minutes = minutes % 60;

                                function pad(n) {
                                    return (n < 10 ? "0" : "") + n;
                                }
                                return pad(hours) + ":" + pad(minutes) + " h";
                            },
                            value: qsTr("…")
                        },
                        {
                            label: qsTr("Age"),
                            cmd: 'install_date="$(grep -m1 -oP \'^\\[\\K[0-9-]+\' /var/log/pacman.log)";install_sec=$(date -d "$install_date" +%s);now_sec=$(date +%s);echo $(( (now_sec - install_sec) / 86400 ))',
                            transform: function (raw) {
                                return raw.trim() + " days";
                            },
                            value: qsTr("…")
                        },
                        {
                            label: qsTr("Kernel"),
                            cmd: 'uname -r',
                            value: qsTr("…")
                        },
                        {
                            label: qsTr("Hyprland"),
                            cmd: 'hyprctl version | grep Hyprland',
                            transform: function (raw) {
                                return raw.trim().split(" ")[1];
                            },
                            value: qsTr("…")
                        },
                        {
                            label: qsTr("Packages"),
                            cmd: 'yay -Qa 2>/dev/null | wc -l',
                            value: qsTr("…")
                        },
                    ]
                }

                Repeater {
                    model: information.infoModel
                    delegate: informationRow
                }

                Component {
                    id: informationRow

                    RowLayout {
                        Layout.fillWidth: true                       // take full width
                        Layout.alignment: Qt.AlignVCenter
                        spacing: Appearance.spacing.smaller

                        Text {
                            text: modelData.label
                            font.family: fontFamily
                            font.pointSize: fontSize
                            color: Colors.palette.m3primary
                            Layout.preferredWidth: 200
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                            // horizontalAlignment: Text.AlignRight
                            // elide: Text.ElideLeft

                        }

                        Text {
                            text: modelData.value
                            font.family: fontFamily
                            font.pointSize: fontSize
                            color: Colors.palette.m3error
                            // Layout.preferredWidth: 200
                            horizontalAlignment: Text.AlignLeft
                            elide: Text.ElideRight
                        }

                        Process {
                            id: proc
                            running: true
                            command: ["sh", "-c", modelData.cmd]

                            stdout: StdioCollector {
                                onStreamFinished: {
                                    let raw = text;
                                    modelData.value = modelData.transform ? modelData.transform(raw) : raw.trim(); // keep model in sync (optional)
                                }
                            }
                        }
                    }
                }
            }
        }

        StyledRect {
            visible: updatesImportant.length > 0
            // Layout.topMargin: Appearance.padding.large
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter

            implicitWidth: text.implicitWidth + Appearance.padding.large * 2
            implicitHeight: text.implicitHeight + Appearance.padding.large * 2

            color: Colors.palette.m3surfaceContainer
            radius: Appearance.rounding.full

            StateLayer {

                radius: Appearance.rounding.full
                color: Colors.palette.m3onSurface

                function onClicked(): void {
                    Hyprland.dispatch("exec kitty --title centerfloat -e yay -Syu");
                }
            }
            StyledRect {
                anchors.centerIn: parent

                implicitWidth: text.implicitWidth + Appearance.padding.smaller * 2
                implicitHeight: text.implicitHeight + Appearance.padding.smaller * 2

                radius: Appearance.rounding.normal

                StyledText {
                    id: text
                    anchors.centerIn: parent

                    text: "Install updates"
                    font.pointSize: Appearance.font.size.small
                    font.family: Appearance.font.family.mono
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            visible: updatesImportant.length > 0

            Repeater {
                model: updatesImportant.map(function (line) {
                    const m = line.match(/^(\S+)\s+(\S+)\s+->\s+(\S+)/);
                    return m ? {
                        pkg: m[1],
                        current: m[2],
                        update: m[3]
                    } : {
                        pkg: line,
                        current: "…",
                        update: "…"
                    };
                })

                delegate: RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: Appearance.spacing.smaller

                    Text {
                        text: modelData.pkg
                        font.family: fontFamily
                        font.pointSize: fontSize
                        color: Colors.palette.m3primary
                        Layout.preferredWidth: 200
                        elide: Text.ElideRight
                    }

                    Text {
                        text: modelData.current
                        font.family: fontFamily
                        font.pointSize: fontSize
                        color: Colors.palette.m3error
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "→"
                        font.family: fontFamily
                        font.pointSize: fontSize
                        color: Colors.palette.m3secondary
                        Layout.preferredWidth: 12
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: modelData.update
                        font.family: fontFamily
                        font.pointSize: fontSize
                        color: Colors.palette.green
                        horizontalAlignment: Text.AlignRight
                        Layout.preferredWidth: 120
                        elide: Text.ElideRight
                    }
                }
            }
        }

        Rectangle {
            height: 1
            color: Colors.palette.m3outline
            Layout.fillWidth: true

            visible: updatesImportant.length > 0
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Appearance.spacing.small

            visible: updatesRemaining.length > 0

            Repeater {
                model: updatesRemaining.map(function (line) {
                    const m = line.match(/^(\S+)\s+(\S+)\s+->\s+(\S+)/);
                    return m ? {
                        pkg: m[1],
                        current: m[2],
                        update: m[3]
                    } : {
                        pkg: line,
                        current: "ss",
                        update: "sss"
                    };
                })

                delegate: RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: Appearance.spacing.smaller

                    Text {
                        text: modelData.pkg
                        font.family: fontFamily
                        font.pointSize: fontSize
                        color: Colors.palette.m3primary
                        Layout.preferredWidth: 200
                        elide: Text.ElideRight
                    }

                    Text {
                        text: modelData.current
                        font.family: fontFamily
                        font.pointSize: fontSize
                        color: Colors.palette.m3error
                        horizontalAlignment: Text.AlignRight
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "→"
                        font.family: fontFamily
                        font.pointSize: fontSize
                        color: Colors.palette.m3secondary
                        Layout.preferredWidth: 12
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        text: modelData.update
                        font.family: fontFamily
                        font.pointSize: fontSize
                        color: Colors.palette.green
                        horizontalAlignment: Text.AlignRight
                        Layout.preferredWidth: 120
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
