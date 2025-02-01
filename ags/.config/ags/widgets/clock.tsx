import { Variable, GLib, bind } from "astal"


export default function Clock({ format = "%H:%M" }) {
    const time = Variable<string>("").poll(1000, () =>
        GLib.DateTime.new_now_local().format(format)!)

    return <label
        className="Clock"
        onDestroy={() => time.drop()}
        label={time()}
    />
}
