import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';

import Bar from "./bar/index";

import IndicatorVolume from "./indicators/volume";
import SidebarSettings from './sidebars/sidebar-settings';


App.addIcons(`${App.configDir}/assets`)

// https://aylur.github.io/ags-docs/config/theming/#autoreload-css
Utils.monitorFile(
    `${App.configDir}/scss`,

    function () {
        // Are set in ./config.js
        const scss = `${App.configDir}/scss/index.scss`
        const css = `/tmp/ags/style.css`

        // compile, reset, apply
        Utils.exec(`sassc ${scss} ${css}`)
        App.resetCss()
        App.applyCss(css)
    },
)

App.config({
    windows: [
        SidebarSettings,
        IndicatorVolume,
    ]
})

export default {
    windows: [
        Hyprland.monitors.map((m) => Bar(m)),
    ]
};