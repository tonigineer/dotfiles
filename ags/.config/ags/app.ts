#!/usr/bin/gjs -m

import "./globals";

import { App } from "astal/gtk3";

import { Logger } from "@logging";
import { compileScss } from "./css_hot_reload";

import BarTop from "@windows/bars/top";
import BarBottom from "@windows/bars/bottom";

import { WindowShutdown } from "@windows/system/shutdown";
import { WindowSystemUpdates } from "@windows/system/updates";

// import requestHandler from './request_handler'

App.start({
    css: compileScss(),
    main() {
        Logger.info("App.start executed ...");

        App.get_monitors().map(BarTop);
        App.get_monitors().map(BarBottom);

        WindowShutdown();
        WindowSystemUpdates();
    },

    // requestHandler
});
