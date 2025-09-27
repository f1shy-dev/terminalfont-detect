const { join } = require("path");
const { platform, arch } = process;

function mapArch(a) {
  if (a === "x64") return "x86_64";
  if (a === "arm64") return "aarch64";
  return a;
}

function mapPlatform(p) {
  if (p === "darwin") return "macos";
  if (p === "win32") return "windows";
  if (p === "linux") return "linux";
  return p;
}

function getBinaryPath() {
  const p = mapPlatform(platform);
  const a = mapArch(arch());
  const base = join(__dirname, "bin", `${p}-${a}`);
  const name =
    p === "windows" ? "terminalfont-detect.exe" : "terminalfont-detect";
  return join(base, name);
}

module.exports = {
  binaryPath: getBinaryPath(),
};
