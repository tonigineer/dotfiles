import "root:/services"
import "root:/utils"
import Quickshell.Io
import QtQuick

Image {
    id: root

    property string path
    property string hash
    readonly property string cachePath: `${Paths.imagecache}/${hash}@${width}x${height}.png`.slice(7)

    asynchronous: true
    cache: false
    fillMode: Image.PreserveAspectCrop
    sourceSize.width: width
    sourceSize.height: height

    // onPathChanged: shaProc.exec(["sha256sum", path.replace("file://", "")])
    onPathChanged: {
        shaProc.command = ["sha256sum", path.replace("file://", "")];
        shaProc.running = true;          // or shaProc.startDetached();
    }

    onCachePathChanged: {
        if (hash)
            source = cachePath;
    }

    onStatusChanged: {
        if (source == cachePath && status === Image.Error)
            source = path;
        else if (source == path && status === Image.Ready) {
            Paths.mkdir(Paths.imagecache);
            const grabPath = cachePath;
            grabToImage(res => res.saveToFile(grabPath));
        }
    }

    Process {
        id: shaProc

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: chunk => root.hash = chunk.trim().split(" ")[0]
        }
    }

    // Process {
    //     id: shaProc

    //     stdout: StdioCollector {
    //         onStreamFinished: root.hash = text.split(" ")[0]
    //     }
    // }
}
