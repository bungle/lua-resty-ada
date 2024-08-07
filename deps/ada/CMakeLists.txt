cmake_minimum_required(VERSION 3.16)

project(ada
  DESCRIPTION "Fast spec-compliant URL parser"
  LANGUAGES C CXX
  VERSION 2.9.0
)

set(CMAKE_CXX_STANDARD 17)

add_library(ada SHARED ada.cpp)
