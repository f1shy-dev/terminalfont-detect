#include "../../fastfetch/src/detection/version/version.h"
#include "../../fastfetch/src/fastfetch.h"

FFVersionResult ffVersionResult = {
    .projectName = FASTFETCH_PROJECT_NAME,
    .sysName = "macOS",
    .architecture =
#if defined(__aarch64__)
        "aarch64",
#elif defined(__x86_64__)
        "x86_64",
#else
        "unknown",
#endif
    .version = FASTFETCH_PROJECT_VERSION,
    .versionTweak = FASTFETCH_PROJECT_VERSION_TWEAK,
    .versionGit = FASTFETCH_PROJECT_VERSION_GIT,
    .cmakeBuiltType = FASTFETCH_PROJECT_CMAKE_BUILD_TYPE,
    .compileTime = "",
    .compiler = "clang",
    .debugMode =
#ifndef NDEBUG
        true,
#else
        false,
#endif
};
