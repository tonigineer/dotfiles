pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real cpuPerc
    property real cpuTemp
    property string gpuType: "NONE"
    property real gpuPerc
    property real gpuTemp
    property real memUsed
    property real memTotal
    readonly property real memPerc: memTotal > 0 ? memUsed / memTotal : 0
    property real storageUsed
    property real storageTotal
    property real storagePerc: storageTotal > 0 ? storageUsed / storageTotal : 0
    property int updatesCount: 0
    property var updatesList: []

    property real lastCpuIdle
    property real lastCpuTotal

    property int refCount: 1

    function formatKib(kib: real): var {
        const mib = 1024;
        const gib = 1024 ** 2;
        const tib = 1024 ** 3;

        if (kib >= tib)
            return {
                value: kib / tib,
                unit: "TiB"
            };
        if (kib >= gib)
            return {
                value: kib / gib,
                unit: "GiB"
            };
        if (kib >= mib)
            return {
                value: kib / mib,
                unit: "MiB"
            };
        return {
            value: kib,
            unit: "KiB"
        };
    }

    Timer {
        running: root.refCount > 0
        interval: 3000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
            storage.running = true;
            gpuUsage.running = true;
            sensors.running = true;
            // updatesCheck.running = true;
        }
    }

    Timer {
        running: true
        interval: 15 * 60 * 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            updatesCheck.running = true;
        }
    }

    Process {
        id: updatesCheck
        command: ["sh", "-c", "yay -Sy; yay -Qu"]

        stdout: SplitParser {
            splitMarker: "\n"
            property string buf: ""
            onRead: chunk => {
                buf += chunk + "\n";
                const pkgs = buf.trim().split("\n").filter(l => l.length && l.includes("->")).sort();
                root.updatesList = pkgs;
                root.updatesCount = pkgs.length;
            }
        }
    }

    // Process {
    //     id: updatesCheck
    //     command: ["sh", "-c", "yay -Sy; yay -Qu"]
    //     stdout: StdioCollector {
    //         onStreamFinished: {
    //             const pkgs = text.trim().split('\n').filter(l => l.length && l.includes('->')).sort();
    //             root.updatesList = pkgs;
    //             root.updatesCount = pkgs.length;
    //         }
    //     }
    // }

    FileView {
        id: stat

        path: "/proc/stat"
        onLoaded: {
            const data = text().match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
            if (data) {
                const stats = data.slice(1).map(n => parseInt(n, 10));
                const total = stats.reduce((a, b) => a + b, 0);
                const idle = stats[3] + (stats[4] ?? 0);

                const totalDiff = total - root.lastCpuTotal;
                const idleDiff = idle - root.lastCpuIdle;
                root.cpuPerc = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0;

                root.lastCpuTotal = total;
                root.lastCpuIdle = idle;
            }
        }
    }

    FileView {
        id: meminfo

        path: "/proc/meminfo"
        onLoaded: {
            const data = text();
            root.memTotal = parseInt(data.match(/MemTotal: *(\d+)/)[1], 10) || 1;
            root.memUsed = (root.memTotal - parseInt(data.match(/MemAvailable: *(\d+)/)[1], 10)) || 0;
        }
    }

    Process {
        id: storage
        command: ["sh", "-c", "df | grep '^/dev/' | awk '{print $1, $3, $4}'"]

        stdout: SplitParser {
            splitMarker: "\n"
            property string buf: ""

            onRead: chunk => {
                buf += chunk + "\n";

                const deviceMap = new Map();
                for (const line of buf.trim().split("\n")) {
                    if (!line.length)
                        continue;
                    const parts = line.split(/\s+/);
                    if (parts.length < 3)
                        continue;
                    const device = parts[0];
                    const used = parseInt(parts[1], 10) || 0;
                    const avail = parseInt(parts[2], 10) || 0;

                    if (!deviceMap.has(device) || used + avail > deviceMap.get(device).used + deviceMap.get(device).avail) {
                        deviceMap.set(device, {
                            used,
                            avail
                        });
                    }
                }

                let totalUsed = 0;
                let totalAvail = 0;
                for (const {
                    used,
                    avail
                } of deviceMap.values()) {
                    totalUsed += used;
                    totalAvail += avail;
                }
                root.storageUsed = totalUsed;
                root.storageTotal = totalUsed + totalAvail;
            }
        }
    }

    // Process {
    //     id: storage

    //     command: ["sh", "-c", "df | grep '^/dev/' | awk '{print $1, $3, $4}'"]
    //     stdout: StdioCollector {
    //         onStreamFinished: {
    //             const deviceMap = new Map();

    //             for (const line of text.trim().split("\n")) {
    //                 if (line.trim() === "")
    //                     continue;

    //                 const parts = line.trim().split(/\s+/);
    //                 if (parts.length >= 3) {
    //                     const device = parts[0];
    //                     const used = parseInt(parts[1], 10) || 0;
    //                     const avail = parseInt(parts[2], 10) || 0;

    //                     // Only keep the entry with the largest total space for each device
    //                     if (!deviceMap.has(device) || (used + avail) > (deviceMap.get(device).used + deviceMap.get(device).avail)) {
    //                         deviceMap.set(device, {
    //                             used: used,
    //                             avail: avail
    //                         });
    //                     }
    //                 }
    //             }

    //             let totalUsed = 0;
    //             let totalAvail = 0;

    //             for (const [device, stats] of deviceMap) {
    //                 totalUsed += stats.used;
    //                 totalAvail += stats.avail;
    //             }

    //             root.storageUsed = totalUsed;
    //             root.storageTotal = totalUsed + totalAvail;
    //         }
    //     }
    // }

    Process {
        id: gpuTypeCheck
        running: true
        command: ["sh", "-c", "if ls /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | grep -q .;" + " then echo GENERIC;" + " elif command -v nvidia-smi >/dev/null;" + "  then echo NVIDIA;" + " else echo NONE; fi"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: chunk => root.gpuType = chunk.trim()
        }
    }

    // Process {
    //     id: gpuTypeCheck

    //     running: true
    //     command: ["sh", "-c", "if ls /sys/class/drm/card*/device/gpu_busy_percent 2>/dev/null | grep -q .; then echo GENERIC; elif command -v nvidia-smi >/dev/null; then echo NVIDIA; else echo NONE; fi"]
    //     stdout: StdioCollector {
    //         onStreamFinished: root.gpuType = text.trim()
    //     }
    // }

    Process {
        id: gpuUsage
        command: root.gpuType === "GENERIC" ? ["sh", "-c", "cat /sys/class/drm/card*/device/gpu_busy_percent"] : root.gpuType === "NVIDIA" ? ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"] : ["echo"]

        stdout: SplitParser {
            splitMarker: "\n"
            property string buf: ""
            onRead: chunk => {
                buf += chunk + "\n";

                if (root.gpuType === "GENERIC") {
                    const percs = buf.trim().split("\n").filter(l => l.length);
                    if (percs.length) {
                        const sum = percs.reduce((a, d) => a + parseInt(d, 10), 0);
                        root.gpuPerc = sum / percs.length / 100;
                    }
                } else if (root.gpuType === "NVIDIA") {
                    const parts = buf.trim().split(",");
                    if (parts.length >= 2) {
                        root.gpuPerc = parseInt(parts[0], 10) / 100;
                        root.gpuTemp = parseInt(parts[1], 10);
                    }
                } else {
                    root.gpuPerc = 0;
                    root.gpuTemp = 0;
                }
            }
        }
    }

    // Process {
    //     id: gpuUsage

    //     command: root.gpuType === "GENERIC" ? ["sh", "-c", "cat /sys/class/drm/card*/device/gpu_busy_percent"] : root.gpuType === "NVIDIA" ? ["nvidia-smi", "--query-gpu=utilization.gpu,temperature.gpu", "--format=csv,noheader,nounits"] : ["echo"]
    //     stdout: StdioCollector {
    //         onStreamFinished: {
    //             if (root.gpuType === "GENERIC") {
    //                 const percs = text.trim().split("\n");
    //                 const sum = percs.reduce((acc, d) => acc + parseInt(d, 10), 0);
    //                 root.gpuPerc = sum / percs.length / 100;
    //             } else if (root.gpuType === "NVIDIA") {
    //                 const [usage, temp] = text.trim().split(",");
    //                 root.gpuPerc = parseInt(usage, 10) / 100;
    //                 root.gpuTemp = parseInt(temp, 10);
    //             } else {
    //                 root.gpuPerc = 0;
    //                 root.gpuTemp = 0;
    //             }
    //         }
    //     }
    // }

    Process {
        id: sensors
        command: ["sensors"]
        environment: ({
                LANG: "C",
                LC_ALL: "C"
            })

        stdout: SplitParser {
            splitMarker: "\n"
            property string buf: ""
            onRead: chunk => {
                buf += chunk + "\n";

                let cpuTemp = buf.match(/(?:Package id [0-9]+|Tdie):\s+((\+|-)?[0-9.]+)(?:°| )C/);
                if (!cpuTemp)
                    cpuTemp = buf.match(/Tctl:\s+((\+|-)?[0-9.]+)(?:°| )C/);
                if (cpuTemp)
                    root.cpuTemp = parseFloat(cpuTemp[1]);

                if (root.gpuType !== "GENERIC")
                    return;
                let eligible = false;
                let sum = 0;
                let count = 0;
                for (const line of buf.trim().split("\n")) {
                    if (line === "Adapter: PCI adapter")
                        eligible = true;
                    else if (line === "")
                        eligible = false;
                    else if (eligible) {
                        let m = line.match(/^(temp[0-9]+|GPU core|edge):\s+\+([0-9]+\.[0-9]+)(?:°| )C/);
                        if (!m)
                            m = line.match(/^(junction|mem):\s+\+([0-9]+\.[0-9]+)(?:°| )C/);
                        if (m) {
                            sum += parseFloat(m[2]);
                            count++;
                        }
                    }
                }
                root.gpuTemp = count ? sum / count : 0;
            }
        }
    }
    // Process {
    //     id: sensors

    //     command: ["sensors"]
    //     environment: ({
    //             LANG: "C",
    //             LC_ALL: "C"
    //         })
    //     stdout: StdioCollector {
    //         onStreamFinished: {
    //             let cpuTemp = text.match(/(?:Package id [0-9]+|Tdie):\s+((\+|-)[0-9.]+)(°| )C/);
    //             if (!cpuTemp)
    //                 // If AMD Tdie pattern failed, try fallback on Tctl
    //                 cpuTemp = text.match(/Tctl:\s+((\+|-)[0-9.]+)(°| )C/);

    //             if (cpuTemp)
    //                 root.cpuTemp = parseFloat(cpuTemp[1]);

    //             if (root.gpuType !== "GENERIC")
    //                 return;

    //             let eligible = false;
    //             let sum = 0;
    //             let count = 0;

    //             for (const line of text.trim().split("\n")) {
    //                 if (line === "Adapter: PCI adapter")
    //                     eligible = true;
    //                 else if (line === "")
    //                     eligible = false;
    //                 else if (eligible) {
    //                     let match = line.match(/^(temp[0-9]+|GPU core|edge)+:\s+\+([0-9]+\.[0-9]+)(°| )C/);
    //                     if (!match)
    //                         // Fall back to junction/mem if GPU doesn't have edge temp (for AMD GPUs)
    //                         match = line.match(/^(junction|mem)+:\s+\+([0-9]+\.[0-9]+)(°| )C/);

    //                     if (match) {
    //                         sum += parseFloat(match[2]);
    //                         count++;
    //                     }
    //                 }
    //             }

    //             root.gpuTemp = count > 0 ? sum / count : 0;
    //         }
    //     }
    // }
}
