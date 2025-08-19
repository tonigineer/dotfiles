import "../widgets" as W
import "../services" as S
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property color defaultColor: S.Config.theme.secondary

    Layout.fillHeight: false
    Layout.alignment: Qt.AlignVCenter

    ColumnLayout {
        id: values
        spacing: -5

        Text {
            text: `${S.NetworkAdapter.uploadMBs >= 0.1 ? "" : " "}${S.NetworkAdapter.uploadMBs.toFixed(1)}`
            color: root.defaultColor
            font.pixelSize: S.Config.fontSize.small
            font.bold: true
        }

        Text {
            text: `${S.NetworkAdapter.downloadMBs >= 0.1 ? "" : " "}${S.NetworkAdapter.downloadMBs.toFixed(1)}`
            color: root.defaultColor
            font.pixelSize: S.Config.fontSize.small
            font.bold: true
        }
    }

    ColumnLayout {
        id: arrows
        spacing: S.Config.settings.bar.height * -2 / 3

        W.MaterialIcon {
            id: uploadArrow

            text: "arrow_drop_up"

            color: S.NetworkAdapter.uploadMBs >= 0.1 ? S.Config.theme.error : S.Config.theme.inverse_on_surface
            font.pointSize: S.Config.fontSize.h1
            font.weight: S.NetworkAdapter.uploadMBs >= 0.1 ? Font.Bold : Font.DemiBold
        }

        W.MaterialIcon {
            id: downloadArrow

            text: "arrow_drop_down"

            color: S.NetworkAdapter.downloadMBs >= 0.1 ? S.Config.theme.inverse_primary : S.Config.theme.inverse_on_surface
            font.pointSize: S.Config.fontSize.h1
            font.weight: S.NetworkAdapter.downloadMBs >= 0.1 ? Font.Bold : Font.DemiBold
        }
    }
}

// RowLayout {
//     id: root
//
//     property color defaultColor: "red"
//
//     // anchors.centerIn: parent
//     implicitWidth: 20
//
//     W.MaterialIcon {
//         id: uploadArrow
//
//         anchors.bottom: parent.bottom
//         anchors.right: parent.right
//
//         text: "arrow_drop_up"
//         color: S.NetworkAdapter.uploadMBs >= -1.1 ? "red" : "yellow" //Colors.palette.m3error : Colors.palette.m3inverseOnSurface
//         font.pointSize: S.Config.fontSize.large
//         font.weight: S.NetworkAdapter.uploadMBs >= -1.1 ? Font.Bold : Font.DemiBold
//     }
//
//     // MaterialIcon {
//     //     id: downloadArrow
//     //
//     //     anchors.top: networkSpeeds.top
//     //     anchors.right: parent.right
//     //     animate: true
//     //
//     //     text: "arrow_drop_down"
//     //     color: NetworkAdapter.downloadMBs >= -1.1 ? Colors.palette.rosewater : Colors.palette.m3inverseOnSurface
//     //
//     //     font.pointSize: Appearance.font.size.large
//     //     font.weight: NetworkAdapter.downloadMBs >= -1.1 ? Font.Bold : Font.DemiBold
//     // }
//     //
//     // Text {
//     //     id: uploadValue
//     //
//     //     anchors.bottom: parent.top
//     //     anchors.bottomMargin: -11
//     //     anchors.left: parent.left
//     //
//     //     text: `${NetworkAdapter.uploadMBs >= 9 ? "" : " "}${NetworkAdapter.uploadMBs.toFixed(1)}`
//     //     color: root.colour
//     //     font.pixelSize: 8
//     //     font.bold: true
//     //     font.family: Appearance.font.family.mono
//     // }
//     //
//     // Text {
//     //     id: downloadValue
//     //     anchors.top: parent.bottom
//     //     anchors.topMargin: -11
//     //     anchors.left: parent.left
//     //
//     //     text: `${NetworkAdapter.downloadMBs >= 9 ? "" : " "}${NetworkAdapter.downloadMBs.toFixed(1)}`
//     //     color: root.colour
//     //     font.pixelSize: 8
//     //     font.bold: true
//     //     font.family: Appearance.font.family.mono
//     // }
// }
