cmake_minimum_required(VERSION 3.16)

project(
  ada
  DESCRIPTION "Fast spec-compliant URL parser"
  LANGUAGES C CXX
  VERSION 3.2.4
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
  URL      https://github.com/ada-url/ada/releases/download/v3.2.4/singleheader.zip
  URL_HASH SHA256=bd89fcf57c93e965e6e2488448ab9d1cf8005311808c563b288f921d987e4924
)

FetchContent_MakeAvailable(ada)

add_library(ada SHARED _deps/ada-src/ada.cpp)

install(TARGETS ada DESTINATION lib)
