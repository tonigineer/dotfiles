//@ pragma UseQApplication
//@ pragma IgnoreSystemSettings
//
//@ pragma Env QS_NO_RELOAD_POPUP=1

// import QtQuick
import Quickshell

// import Quickshell.Io
// import Quickshell.Hyprland

Scope {
    id: root

    Component.onCompleted: {
        console.log("Shell initialized");
        // S.BrightnessState.load();
    }

    Variants {
        model: Quickshell.screens

        ScreenState {
            required property ShellScreen modelData

            screen: modelData
        }
    }
}
