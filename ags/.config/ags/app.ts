#!/usr/bin/gjs -m

import "./globals";

import { App } from "astal/gtk3";
import { compileScss } from "./css_hot_reload";

import BarTop from "@windows/bar_top/main";
import BarBottom from "@windows/bar_bottom/main";
// import { PowerMenu } from "@widgets/powermenu";
import { PowerMenu } from "@windows/shutdown/main";

// import requestHandler from './request_handler'

App.start({
    css: compileScss(),
    main() {
        App.get_monitors().map(BarTop);
        App.get_monitors().map(BarBottom);
        App.get_monitors().map(PowerMenu);
    },
    // requestHandler
});
