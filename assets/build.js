const esbuild = require("esbuild");
const fs = require("fs-extra");
const path = require("path");

const args = process.argv.slice(2);
const watch = args.includes("--watch");
const deploy = args.includes("--deploy");

// Paths
const OUTPUT_DIR = path.join(__dirname, "..", "priv", "static", "assets");
const NODE_RED_SOURCE = path.join(
  __dirname,
  "node_modules",
  "@node-red",
  "editor-client",
);
const XTERM_SOURCE = path.join(__dirname, "node_modules", "@xterm", "xterm");
const NODES_SOURCE = path.join(__dirname, "nodes");
const NODE_MODULES = path.join(__dirname, "node_modules");

// Ensure output directory exists
fs.ensureDirSync(OUTPUT_DIR);

function copyNodeRedFiles() {
  console.log("Copying Node-RED Editor Client files...");
  const staticDirs = ["locales", "public"];
  staticDirs.forEach((dir) => {
    const source = path.join(NODE_RED_SOURCE, dir);
    const destination = path.join(OUTPUT_DIR, "node-red", dir);
    fs.copySync(source, destination);
    console.log(`Copied ${dir} to ${destination}`);
  });
}

function copyNodeRedNodes() {
  console.log("Copying Node-RED Editor Nodes files ...");
  const staticDirs = ["icons", "locales"];
  staticDirs.forEach((dir) => {
    const source = path.join(NODES_SOURCE, dir);
    const destination = path.join(OUTPUT_DIR, "nodes", dir);
    fs.copySync(source, destination);
    console.log(`Copied ${dir} to ${destination}`);
  });
  const source = path.join(NODES_SOURCE, "core");
  const destination = path.join(OUTPUT_DIR, "nodes", "nodes.html");
  const htmlFiles = fs
    .readdirSync(source)
    .filter((file) => file.endsWith(".html"));

  // Read all HTML files and concatenate their contents
  let htmlContent = "";
  htmlFiles.forEach((file) => {
    const filePath = path.join(source, file);
    const content = fs.readFileSync(filePath, "utf8");
    htmlContent += content; // Concatenate the content of each file
  });
  fs.writeFileSync(destination, htmlContent);
  console.log(`Copied ${source} to ${destination}`);
}

(async function build() {
  try {
    console.log("Starting build process...");

    // Clean the output directory
    fs.emptyDirSync(OUTPUT_DIR);

    copyNodeRedFiles();

    copyNodeRedNodes();

    await esbuild.build({
      entryPoints: [path.join(__dirname, "js", "app.js")],
      outdir: OUTPUT_DIR,
      bundle: true,
      splitting: false,
      target: "es2017",
      format: "esm",
      minify: deploy,
      sourcemap: deploy ? undefined : "linked",
    });

    await esbuild.build({
      entryPoints: [path.join(__dirname, "js", "xterm.js")],
      outdir: OUTPUT_DIR,
      bundle: true,
      splitting: false,
      target: "es2017",
      format: "esm",
      minify: deploy,
      sourcemap: deploy ? undefined : "linked",
    });

    console.log("Build process completed successfully!");
  } catch (error) {
    console.error("Build process failed:", error);
  }
})();
