const { query } = await Service.import("applications")
const WINDOW_NAME = "AppLauncher"

import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';


const ApplicationItem = application => Widget.Button({
    attribute: { application },
    on_clicked: () => {
        App.closeWindow(WINDOW_NAME)
        application.launch()
    },
    child: Widget.Box({
        children: [
            Widget.Icon({
                icon: application.icon_name,
                size: 42,
            }),
            Widget.Label({
                class_name: "title",
                label: application.name,
                xalign: 0,
                vpack: "center",
                truncate: "end",
            }),
        ],
    }),
})


let Applications = query("").map(ApplicationItem)






//     // repopulate the box, so the most frequent apps are on top of the list
//     // function repopulate() {
//     //     applications = query("").map(AppItem)
//     //     applications.forEach(item => item.visible = false);
//     //     list.children = applications
//     // }

//     // search entry
//     const entry = Widget.Entry({
//         hexpand: true,
//         class_name: "text",
//         placeholder_text: 'type here',
//         text: 'S  initial text',
//         // to launch the first item on Enter
//         on_accept: () => {
//             // make sure we only consider visible (searched for) applications
//             const results = applications.filter((item) => item.visible);
//             if (results[0]) {
//                 App.toggleWindow(WINDOW_NAME)
//                 results[0].attribute.app.launch()
//             }
//         },

//         // filter out the list
//         on_change: ({ text }) => {
//             let num = 0;
//             applications.forEach(item => {
//                 item.visible = item.attribute.app.match(text);
//                 if (item.visible) num += 1;
//             });
//             console.log(num);
//             found.setValue(num > 0 && num < 3);
//         }
//     })

//     return Widget.Box({
//         class_name: "app-launcher",
//         vertical: true,
//         children: [
//             Widget.Box({
//                 class_name: "entry-box",
//                 children: [
//                     Widget.Icon({
//                         class_name: "icon",
//                         css: "color: white;",
//                         icon: "icon-search-symbolic",
//                         size: 28,
//                     }),
//                     entry]
//             }),
//             // Widget.Scrollable({
//             //     hscroll: "never",
//             //     css: `min-height: ${40}px;`,
//             //     child: list,
//             // }),
//             // Widget.Scrollable({
//             //     hscroll: "never",
//             //     css: `min-height: ${40}px;`,
//             //     child: list,
//             // }),
//             Widget.Scrollable({
//                 hscroll: "never",
//                 css: `min-height: ${40}px;`,
//                 child: list,
//             }),
//             // Widget.Scrollable({
//             //     hscroll: "never",
//             //     css: `min-height: ${40}px;`,
//             //     child: list,
//             // }),
//         ],
//         setup: self => self.hook(App, (_, windowName, visible) => {
//             applications.forEach(item => item.visible = false);
//             list.children = applications
//             //     if (windowName !== WINDOW_NAME)
//             //         return

//             // // when the applauncher shows up
//             // if (visible) {
//             //     repopulate()
//             //     entry.text = "??"X
//             //     entry.grab_focus()
//             // }
//         }),
//     })
// }

function EntryBar() {
    const Icon = () => Widget.Icon({
        class_name: "icon",
        css: "color: white;",
        icon: "icon-search-symbolic",
        size: 28,
    })

    const Entry = () => Widget.Entry({
        hexpand: true,
        class_name: "text",
        placeholder_text: 'type here',
        // text: 'S  initial text',
        // to launch the first item on Enter
        on_accept: () => {
            // make sure we only consider visible (searched for) applications
            // const results = applications.filter((item) => item.visible);
            // if (results[0]) {
            //     App.toggleWindow(WINDOW_NAME)
            //     results[0].attribute.app.launch()
            // }
        },

        // filter out the list
        on_change: ({ text }) => {
            // let num = 0;
            Applications.forEach(item => {
                item.visible = item.attribute.application.match(text);
                // if (item.visible) num += 1;
            });
            // console.log(num);
            // found.setValue(num > 0 && num < 3);
        }
    })

    return Widget.Box({
        children: [
            Icon(),
            Entry(),
            Widget.Box({
                vertical: true,
                children: Applications,
            })
        ]
    })
}

function ResultList() {
    return Widget.Box({
        children: [Widget.Label("LILST")]
    })
}

const MainWindow = () => Widget.Box({
    class_name: "app-launcher",
    children: [
        EntryBar(),
        ResultList()
    ]
})

// there needs to be only one instance
const AppLauncher = Widget.Window({
    name: WINDOW_NAME,
    monitor: Hyprland.active.bind("monitor").as(m => m.id),
    visible: false,
    // exclusivity: "exclusive",
    keymode: "exclusive",
    anchor: ["top", "left", "top", "right"],
    margins: [0, 650, 0, 650],
    child: MainWindow(),
    setup: self => self.keybind("Escape", () => {
        App.closeWindow(WINDOW_NAME)
    }),
})

export default AppLauncher;