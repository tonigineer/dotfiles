import { CONFIG } from "./../../config";


const UPDATE_COMMAND = 'yay -Sy>/dev/null 2>&1 && yay -Qu | sort';

// Using the poll of only one variable to also update 
// second variable. Saving resources.
const numUpdates = Variable(0, {
    poll: [CONFIG.widgets.resources.poll_rates.updates, ['bash', '-c', UPDATE_COMMAND], out => {
        listOfUpdates.value = out;
        return out === "" ? 0 : Number(out.split('\n').length);
    }]
})

const listOfUpdates = Variable("");


const UpdateIndicator = () => Widget.Revealer({
    class_name: "updates",
    revealChild: false,
    transitionDuration: 1000,
    transition: 'slide_right',
    child: Widget.Button({
        on_clicked: () => Utils.execAsync(["bash", "-c", `${CONFIG.apps.updater}`]).catch(print),
        child: Widget.Box({
            children: [
                Widget.Label({
                    class_name: "updates icon",
                    label: "󱧘 "
                }),
                Widget.Label({
                    class_name: "updates label",
                    label: numUpdates.value.toString()
                }),
            ]
        }),
    }),
    setup: self => self.hook(numUpdates, () => {
        self.reveal_child = numUpdates.value > 0;
        self.child.child.children[1].label = numUpdates.value.toString();
        self.tooltip_text = "Updates pending for:\n\n" + listOfUpdates.value;
    })
})

export { UpdateIndicator }
