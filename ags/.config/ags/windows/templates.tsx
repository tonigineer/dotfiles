import { GLib } from "astal";
import { App, Astal, Gdk } from "astal/gtk3";
import { Logger } from "@logging";

const InactivityHandler = {
    timeoutId: null as number | null,
    duration: 5000 as number,

    start(window: any, duration?: number) {
        this.stop();
        this.duration = duration ?? this.duration;

        Logger.debug(`Inactivity timer started: ${window.name}`);

        this.timeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, this.duration, () => {
            Logger.debug(`Inactivity timeout reached: ${window.name}`);
            window.hide();
            this.timeoutId = null;
            return GLib.SOURCE_REMOVE;
        });
    },

    stop() {
        if (this.timeoutId !== null) {
            GLib.source_remove(this.timeoutId);
            this.timeoutId = null;
        }
    },

    reset(window: any) {
        this.start(window);
    },
};

export function InteractiveWindow(
    window_name: String,
    anchors: number,
    createContent: CallableFunction,
    visible: boolean = false,
    timeout: number = 5000
) {
    const { child, keys } = createContent();

    return <window name={window_name}
        application={App}
        anchor={anchors}
        //margin_top={100}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        visible={visible}
        onShow={(self: any) => {
            Logger.debug(`Show window: ${self.name}`);
            InactivityHandler.start(self, timeout);
        }}
        onHide={(self: any) => {
            Logger.debug(`Hide window: ${self.name}`);
            InactivityHandler.stop();
        }}
        keymode={Astal.Keymode.ON_DEMAND}
        events={Gdk.EventMask.POINTER_MOTION_MASK}
        onKeyPressEvent={
            function(self: any, event: Gdk.Event) {
                Logger.debug("Inactivity timer reset by key press");
                InactivityHandler.reset(self);
                keys(self, event)
            }
        }
        onMotionNotifyEvent={(self: any, _event: Gdk.Event) => {
            Logger.debug("Inactivity timer reset mouse movement.");
            InactivityHandler.reset(self);
        }}>
        {child}
    </window >
}
