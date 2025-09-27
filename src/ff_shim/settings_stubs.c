#include "../../fastfetch/src/common/settings.h"
#include "../../fastfetch/src/detection/displayserver/displayserver.h"

FFvariant ffSettingsGetDConf(const char *key, FFvarianttype type) {
  (void)key;
  (void)type;
  return FF_VARIANT_NULL;
}
FFvariant ffSettingsGetGSettings(const char *schemaName, const char *path,
                                 const char *key, FFvarianttype type) {
  (void)schemaName;
  (void)path;
  (void)key;
  (void)type;
  return FF_VARIANT_NULL;
}
FFvariant ffSettingsGetGnome(const char *dconfKey,
                             const char *gsettingsSchemaName,
                             const char *gsettingsPath,
                             const char *gsettingsKey, FFvarianttype type) {
  (void)dconfKey;
  (void)gsettingsSchemaName;
  (void)gsettingsPath;
  (void)gsettingsKey;
  (void)type;
  return FF_VARIANT_NULL;
}
FFvariant ffSettingsGetXFConf(const char *channelName, const char *propertyName,
                              FFvarianttype type) {
  (void)channelName;
  (void)propertyName;
  (void)type;
  return FF_VARIANT_NULL;
}
FFvariant ffSettingsGetXFConfFirstMatch(const char *channelName,
                                        const char *propertyPrefix,
                                        FFvarianttype type, void *data,
                                        FFTestXfconfPropCallback *cb) {
  (void)channelName;
  (void)propertyPrefix;
  (void)type;
  (void)data;
  (void)cb;
  return FF_VARIANT_NULL;
}

const FFDisplayServerResult *ffConnectDisplayServer(void) {
  static FFDisplayServerResult res = {};
  return &res;
}
