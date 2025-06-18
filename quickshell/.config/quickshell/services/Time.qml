pragma Singleton

import Quickshell
import QtQuick

Singleton {
    id: root

    readonly property string dateLong: Qt.formatDate(clock.date, "dddd, d.MMM.yyyy")
    readonly property string timeLong: Qt.formatTime(clock.date, "hh:mm:ss")
    readonly property string date: Qt.formatDate(clock.date, "dd.MM.yyyy")
    readonly property string time: Qt.formatTime(clock.date, "hh:mm")

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
