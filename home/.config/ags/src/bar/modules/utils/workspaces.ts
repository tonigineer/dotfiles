import { Applications } from "resource:///com/github/Aylur/ags/service/applications.js";
import GLib from "gi://GLib?version=2.0";

import type { Client } from "types/service/hyprland";

const app_icons = new Applications().list.reduce(
    (acc, app) => {
        if (app.icon_name) {
            acc.classOrNames[app.wm_class ?? app.name] = app.icon_name;
            acc.executables[app.executable] = app.icon_name;
        }
        return acc;
    },
    { classOrNames: {}, executables: {} },
);

function trimToIconName(name: string) {
    return name.replaceAll(" ", "-").replaceAll(".", "-");
}

export function getIconName(client: Client | undefined): string {
    if (!client) {
        return "workspace-missing";
    }

    let icon = app_icons.classOrNames[client.class];

    // Prioritize own .svg over findings.
    let possibleIcon = trimToIconName(`icon-${client.class.toLowerCase()}`);
    if (fileExists(`${App.configDir}/assets/${possibleIcon}.svg`)) {
        icon = possibleIcon;
        app_icons.classOrNames[client.class] = icon;
    }

    possibleIcon = trimToIconName(`icon-${client.title.toLowerCase()}`);
    if (fileExists(`${App.configDir}/assets/${possibleIcon}.svg`)) {
        icon = possibleIcon;
        app_icons.classOrNames[client.title] = icon;
    }

    if (!icon) {
        const binaryName = Utils.exec(`ps -p ${client.pid} -o comm=`);
        icon = app_icons.executables[binaryName];
        if (!icon) {
            let key = Object.keys(app_icons.executables).find((key) => key.startsWith(binaryName));
            if (key) {
                icon = app_icons.executables[key];
            }
        }
        if (icon) {
            app_icons[client.class] = icon;
        }
    }

    if (!icon) {
        const icon_key = Object.keys(app_icons.classOrNames).find(
            (key) =>
                key.includes(client.title) ||
                key.includes(client.initialTitle) ||
                key.includes(client.initialClass) ||
                key.includes(client.class),
        );
        if (icon_key) {
            icon = app_icons.classOrNames[icon_key];
            app_icons.classOrNames[client.class] = icon;
        }
    }

    if (!icon) {
        app_icons.classOrNames[client.class] = "workspace-missing";
    }

    return icon;
}

export function fileExists(path: string): boolean {
    return GLib.file_test(path, GLib.FileTest.EXISTS);
}
