cmake_minimum_required(VERSION 3.16)

project(
  ada
  DESCRIPTION "Fast spec-compliant URL parser"
  LANGUAGES C CXX
  VERSION 2.9.0
)

set(CMAKE_CXX_STANDARD 17)

# Avoid warning about DOWNLOAD_EXTRACT_TIMESTAMP in CMake 3.24:
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()

include(FetchContent)

FetchContent_Declare(
  ada
  URL      https://github.com/ada-url/ada/releases/download/v2.9.0/singleheader.zip
  URL_HASH SHA256=20b09948cf58362abe4de20b8e709d5041477fb798350fd1a02cde6aad121e08
)

FetchContent_MakeAvailable(ada)

add_library(ada SHARED _deps/ada-src/ada.cpp)

install(TARGETS ada DESTINATION lib)
