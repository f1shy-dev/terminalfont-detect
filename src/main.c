// Minimal CLI to print the current terminal font using fastfetch's detection
// API
#include "../fastfetch/src/common/init.h"
#include "../fastfetch/src/detection/terminalfont/terminalfont.h"
#include "../fastfetch/src/fastfetch.h"
#include "ff_config/fastfetch_config.h"

#include <stdio.h>

int main(void) {
  ffInitInstance();

  FFTerminalFontResult result = {0};
  ffStrbufInit(&result.error);
  ffFontInit(&result.font);
  ffFontInit(&result.fallback);

  if (!ffDetectTerminalFont(&result)) {
    fprintf(stderr, "error: %s\n", result.error.chars);
    ffFontDestroy(&result.font);
    ffFontDestroy(&result.fallback);
    ffStrbufDestroy(&result.error);
    ffDestroyInstance();
    return 1;
  }

  if (result.font.pretty.length)
    printf("%s\n", result.font.pretty.chars);
  else if (result.font.name.length)
    printf("%s\n", result.font.name.chars);
  else
    printf("unknown\n");

  if (result.fallback.pretty.length)
    fprintf(stderr, "fallback: %s\n", result.fallback.pretty.chars);

  ffFontDestroy(&result.font);
  ffFontDestroy(&result.fallback);
  ffStrbufDestroy(&result.error);
  ffDestroyInstance();
  return 0;
}
