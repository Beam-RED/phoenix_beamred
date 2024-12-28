const esbuild = require("esbuild");
const fs = require("fs-extra");
const path = require("path");
console.log("tes");

// Paths
const OUTPUT_DIR = path.join(__dirname, "..", "priv", "static", "assets");
const NODE_RED_SOURCE = path.join(
  __dirname,
  "node_modules",
  "@node-red",
  "editor-client",
);
const NODE_MODULES = path.join(__dirname, "node_modules");

// Ensure output directory exists
fs.ensureDirSync(OUTPUT_DIR);

// Copy Node-RED Editor Client static files
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

(async function build() {
  try {
    console.log("Starting build process...");

    // Clean the output directory
    fs.emptyDirSync(OUTPUT_DIR);

    // Copy Node-RED static files
    copyNodeRedFiles();

    console.log("Build process completed successfully!");
  } catch (error) {
    console.error("Build process failed:", error);
  }
})();
