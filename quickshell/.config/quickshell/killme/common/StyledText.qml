import QtQuick
import QtQuick.Layouts

import "root:/config"

Text {
    renderType: Text.NativeRendering
    verticalAlignment: Text.AlignVCenter
    font {
        hintingPreference: Font.PreferFullHinting
        family: Vanity.font.text
        // pixelSize: Vanity.font.pixleSize.smallest
    }
    // color: Vanity.color.activeWindow.background
    // linkColor: Vanity.color.activeWindow.link
}
