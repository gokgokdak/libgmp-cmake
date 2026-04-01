cmake_minimum_required(VERSION 3.21)

project(gmp VERSION 6.3.0 LANGUAGES C)

option(GMP_ENABLE_CXX "Build the C++ wrapper library (gmpxx)." OFF)
option(GMP_ENABLE_ASM "Build architecture-specific assembly where supported." ON)
option(GMP_BUILD_SHARED "Build shared GMP libraries." ON)
option(GMP_BUILD_STATIC "Build static GMP libraries." ON)
option(GMP_BUILD_VERIFY_CASES "Build wrapper verification targets for link scenarios." OFF)
option(GMP_BUILD_TESTS "Build and register the upstream GMP C test suite." OFF)

if(NOT GMP_BUILD_SHARED AND NOT GMP_BUILD_STATIC)
  message(FATAL_ERROR "At least one of GMP_BUILD_SHARED or GMP_BUILD_STATIC must be ON.")
endif()

if(GMP_ENABLE_CXX)
  enable_language(CXX)
endif()

if(GMP_ENABLE_ASM)
  enable_language(ASM)
endif()

if(GMP_BUILD_VERIFY_CASES OR GMP_BUILD_TESTS)
  enable_testing()
endif()

include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/GmpBuild.cmake)
gmp_build()
