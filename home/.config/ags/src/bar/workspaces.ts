import Hyprland from 'resource:///com/github/Aylur/ags/service/hyprland.js';

const ICONS = {
    1: " ₁",
    2: " ₂",
    3: "󰘐 ₃",
    4: " ₄",
    5: "󰙯 ₅",
    6: "󰓓 ₆",
};

const Workspaces = () => {
    // const monitors = {};
    // HYPRLAND.monitors.forEach((i) => monitors[i] = i.name);
    const activeId = Hyprland.active.workspace.bind("id")
    const WORKSPACES = Hyprland.bind("workspaces")
        .as(ws => ws.sort(({ id: a }, { id: b }) => a - b).map(({ id }) => Widget.Button({
            on_clicked: () => Hyprland.messageAsync(`dispatch workspace ${id}`),
            child: Widget.Label(`${ICONS[id]}`),
            class_name: activeId.as(i => `${i === id ? "focused" : "unfocused"}`),
        })))

    return Widget.Box({
        class_name: "workspaces",
        children: WORKSPACES,
    })
}

export default Workspaces;