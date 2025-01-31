cmake_minimum_required(VERSION 3.16)

project(
  ada
  DESCRIPTION "Fast spec-compliant URL parser"
  LANGUAGES C CXX
  VERSION 3.2.1
)

set(CMAKE_CXX_STANDARD 20)

# Avoid warning about DOWNLOAD_EXTRACT_TIMESTAMP in CMake 3.24:
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()

include(FetchContent)

FetchContent_Declare(
  ada
  URL      https://github.com/ada-url/ada/releases/download/v3.2.1/singleheader.zip
  URL_HASH SHA256=2954ff2208aa016de4213af7371273e1c41c71571e373eadf550ada808c79f42
)

FetchContent_MakeAvailable(ada)

add_library(ada SHARED _deps/ada-src/ada.cpp)

install(TARGETS ada DESTINATION lib)
