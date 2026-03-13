
import Quickshell
import Quickshell.Io
import QtQuick
import Qt.labs.folderlistmodel
import Quickshell.Wayland

PanelWindow {
    id: root

    implicitHeight: config.image_height || 500;
    implicitWidth: Screen.width - 2 * (config.margin_x || 0);

    color: "transparent"

    aboveWindows: true
    exclusionMode: "Ignore"
    exclusiveZone: 1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    FileView {
        path: Quickshell.shellPath("config.json")
        watchChanges: true
        onFileChanged: {
          reload()
        }
        JsonAdapter {
            id: config

            property int animation_speed
            property int image_height
            property int margin_x
            property int number_of_images
            property string wallpaper_dir
            property string cache_dir
            property string border_color
        }
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + config.wallpaper_dir
        showDirs: false
        nameFilters: ["*.png", "*.jpg", "*.jpeg"]
        sortField: FolderListModel.Name

        onStatusChanged: {
          if (status === FolderListModel.Ready) {
            createThumbnails();
            }
        }
    }

    function createThumbnails() {
        var proc = processComponent.createObject(null, {
            command: ["mkdir", "-p", config.cache_dir]
        });

        proc.running = true;

        for (var i = 0; i < folderModel.count; i++) {
            var filePath = folderModel.get(i, "filePath");
            var fileName = folderModel.get(i, "fileName");

            var proc = processComponent.createObject(null, {
                command: ["convert", filePath, "-thumbnail", "x500", config.cache_dir + "/" + fileName]
            });
            proc.running = true;
        }
    }

    Component {
        id: processComponent

        Process {
            onExited: exitCode => {
                destroy();
            }
        }
    }

    PathView {
        id: pathView
        property real tileWidth: width / config.number_of_images

        anchors.fill: parent

        focus: true
        model: folderModel
        pathItemCount: config.number_of_images
        preferredHighlightBegin: 0.5

        preferredHighlightEnd: 0.5
        path: Path {
            startX: -200
            startY: pathView.height / 2
            PathLine {
                x: pathView.width + 200
                y: pathView.height / 2
            }
        }

        Keys.onPressed: function(event) {
            if (event.isAutoRepeat) {
                event.accepted = true
                return;
            }

            if (event.key === Qt.Key_K) {
                decrementCurrentIndex()
                event.accepted = true
            } else if (event.key === Qt.Key_J) {
                incrementCurrentIndex()
                event.accepted = true
            } else if (event.key === Qt.Key_H) {
                currentIndex = (currentIndex - 7 + count) % count
                event.accepted = true
            } else if (event.key === Qt.Key_L) {
                currentIndex = (currentIndex + 7) % count
                event.accepted = true
            } else if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                event.accepted = true
                Qt.quit()
            }

            var filePath = folderModel.get(pathView.currentIndex, "filePath")
                 console.log("Setting wallpaper:", filePath)
            var proc = processComponent.createObject(null, {
              command: ["qs", "-c", "noctalia-shell", "ipc", "call", "wallpaper", "set", filePath, "all"]
            });
            proc.running = true;
        }

        delegate: Item {
            width: pathView.tileWidth
            height: pathView.height

            // width: PathView.isCurrentItem ? 1.25 * pathView.tileWidth : pathView.tileWidth
            // height: PathView.isCurrentItem ? 1.25 * pathView.height : pathView.height

            scale: PathView.isCurrentItem ? 1.0 : 0.85
            z: PathView.isCurrentItem ? 10 : 1

            Behavior on scale {
                 NumberAnimation {
                     duration: 200
                     easing.type: Easing.OutCubic
                 }
             }

             Behavior on width {
                 NumberAnimation {
                     duration: 50
                     easing.type: Easing.OutCubic
                 }
             }

            Text {
                id: alt
                text: "Loading ..."
                color: config.border_color
                anchors.centerIn: parent
                font.pixelSize: 20
                transform: Shear {
                    xFactor: -0.25
                }
            }

            Image {
                id: img
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop

                asynchronous: true
                cache: false
                smooth: true
                source: "file://" + config.cache_dir + fileName

                sourceSize.width: width
                sourceSize.height: height

                transform: Shear {
                    xFactor: -0.25
                }

                Timer {
                    id: retryTimer
                    interval: 200
                    repeat: false
                    onTriggered: {
                        let s = img.source;
                        img.source = "";
                        img.source = s;
                    }
                }

                onStatusChanged: {
                    if (status === Image.Error) {
                        alt.text = "Caching ...";
                        retryTimer.start();
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: PathView.isCurrentItem ? 5 : 2
                    border.color: "white"
                    radius: 10

                    z: 100

                    Behavior on border.width {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }


            // Rectangle {
            //     id: border
            //     z: 10
            //     visible: parent.active
            //     width: pathView.tileWidth
            //     height: 500
            //     color: "transparent"

            //     border.width: 4
            //     border.color: config.border_color

            //     transform: Shear {
            //         xFactor: -0.25
            //     }

            //     // x: list.selectedIndex * (width + list.spacing) - list.contentX

            //     Behavior on x {
            //         NumberAnimation {
            //             duration: 160
            //             easing.type: Easing.OutCubic
            //         }
            //     }
            // }

            // MouseArea {
            //     anchors.fill: parent

            //     onClicked: {
            //         list.selectedIndex = index;
            //         list.activateCurrent();
            //     }

            //     onWheel: function (wheel) {
            //         list.contentX = list.clampX(list.contentX - wheel.angleDelta.y * 2);
            //         wheel.accepted = false;
            //     }
            // }
        }
    }
}
