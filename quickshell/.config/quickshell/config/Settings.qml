pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

Singleton {
    id: root

    property QtObject bar

    bar: QtObject {
        property bool atBottom: false
        property bool borderless: false
        property bool showBackground: true

        property QtObject workspaces: QtObject {
            property int shown: 10
            property bool alwaysShowNumbers: false
            property int showNumberDelay: 150
        }
        property QtObject utilButtons: QtObject {
            property bool showScreenSnip: true
            property bool showColorPicker: false
            property bool showMicToggle: false
            property bool showKeyboardToggle: true
        }
        property QtObject clock: QtObject {
            property string format: "hh:mm"
            property string dateFormat: "dddd, dd/MM"
        }
    }
}
