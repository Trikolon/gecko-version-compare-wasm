// version_compare.cpp
#include <cstdint>
#include "nsVersionComparator.h"
#ifdef __EMSCRIPTEN__
#include <emscripten/bind.h>
#include <string>
#endif

#ifdef __EMSCRIPTEN__
extern "C" int32_t CompareVersions(const char* a, const char* b)
{
  return mozilla::CompareVersions(a, b);
}

static int32_t CompareVersionsStr(const std::string& a, const std::string& b) {
  return mozilla::CompareVersions(a.c_str(), b.c_str());
}

EMSCRIPTEN_BINDINGS(version_compare) {
  emscripten::function("compareVersions", &CompareVersionsStr);
}
#else
extern "C" int32_t CompareVersions(const char* a, const char* b)
{
  return mozilla::CompareVersions(a, b);
}
#endif