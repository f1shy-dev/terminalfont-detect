const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const apple_sdk = b.option([]const u8, "apple_sdk", "Path to macOS SDK (e.g. from xcrun --show-sdk-path)");

    // Executable: terminalfont-detect
    const exe = b.addExecutable(.{
        .name = "terminalfont-detect",
        .root_module = b.createModule(.{ .target = target, .optimize = optimize }),
    });
    // Prefer smaller binaries (Zig 0.15 knobs)
    exe.root_module.omit_frame_pointer = true;
    exe.root_module.single_threaded = false;

    // Our C entry
    exe.root_module.addCSourceFile(.{ .file = b.path("src/main.c"), .flags = &.{} });

    // fastfetch include dirs
    exe.root_module.addIncludePath(b.path("fastfetch/src"));
    exe.root_module.addIncludePath(b.path("src/ff_config"));
    // shim includes (e.g. Windows.h case-insensitive bridge for cross-compiles)
    exe.root_module.addIncludePath(b.path("src/ff_shim"));

    // Collect minimal set of fastfetch sources we need for terminal + font detection
    const common_sources: []const []const u8 = &.{
        // core
        "fastfetch/src/common/init.c",
        // "fastfetch/src/common/jsonconfig.c", // not needed for our detector; avoid pulling module registry
        "fastfetch/src/common/properties.c",
        "fastfetch/src/common/parsing.c",
        "fastfetch/src/common/option.c",
        // "fastfetch/src/common/commandoption.c", // depends on generated datatext; not needed
        "fastfetch/src/common/format.c",
        "fastfetch/src/common/duration.c",
        "fastfetch/src/common/frequency.c",
        "fastfetch/src/common/size.c",
        "fastfetch/src/common/time.c",
        "fastfetch/src/common/percent.c",
        // options used by ffInitInstance()
        "fastfetch/src/options/logo.c",
        // we stub display options to avoid pulling extra deps
        // "fastfetch/src/options/display.c", // replaced by stub
        "fastfetch/src/options/general.c",
        // platform
        "fastfetch/src/util/platform/FFPlatform.c",
        // utils
        "fastfetch/src/util/FFlist.c",
        "fastfetch/src/util/path.c",
        "fastfetch/src/util/base64.c",
        "fastfetch/src/util/wcwidth.c",
        "fastfetch/src/common/printing.c",
        // vendored yyjson implementation
        "fastfetch/src/3rdparty/yyjson/yyjson.c",
        // detection: terminal theme used during init
        // terminal theme detection: replaced by stub to reduce deps
        // "fastfetch/src/detection/terminaltheme/terminaltheme.c",
        // detection: terminal core
        "fastfetch/src/detection/terminalshell/terminalshell.c",
        // detection: terminal font core
        "fastfetch/src/detection/terminalfont/terminalfont.c",
        // version globals (shim provides ffVersionResult to avoid reproducible date/time errors)
        "src/ff_shim/ff_version_shim.c",
        // font helpers
        "fastfetch/src/common/font.c",
    };
    inline for (common_sources) |path| exe.root_module.addCSourceFile(.{ .file = b.path(path), .flags = &.{} });

    // Ensure vasprintf is declared on Windows without editing vendored sources.
    // We force-include our minimal declaration header for FFstrbuf.c only on Windows.
    if (target.result.os.tag == .windows) {
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/FFstrbuf.c"), .flags = &.{ "-include", "src/ff_shim/win_compat.h" } });
    } else {
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/FFstrbuf.c"), .flags = &.{} });
    }

    // Add our stubs
    exe.root_module.addCSourceFile(.{ .file = b.path("src/ff_shim/logo_print_stub.c"), .flags = &.{} });
    exe.root_module.addCSourceFile(.{ .file = b.path("src/ff_shim/settings_stubs.c"), .flags = &.{} });
    exe.root_module.addCSourceFile(.{ .file = b.path("src/ff_shim/display_options_stub.c"), .flags = &.{} });
    exe.root_module.addCSourceFile(.{ .file = b.path("src/ff_shim/jsonconfig_stubs.c"), .flags = &.{} });
    exe.root_module.addCSourceFile(.{ .file = b.path("src/ff_shim/printing_line_stub.c"), .flags = &.{} });
    exe.root_module.addCSourceFile(.{ .file = b.path("src/ff_shim/terminaltheme_stub.c"), .flags = &.{} });

    // Non-Windows (Unix-like)
    if (target.result.os.tag != .windows) {
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/common/io/io_unix.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/platform/FFPlatform_unix.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/common/processing_linux.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/detection/terminalshell/terminalshell_linux.c"), .flags = &.{} });
    } else {
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/common/io/io_windows.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/platform/FFPlatform_windows.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/common/processing_windows.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/detection/terminalshell/terminalshell_windows.c"), .flags = &.{} });
    }

    // Apple specifics
    if (target.result.os.tag == .macos) {
        // Objective-C sources
        if (apple_sdk) |sdk| {
            const sdk_frameworks = b.pathJoin(&.{ sdk, "System/Library/Frameworks" });
            exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/detection/terminalfont/terminalfont_apple.m"), .flags = &.{"-fobjc-arc", "-isysroot", sdk, "-F", sdk_frameworks} });
            exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/apple/osascript.m"), .flags = &.{"-fobjc-arc", "-isysroot", sdk, "-F", sdk_frameworks} });
            // Ensure framework search path uses the provided SDK, not host paths
            exe.addFrameworkPath(.{ .cwd_relative = sdk_frameworks });
        } else {
            exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/detection/terminalfont/terminalfont_apple.m"), .flags = &.{"-fobjc-arc"} });
            exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/apple/osascript.m"), .flags = &.{"-fobjc-arc"} });
            // Fallback to default system framework locations on developer machines
            exe.addFrameworkPath(.{ .cwd_relative = "/System/Library/Frameworks" });
            exe.addFrameworkPath(.{ .cwd_relative = "/Library/Frameworks" });
        }
        // binary extractor impl for Apple
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/binary_apple.c"), .flags = &.{} });

        // Link frameworks required by osascript.m and plist access used in terminalfont_apple.m
        exe.linkFramework("Foundation");
        exe.linkFramework("AppKit");
        exe.linkFramework("CoreData");
    } else if (target.result.os.tag == .windows) {
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/detection/terminalfont/terminalfont_windows.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/windows/unicode.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/windows/registry.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/windows/version.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/windows/getline.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/binary_windows.c"), .flags = &.{} });
        exe.root_module.addCSourceFile(.{ .file = b.path("src/ff_shim/win_compat.c"), .flags = &.{} });
        // Windows libs
        exe.linkSystemLibrary("advapi32");
        exe.linkSystemLibrary("user32");
        exe.linkSystemLibrary("shell32");
        exe.linkSystemLibrary("kernel32");
        exe.linkSystemLibrary("imagehlp");
        exe.linkSystemLibrary("ole32");
        exe.linkSystemLibrary("secur32");
        exe.linkSystemLibrary("version");
    } else {
        // Linux/BSD
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/detection/terminalfont/terminalfont_linux.c"), .flags = &.{} });
        // binary extractor impl for Linux/BSD
        exe.root_module.addCSourceFile(.{ .file = b.path("fastfetch/src/util/binary_linux.c"), .flags = &.{} });
    }

    // Define feature macros to keep dependencies minimal
    const macros = .{
        .{ "FF_HAVE_DBUS", "0" },
        .{ "FF_HAVE_DCONF", "0" },
        .{ "FF_HAVE_GIO", "0" },
        .{ "FF_HAVE_XRANDR", "0" },
        .{ "FF_HAVE_XCB_RANDR", "0" },
        .{ "FF_HAVE_WAYLAND", "0" },
        .{ "FF_HAVE_VULKAN", "0" },
        .{ "FF_HAVE_OPENCL", "0" },
        .{ "FF_HAVE_ZLIB", "0" },
        .{ "FF_HAVE_SQLITE3", "0" },
        .{ "FF_HAVE_EGL", "0" },
        .{ "FF_HAVE_GLX", "0" },
        .{ "FF_HAVE_CHAFA", "0" },
        .{ "FF_HAVE_PULSE", "0" },
        .{ "FF_HAVE_DRM", "0" },
        .{ "FF_HAVE_DRM_AMDGPU", "0" },
        .{ "FF_HAVE_LIBZFS", "0" },
        .{ "FF_HAVE_PCIACCESS", "0" },
        .{ "FF_HAVE_LINUX_VIDEODEV2", "0" },
        .{ "FF_HAVE_LINUX_WIRELESS", "0" },
        .{ "FF_HAVE_THREADS", "1" },
    };
    inline for (macros) |m| exe.root_module.addCMacro(m[0], m[1]);
    // Allow __DATE__/__TIME__ in version.c on Zig 0.15 by defining this opt-out
    exe.root_module.addCMacro("ZIG_REPRODUCIBLE_BUILD", "0");

    // Debug defines for macOS Clang if useful
    if (target.result.os.tag == .macos) {
        exe.root_module.addCMacro("_DARWIN_C_SOURCE", "1");
    }

    // libc
    exe.linkLibC();

    // Linux-specific feature macros
    if (target.result.os.tag == .linux) {
        exe.root_module.addCMacro("_GNU_SOURCE", "1");
    }

    // Install artifact
    b.installArtifact(exe);

    // Default run step
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);
    const run_step = b.step("run", "Run terminalfont-detect");
    run_step.dependOn(&run_cmd.step);
}


