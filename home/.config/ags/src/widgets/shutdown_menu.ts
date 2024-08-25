// function Workspaces() {
//     // const monitors = {};
//     // HYPRLAND.monitors.forEach((i) => monitors[i] = i.name);
//     const activeId = HYPRLAND.active.workspace.bind("id")
//     const WORKSPACES = HYPRLAND.bind("workspaces")
//         .as(ws => ws.sort(({ id: a }, { id: b }) => a - b).map(({ id }) => Widget.Button({
//             on_clicked: () => HYPRLAND.messageAsync(`dispatch workspace ${id}`),
//             child: Widget.Label(`${ICONS[id]}`),
//             class_name: activeId.as(i => `${i === id ? "focused" : "unfocused"}`),
//         })))

//     return Widget.Box({
//         class_name: "workspaces",
//         children: WORKSPACES,
//     })
// }

function ShutdownMenu() {



    const SHUTDOWN_MODES = Widget.Box({
        class_name: "power_menu",
        children: [
            Widget.Button({
                child: Widget.Label({
                    label: "󰐥",
                }),
            }),
            Widget.Button({
                child: Widget.Label({
                    label: "󰜉",
                }),
            }),
            Widget.Button({
                child: Widget.Label({
                    label: "󱫟",
                }),
            })
        ],
        visible: false,
    });


    // const SHUTDOWN_MODES = () => {
    //     return {
    //         component: Widget.Box({
    //             class_name: "power_menu",
    //             children: [
    //                 Widget.Button({
    //                     child: Widget.Label({
    //                         label: "󰐥",
    //                     }),
    //                 }),
    //                 Widget.Button({
    //                     child: Widget.Label({
    //                         label: "󰜉",
    //                     }),
    //                 }),
    //                 Widget.Button({
    //                     child: Widget.Label({
    //                         label: "󱫟",
    //                     }),
    //                 })
    //             ],
    //         }),
    //         isVisible: show,
    //     }
    // }

    const SHUTDOWN_MENU_BUTTON = Widget.Button({
        hpack: "end",
        hexpand: false,
        class_name: "power_menu_button",
        child: Widget.Label({
            hpack: "end",
            label: "󰤂",
            class_name: "power_menu_button",
        }),
        // onPrimaryClick() {
        //     if (SHUTDOWN_MODES.isVisible) {
        //         SHUTDOWN_MODES.visible = false;
        //     }
        //     else {
        //         SHUTDOWN_MODES.visible = true;
        //     }
        // },
        visible: false,
    });

    return Widget.Box({
        class_name: "power_menu",
        children: [SHUTDOWN_MODES, SHUTDOWN_MENU_BUTTON],
    });
}


export { ShutdownMenu }
