import { Gio, GLib } from "astal";

export enum LogLevel {
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
}

export const Logger = {
    level: LogLevel.DEBUG,
    logfile: `${GLib.get_home_dir()}/.config/ags/log`,

    fileLogger(message: string) {
        const file = Gio.File.new_for_path(this.logfile);
        let stream: Gio.FileOutputStream | null = null;

        try {
            stream = file.append_to(Gio.FileCreateFlags.NONE, null);
        } catch (e) {
            console.log(`Error opening log file: ${e}`);
            return;
        }

        try {
            stream.write_all(message + "\n", null);
        } catch (e) {
            console.log(`Error writing to log file: ${e}`);
        } finally {
            stream.close(null);
        }
    },

    log(level: LogLevel, message: string) {
        if (level < this.level) return;

        const timestamp = new Date().toISOString();
        const levelName = LogLevel[level].toUpperCase().padStart(5, " "); // Get enum name as string
        const fullMessage = `[${timestamp}] [${levelName}] ${message}`;

        this.fileLogger(fullMessage);
    },

    setLevel(level: LogLevel) {
        this.level = level;
    },

    debug(msg: string) {
        this.log(LogLevel.DEBUG, msg);
    },
    info(msg: string) {
        this.log(LogLevel.INFO, msg);
    },
    warn(msg: string) {
        this.log(LogLevel.WARN, msg);
    },
    error(msg: string) {
        this.log(LogLevel.ERROR, msg);
    },
};
