import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';


const WINDOW_NAME = "terminal";

const outputPanel = Widget.Revealer({
    class_name: "output",
    transitionDuration: 0,
    transition: "none",
    reveal_child: false,
    child: Widget.Label({
        hpack: "start",
        truncate: "end",
    })
})

const commandLine = Widget.Box({
    class_name: "commandline",
    attribute: { OUTPUT_LENGTH: 20 },
    children: [
        Widget.Label({
            class_name: "prompt",
            label: "~ ❯ "
        }),
        Widget.Entry({
            class_name: "command",
            attribute: {
                active_mode: false
            },
            hexpand: true,
            placeholder_text: 'press ? to enter active mode',
            on_accept: ({ text }) => {
                Utils.execAsync(["bash", "-c", text + " &"])
                commandLine.children[1].text = "";
                App.closeWindow("terminal");
            },
            on_change: ({ text }) => {
                if (!text?.startsWith("?")) {
                    commandLine.children[0].css = "color: rgba(250, 247, 254, 1.00);"
                    commandLine.children[0].label = "~ ❯ ";
                    outputPanel.reveal_child = false;
                } else {
                    commandLine.children[0].css = "color: rgba(255, 103, 103, 1.0);"
                    commandLine.children[0].label = "~ ❯ # ";
                    const out = Utils.exec(["bash", "-c", text.slice(1)]);
                    let lines = out.split("\n").slice(0, 20);
                    while (lines.length < 20) lines.push("");
                    outputPanel.child.label = lines.join("\n");
                    outputPanel.reveal_child = true;
                }
            }
        })
    ]
})

const TerminalWindow = Widget.Window({
    name: WINDOW_NAME,
    monitor: Hyprland.active.bind("monitor").as(m => m.id),
    anchor: ["top"],
    layer: "overlay",
    margins: [15, 15],
    visible: false,
    keymode: "exclusive",
    class_name: "terminal",
    child: Widget.Box({
        vertical: true,
        vexpand: true,
        children: [commandLine, outputPanel]
    }),
    setup: self => self.keybind("Escape", () => {
        commandLine.children[1].text = "";
        App.closeWindow(WINDOW_NAME)
    }),
})

export default TerminalWindow;