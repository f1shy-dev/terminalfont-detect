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

function detectLibc() {
  if (platform === "linux") {
    try {
      const { GLIBC } = require("glibc-version") || {};
      if (GLIBC) return "gnu";
    } catch (_) {}
    try {
      // musl environments often have musl in ldd output
      const { execSync } = require("child_process");
      const out = execSync("ldd --version || true", {
        stdio: ["ignore", "pipe", "ignore"],
      }).toString();
      if (/musl/i.test(out)) return "musl";
    } catch (_) {}
    // default to gnu if unsure
    return "gnu";
  }
  return "";
}

function tryRequirePlatformPackage() {
  const os = mapPlatformToNpm(platform);
  const cpu = mapArchToNpm(arch);
  const libc = os === "linux" ? detectLibc() : "";
  const base = `@vishyfishy2/terminalfont-detect-${os}-${cpu}`;
  const name = libc ? `${base}-${libc}` : base;
  try {
    const mod = require(name);
    if (mod && mod.binaryPath) return mod.binaryPath;
  } catch (_) {}
  // try fallback to gnu if musl not found (or vice versa)
  if (os === "linux") {
    const alt = libc === "musl" ? `${base}-gnu` : `${base}-musl`;
    try {
      const mod = require(alt);
      if (mod && mod.binaryPath) return mod.binaryPath;
    } catch (_) {}
  }
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
    arch === "x64" ? "x86_64" : arch === "arm64" ? "aarch64" : arch;
  const base = join(__dirname, "bin", `${os}-${cpu}`);
  const name =
    os === "windows" ? "terminalfont-detect.exe" : "terminalfont-detect";
  return join(base, name);
}

const binaryPath = tryRequirePlatformPackage() || fallbackBundled();

module.exports = { binaryPath };
