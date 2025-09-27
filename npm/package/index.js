const { join } = require("path");
const { platform, arch } = process;

function mapArchToNpm(a) {
  if (a === "x64") return "x64";
  if (a === "arm64") return "arm64";
  return a;
}

function mapPlatformToNpm(p) {
  if (p === "darwin") return "darwin";
  if (p === "win32") return "win32";
  if (p === "linux") return "linux";
  return p;
}

function tryRequirePlatformPackage() {
  const os = mapPlatformToNpm(platform);
  const cpu = mapArchToNpm(arch());
  const name = `@vishyfishy2/terminalfont-detect-${os}-${cpu}`;
  try {
    const mod = require(name);
    if (mod && mod.binaryPath) return mod.binaryPath;
  } catch (_) {}
  return null;
}

function fallbackBundled() {
  // Fallback to legacy layout if present
  const os =
    platform === "win32"
      ? "windows"
      : platform === "darwin"
      ? "macos"
      : "linux";
  const cpu =
    arch() === "x64" ? "x86_64" : arch() === "arm64" ? "aarch64" : arch();
  const base = join(__dirname, "bin", `${os}-${cpu}`);
  const name =
    os === "windows" ? "terminalfont-detect.exe" : "terminalfont-detect";
  return join(base, name);
}

const binaryPath = tryRequirePlatformPackage() || fallbackBundled();

module.exports = { binaryPath };
