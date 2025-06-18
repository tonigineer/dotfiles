pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

import "root:/config"

Singleton {
    id: root

    /* General settings */

    /* Appearance */
    // property QtObject theme: Theme

    /* Windows */
    property QtObject bar

    bar: QtObject {
        /* General settings */
        property bool showAtBottom: false
        property int margin: 0
        property color backgroundColor: "white"

        property int radius: 0
        property real borderWidth: 0
        property color borderColor: Theme.accent_red

        property real leftMargin: 10
        property real rightMargin: 10
        property int widgetSpacing: -1

        /* Widgets */
        property QtObject widgetIcon
        property QtObject widgetActiveWindow
        property QtObject widgetWorkspaces
        property QtObject widgetUtilButtons
        property QtObject widgetClock

        widgetIcon: QtObject {
            property bool showDistro: false
            property string customIcon: "arch"
        }

        widgetActiveWindow: QtObject {
            property bool showTitle: false
        }

        widgetWorkspaces: QtObject {
            property int shown: 10
            property bool alwaysShowNumbers: false
            property int showNumberDelay: 150
        }
        widgetUtilButtons: QtObject {
            property bool showScreenSnip: true
            property bool showColorPicker: false
            property bool showMicToggle: false
            property bool showKeyboardToggle: true
        }
        widgetClock: QtObject {
            property string format: "hh:mm"
            property string dateFormat: "dddd, dd/MM"
        }
    }
}
