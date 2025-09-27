#include "../../fastfetch/src/common/jsonconfig.h"

bool ffJsonConfigParseModuleArgs(yyjson_val *key, yyjson_val *val,
                                 FFModuleArgs *moduleArgs) {
  (void)key;
  (void)val;
  (void)moduleArgs;
  return false;
}
const char *ffJsonConfigParseEnum(yyjson_val *val, int *result,
                                  FFKeyValuePair pairs[]) {
  (void)val;
  (void)result;
  (void)pairs;
  return NULL;
}
void ffPrintJsonConfig(bool prepare, yyjson_mut_doc *jsonDoc) {
  (void)prepare;
  (void)jsonDoc;
}
void ffJsonConfigGenerateModuleArgsConfig(yyjson_mut_doc *doc,
                                          yyjson_mut_val *module,
                                          FFModuleArgs *moduleArgs) {
  (void)doc;
  (void)module;
  (void)moduleArgs;
}
