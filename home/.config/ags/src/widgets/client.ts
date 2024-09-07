// const HYPRLAND = await Service.import("hyprland");
import { HYPRLAND } from "./../index";

const ClientTitle = async () => {
    return Widget.Box({
        class_name: "client-box",
        vertical: true,
        children: [
            Widget.Label({
                xalign: 0,
                truncate: 'end',
                maxWidthChars: 25,
                class_name: "client-class",
                // label: HYPRLAND.active.client.bind("title"),
                setup: (self) => self.hook(HYPRLAND.active.client, label => { // Hyprland.active.client
                    label.label = HYPRLAND.active.client.class.length === 0 ? 'Desktop' : HYPRLAND.active.client.class;
                }),
            }),
            Widget.Label({
                xalign: 0,
                truncate: 'end',
                maxWidthChars: 25,
                class_name: "client-title",
                // label: HYPRLAND.active.client.bind("title"),
                setup: (self) => self.hook(HYPRLAND.active.client, label => { // Hyprland.active.client
                    label.label = HYPRLAND.active.client.title.length === 0 ? `Workspace ${HYPRLAND.active.workspace.id}` : HYPRLAND.active.client.title;
                }),
            })
        ]
    })
}

// const Hyprland = (await import('resource:///com/github/Aylur/ags/service/hyprland.js')).default;
// return Widget.Scrollable({
//     hexpand: true, vexpand: true,
//     hscroll: 'automatic', vscroll: 'never',
//     child: Widget.Box({
//         vertical: true,
//         children: [
//             Widget.Label({
//                 xalign: 0,
//                 truncate: 'end',
//                 maxWidthChars: 1, // Doesn't matter, just needs to be non negative
//                 // className: 'txt-smaller bar-wintitle-topdesc txt',
//                 class_name: "client-title",
//                 setup: (self) => self.hook(Hyprland.active.client, label => { // Hyprland.active.client
//                     label.label = Hyprland.active.client.class.length === 0 ? 'Desktop' : Hyprland.active.client.class;
//                 }),
//             }),
//             Widget.Label({
//                 xalign: 0,
//                 truncate: 'end',
//                 maxWidthChars: 1, // Doesn't matter, just needs to be non negative
//                 // className: 'txt-smallie bar-wintitle-txt',
//                 class_name: "client-title",
//                 setup: (self) => self.hook(Hyprland.active.client, label => { // Hyprland.active.client
//                     label.label = Hyprland.active.client.title.length === 0 ? `Workspace ${Hyprland.active.workspace.id}` : Hyprland.active.client.title;
//                 }),
//             })
//         ],
//     }),
// })
// }

export { ClientTitle }

// const WindowTitle = async () => {
//     try {
//         const Hyprland = (await import('resource:///com/github/Aylur/ags/service/hyprland.js')).default;
//         return Widget.Scrollable({
//             hexpand: true, vexpand: true,
//             hscroll: 'automatic', vscroll: 'never',
//             child: Widget.Box({
//                 vertical: true,
//                 children: [
//                     Widget.Label({
//                         xalign: 0,
//                         truncate: 'end',
//                         maxWidthChars: 1, // Doesn't matter, just needs to be non negative
//                         className: 'txt-smaller bar-wintitle-topdesc txt',
//                         setup: (self) => self.hook(Hyprland.active.client, label => { // Hyprland.active.client
//                             label.label = Hyprland.active.client.class.length === 0 ? 'Desktop' : Hyprland.active.client.class;
//                         }),
//                     }),
//                     Widget.Label({
//                         xalign: 0,
//                         truncate: 'end',
//                         maxWidthChars: 1, // Doesn't matter, just needs to be non negative
//                         className: 'txt-smallie bar-wintitle-txt',
//                         setup: (self) => self.hook(Hyprland.active.client, label => { // Hyprland.active.client
//                             label.label = Hyprland.active.client.title.length === 0 ? `Workspace ${Hyprland.active.workspace.id}` : Hyprland.active.client.title;
//                         }),
//                     })
//                 ]
//             })
//         });
//     } catch {
//         return null;
//     }
// }

// export default async (monitor = 0) => {
//     const optionalWindowTitleInstance = await WindowTitle();
//     return Widget.EventBox({
//         onScrollUp: () => {
//             // Indicator.popup(1); // Since the brightness and speaker are both on the same window
//             // Brightness[monitor].screen_value += 0.05;
//             App.toggleWindow('sideleft');
//         },
//         onScrollDown: () => {
//             // Indicator.popup(1); // Since the brightness and speaker are both on the same window
//             // Brightness[monitor].screen_value -= 0.05;
//             App.toggleWindow('sideleft');
//         },
//         onPrimaryClick: () => {
//             App.toggleWindow('sideleft');
//         },
//         child: Widget.Box({
//             homogeneous: false,
//             children: [
//                 Widget.Box({ className: 'bar-corner-spacing' }),
//                 Widget.Overlay({
//                     overlays: [
//                         Widget.Box({ hexpand: true }),
//                         Widget.Box({
//                             className: 'bar-sidemodule', hexpand: true,
//                             child: Widget.Box({
//                                 vertical: true,
//                                 className: 'bar-space-button',
//                                 child: optionalWindowTitleInstance,
//                             }),
//                         }),
//                     ]
//                 })
//             ]
//         })
//     });
// }

