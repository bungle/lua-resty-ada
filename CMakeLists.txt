cmake_minimum_required(VERSION 3.16)

project(
  ada
  DESCRIPTION "Fast spec-compliant URL parser"
  LANGUAGES C CXX
  VERSION 2.9.2
)

set(CMAKE_CXX_STANDARD 17)

# Avoid warning about DOWNLOAD_EXTRACT_TIMESTAMP in CMake 3.24:
if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()

include(FetchContent)

FetchContent_Declare(
  ada
  URL      https://github.com/ada-url/ada/releases/download/v2.9.2/singleheader.zip
  URL_HASH SHA256=b2cce630590b490d79ea4f4460ba77efd5fb29c5a87a4e8cb7ebc4859bc4b564
)

FetchContent_MakeAvailable(ada)

add_library(ada SHARED _deps/ada-src/ada.cpp)

install(TARGETS ada DESTINATION lib)
