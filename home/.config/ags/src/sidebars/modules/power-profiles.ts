import powerProfiles from 'resource:///com/github/Aylur/ags/service/powerprofiles.js';


const PowerProfiles = () => Widget.Box({
    class_name: "power-profiles",
    child: Widget.Box({
        class_name: "icons",
        children: [
            Widget.Button({
                on_clicked: () => { powerProfiles.active_profile = 'power-saver'; },
                child: Widget.Box({
                    vertical: true,
                    children: [
                        Widget.Icon({
                            icon: "power-mode-power-saver-symbolic",
                            size: 28,
                            css: powerProfiles.bind('active_profile').as(p => p === "power-saver" ? "color: rgba(97, 255, 202, 1.0);" : "color: rgba(250, 247, 254, 1.00);")
                        }),
                        Widget.Label({ class_name: "label", label: "power saver" })
                    ]
                }),
            }),
            Widget.Box({ hexpand: true }),
            Widget.Button({
                on_clicked: () => { powerProfiles.active_profile = 'balanced'; },
                child: Widget.Box({
                    vertical: true,
                    children: [
                        Widget.Icon({
                            icon: "power-mode-balanced-symbolic",
                            size: 28,
                            css: powerProfiles.bind('active_profile').as(p => p === "balanced" ? "color: rgba(241, 192, 125, 1.0);" : "color: rgba(250, 247, 254, 1.00);")
                        }),
                        Widget.Label({ class_name: "label", label: "balanced" })
                    ]
                }),
            }),
            Widget.Box({ hexpand: true }),
            Widget.Button({
                on_clicked: () => { powerProfiles.active_profile = 'performance'; },
                child: Widget.Box({
                    vertical: true,
                    children: [
                        Widget.Icon({
                            icon: "power-mode-performance-symbolic",
                            size: 28,
                            css: powerProfiles.bind('active_profile').as(p => p === "performance" ? "color: rgba(255, 103, 103, 1.0);" : "color: rgba(250, 247, 254, 1.00);")
                        }),
                        Widget.Label({ class_name: "label", label: "performance" })
                    ]
                }),
            }),
        ]
    }),

})


export default PowerProfiles;