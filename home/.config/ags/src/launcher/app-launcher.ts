import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';


App.addIcons(`${App.configDir}/assets`)

const WINDOW_NAME = "AppLauncher"

const ApplicationItem = (application) => {
    return Widget.Button({
        attribute: { application },
        on_clicked: () => {
            App.closeWindow(WINDOW_NAME)
            application.launch()
        },
        child: Widget.Box({
            class_name: "application-item",
            hpack: "start",
            children: [
                Widget.Icon({
                    class_name: "icon",
                    icon: Utils.lookUpIcon(application.icon_name)
                        ? application.icon_name
                        : "image-missing",
                    size: 30,
                }),
                Widget.Label({
                    class_name: "title",
                    label: application.name,
                    truncate: "end",
                }),
            ],
        })
    })
}

const { query } = await Service.import("applications")
let Applications = query("").map(ApplicationItem)

function isValidUrlWithRegex(str: string): boolean {
    const pattern = new RegExp('^(https?:\\/\\/)?' +                        // Protocol
        '((([a-zA-Z\\d]([a-zA-Z\\d-]*[a-zA-Z\\d])*)\\.)+[a-zA-Z]{2,}|' +    // Domain name
        '((\\d{1,3}\\.){3}\\d{1,3}))' +                                     // OR IP (v4) address
        '(\\:\\d+)?(\\/[-a-zA-Z\\d%_.~+]*)*' +                              // Port and path
        '(\\?[;&a-zA-Z\\d%_.~+=-]*)?' +                                     // Query string
        '(\\#[-a-zA-Z\\d_]*)?$', 'i');                                      // Fragment locator
    return !!pattern.test(str);
}

function EntryBar() {
    const Icon = Widget.Icon({
        class_name: "icon",
        css: "color: white;",
        icon: "icon-magnifying-glas",
        size: 26,
    })

    const EntryResponse = Widget.Box({
        child: Widget.Icon()
    })

    const EntryResponseText = Widget.Box({
        class_name: "response-text",
        child: Widget.Label()
    })

    const Entry = Widget.Entry({
        attribute: {
            bash_mode: false
        },
        hexpand: true,
        class_name: "text",
        // placeholder_text: 'type here',
        // text: 'S  initial text',
        on_accept: ({ text }) => {
            if (text === null) return

            if (Entry.attribute.bash_mode) {
                Utils.execAsync(["bash", "-c", text]);
                // App.toggleWindow(WINDOW_NAME)
                return;
            }

            const results = Applications.filter((item) => item.visible);
            App.toggleWindow(WINDOW_NAME)

            if (isValidUrlWithRegex(text)) {
                Utils.execAsync(["bash", "-c", `firefox -url ${text}`]);
                return;
            }

            if (results.length === 1) {
                results[0].attribute.application.launch()
                return;
            }

            if (text === "") return;

            Utils.execAsync(["bash", "-c", `firefox -url 'https://duckduckgo.com/?t=ffab&q=${text.replace(" ", "+")}'`]);
        },

        // filter out the list
        on_change: ({ text }) => {
            // EntryResponse.child = Widget.Icon()
            if (Entry.attribute.bash_mode) {
                return;
            }

            if (text === null) return;

            if (text === "$") {
                Entry.attribute.bash_mode = true;
                Entry.css = "color: indianred;";
                Entry.text = "";
                EntryResponseText.child.label = "Run command";
                EntryResponse.child = Widget.Icon({
                    icon: "icon-bash",
                    size: 22
                })
                return;
            }

            if (text === "") {
                Applications.forEach(item => {
                    item.visible = false;
                });
                return;
            }

            if (isValidUrlWithRegex(text)) {
                const reachable = Utils.exec(["bash", "-c", `curl -Is --max-time 0.1 http://${text} | head -n 1`])
                if (reachable) {
                    EntryResponse.child = Widget.Icon({
                        icon: "icon-firefox",
                        size: 22
                    })
                    EntryResponseText.child.label = "Open Website"
                }
                return;
            }

            let findings = 0;
            Applications.forEach(item => {
                item.visible = item.attribute.application.match(text);
                if (item.visible) findings += 1;
            });

            EntryResponse.child = Widget.Icon({
                icon: findings === 0 ? "icon-duckduckgo" : findings === 1 ? "icon-checkmark" : "",
                size: 22
            })

            EntryResponseText.child.label = findings === 0 ? "Search WEB" : findings === 1 ? "Run program" : ""
        },
        setup: self => self.hook(App, (_, windowName, visible) => {
            Applications.forEach(item => {
                item.visible = false;
            });

            if (visible) {
                // Applications = query("").map(ApplicationItem)

                Applications.forEach(item => {
                    item.visible = false;
                });

                // Reset changes from bash mode
                Entry.attribute.bash_mode = false;
                Entry.css = "color: white";
                Entry.text = ".";
                Entry.text = "";

                Entry.grab_focus();
            }
        }),
    })

    return Widget.Box({
        class_name: "entry-box",
        children: [
            Icon,
            Entry,
            EntryResponseText,
            EntryResponse
        ]
    })
}

const ResultList = Widget.Scrollable({
    class_name: "result-list",
    hscroll: 'never',
    css: 'min-height: 165px;',
    child: Widget.Box(
        { vertical: true, children: Applications })
})

const MainWindow = () => Widget.Box({
    class_name: "app-launcher",
    vertical: true,
    children: [
        EntryBar(),
        ResultList
    ]
})

const AppLauncher = Widget.Window({
    name: WINDOW_NAME,
    monitor: Hyprland.active.bind("monitor").as(m => AppLauncher.visible ? AppLauncher.monitor : m.id),
    visible: false,
    layer: "overlay",
    exclusivity: "ignore",
    // popup: true,
    keymode: "exclusive",
    anchor: ["top", "left", "top", "right"],
    margins: [50, 750, 0, 750],
    child: MainWindow(),
    setup: self => self.keybind("Escape", () => {
        App.toggleWindow(WINDOW_NAME)
    })
}).hook(Hyprland, self => { self.visible = self.visible && Hyprland.active.monitor.id === self.monitor })

export default AppLauncher;
