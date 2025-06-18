import QtQuick
import "root:/modules"

BarBlock {
    id: text
    dim: true
    underline: true

    content: Text {
        text: "dfasfdsa"
    }

    leftPadding: 10
    rightPadding: 100
    // content: BarText {
    //     symbolText: ` ${Datetime.date}`
    // }
}
