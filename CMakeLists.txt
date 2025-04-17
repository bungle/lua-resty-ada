cmake_minimum_required(VERSION 3.16)

project(
  ada
  DESCRIPTION "Fast spec-compliant URL parser"
  LANGUAGES C CXX
  VERSION 3.3.0
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Avoid warning about DOWNLOAD_EXTRACT_TIMESTAMP in CMake 3.24:
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()

include(FetchContent)

FetchContent_Declare(
  ada
  URL      https://github.com/ada-url/ada/releases/download/v3.4.4/singleheader.zip
  URL_HASH SHA256=cb0dc03516129e3bfc2c23b24bff039a01fc7ccec1a7585458c425cb57bf9fcb
)

FetchContent_MakeAvailable(ada)

add_library(ada SHARED _deps/ada-src/ada.cpp)

install(TARGETS ada DESTINATION lib)
