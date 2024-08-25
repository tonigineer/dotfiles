const HYPRLAND = await Service.import("hyprland")

const ICONS = {
    1: " ₁",
    2: " ₂",
    3: "󰘐 ₃",
    4: " ₄",
    5: "󰙯 ₅",
    6: "󰓓 ₆",
};

export function Workspaces() {
    // const monitors = {};
    // HYPRLAND.monitors.forEach((i) => monitors[i] = i.name);
    const activeId = HYPRLAND.active.workspace.bind("id")
    const workspaces = HYPRLAND.bind("workspaces")
        .as(ws => ws.sort(({ id: a }, { id: b }) => a - b).map(({ id }) => Widget.Button({
            on_clicked: () => HYPRLAND.messageAsync(`dispatch workspace ${id}`),
            child: Widget.Label(`${ICONS[id]}`),
            class_name: activeId.as(i => `${i === id ? "focused" : "unfocused"}`),
        })))

    return Widget.Box({
        class_name: "workspaces",
        children: workspaces,
    })
}
