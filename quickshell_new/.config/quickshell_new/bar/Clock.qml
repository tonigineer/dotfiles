import "../widgets" as W
import "../services" as S
import QtQuick
import Quickshell

W.StyledText {
    id: clock

    anchors.centerIn: parent

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    // qmllint disable missing-property
    text: S.Config.formatDateTime(sysClock.date)

    W.ButtonLayer {
        anchors.centerIn: parent

        function onClicked(): void {
            console.log(S.Config.settings.misc.dateFormat);
            S.Config.settings.misc.dateFormat = (S.Config.settings.misc.dateFormat + 1) % S.Config.numDateFormats;
        }
    }
}
