pragma Singleton

import "root:/config"
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property list<int> values
    property int refCount


     property int hz: Config.bar.media.cavaHz
     property int bars: Config.bar.media.cavaBars
     property int max_range: Config.bar.media.cavaMaxRange

    Process {
        running: true
        command: ["sh", "-c", `printf '[general]\nframerate=${hz}\nbars=${bars}\n[output]\nchannels=mono\nmethod=raw\nraw_target=/dev/stdout\ndata_format=ascii\nascii_max_range=${max_range}' | cava -p /dev/stdin`]
        stdout: SplitParser {
            onRead: data => {
                if (root.refCount)
                    root.values = data.slice(0, -1).split(";").map(v => parseInt(v, 10));
            }
        }
    }
}
