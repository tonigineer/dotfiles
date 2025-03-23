import { App } from "astal/gtk3";
import { exec, monitorFile } from "astal";
import { Logger } from "@logging";

export function compileScss(): string {
    let error: any = null;

    try {
        exec(`sass ${SRC}/styles.scss ${TMP}/styles.css`);
        App.apply_css("/tmp/styles.css");
        return `${TMP}/styles.css`;
    } catch (err) {
        error = err;
        return "";
    } finally {
        if (error) {
            Logger.error(`Compiling scss files: ${error}`);
        }
        Logger.info("styles.css was compiled ...");
    }
}

// Hot Reload Scss
(function () {
    const scssFiles = exec(`find -L ${SRC} -iname '*.scss'`).split("\n");

    // Compile scss files at startup
    // compileScss();

    scssFiles.forEach((file: any) => monitorFile(file, compileScss));
})();
