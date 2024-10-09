import * as system from "system";

const in_file = `${App.configDir}/src/index.ts`;
const in_scss = `${App.configDir}/scss/index.scss`;
const out_file = "/tmp/ags/main.js";
const out_css = "/tmp/ags/style.css";

Utils.monitorFile("./src", () => {
    console.log("Rebuilding...");
    Utils.subprocess("ags")?.disconnect(0);
    system.exit(0);
});

Utils.monitorFile(in_scss, async () => {
    console.log(
        ["bun", "run", "--cwd", App.configDir, "sass", in_scss, out_css].join(" ")
    );
    await Utils.execAsync(
        ["bun", "run", "--cwd", App.configDir, "sass", in_scss, out_css]
    );
    App.resetCss();
    App.applyCss(out_css);
});

try {
    console.log(
        ["bun", "run", "--cwd", App.configDir, "sass", in_scss, out_css].join(" ")
    );
    await Utils.execAsync(
        ["bun", "run", "--cwd", App.configDir, "sass", in_scss, out_css]
    );
    App.applyCss(out_css);

    console.log(
        ["bun", "build", in_file, "--outdir", out_file, "--external", "resource://*", "--external", "gi://*"].join(" ")
    );
    await Utils.execAsync([
        "bun",
        "build",
        in_file,
        "--outfile",
        out_file,
        "--external",
        "resource://*",
        "--external",
        "gi://*",
        "--external",
        "file://*",
    ]);
    await import(`file://${out_file}`);
} catch (error) {
    console.error(error);
    let current = "";
    try {
        current = await Utils.readFileAsync("/tmp/ags_error.log");
    } catch (e) { }
    await Utils.writeFile(`${current} \n ${error}`, "/tmp/ags_error.log");
}

export { };
