#pragma once
#ifdef _WIN32
#include <stdarg.h>

int vasprintf(char **strp, const char *fmt, va_list ap);

#endif
