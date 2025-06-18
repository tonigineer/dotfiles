// Time.qml

// with this line our type becomes a singleton
pragma Singleton

import Quickshell
// import Quickshell.Io
import QtQuick

// your singletons should always have Singleton as the type
Singleton {
    id: root
    // an expression can be broken across multiple lines using {}
    readonly property string time: {
        // The passed format string matches the default output of
        // the `date` command.
        Qt.formatDateTime(clock.date, "dddd, d.MMM.yyyy -- hh:mm:ss");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    // id: root
    // property string time

    // Process {
    //     id: dateProc
    //     command: ["date"]
    //     running: true

    //     stdout: StdioCollector {
    //         onStreamFinished: root.time = this.text
    //     }
    // }

    // Timer {
    //     interval: 1000
    //     running: true
    //     repeat: true
    //     onTriggered: dateProc.running = true
    // }
}
