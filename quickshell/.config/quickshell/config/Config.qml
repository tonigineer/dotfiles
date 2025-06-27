pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import "root:/config"

Singleton {
    id: root

    /* General settings */
    property string fontFamily: "Monaspace Krypton"
    property int fontSize: 12
    property color textColor: Theme.text_main
    property color backgroundColor: Theme.background

    /* Appearance */
    // property QtObject theme: Theme

    /* Windows */
    property QtObject bar

    bar: QtObject {
        /* General settings */
        property bool showAtBottom: false
        property bool marginOnlyBottom: true
        property real margin: 2
        property int min_height: 30
        property color marginColor: Theme.background_alt

        property int radius: 0
        property real borderWidth: 0
        property color borderColor: Theme.accent_blue

        property real leftMargin: 10
        property real rightMargin: 10
        property int widgetSpacing: 10

        /* Widgets */
        property QtObject widgetIcon
        property QtObject widgetActiveWindow
        property QtObject widgetWorkspaces
        property QtObject widgetUtilButtons
        property QtObject widgetClock

        widgetIcon: QtObject {
            property bool showDistro: false
            property string customIcon: "arch"
            property int iconSize: 14
            property color iconColor: Theme.accent_red
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
