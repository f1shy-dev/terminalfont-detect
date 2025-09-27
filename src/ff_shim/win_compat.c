#ifdef _WIN32
#include "win_compat.h"
#include <stdio.h>
#include <stdlib.h>

int vasprintf(char **strp, const char *fmt, va_list ap) {
  va_list ap_copy;
  va_copy(ap_copy, ap);
  int len = _vscprintf(fmt, ap_copy);
  va_end(ap_copy);
  if (len < 0)
    return -1;
  char *buf = (char *)malloc((size_t)len + 1);
  if (!buf)
    return -1;
  int written = vsnprintf(buf, (size_t)len + 1, fmt, ap);
  if (written < 0) {
    free(buf);
    return -1;
  }
  *strp = buf;
  return written;
}
#endif
