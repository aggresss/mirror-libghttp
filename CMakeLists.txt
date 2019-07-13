# ------------------------------------------------------------------------------
# CMakeLists.txt for libghttp Project Top Level
# ------------------------------------------------------------------------------
cmake_minimum_required(VERSION 2.8)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/CMake" ${CMAKE_MODULE_PATH})
include(Utilities)
include(GNUInstallDirs)

# ------------------------------------------------------------------------------
# Cross compile
# ------------------------------------------------------------------------------

if(TOOLCHAIN_PATH)
    string(REGEX REPLACE "[/]$" "" TOOLCHAIN_PATH_NO_SLASH ${TOOLCHAIN_PATH})
    set(TOOLCHAIN_PATH_WITH_SLASH "${TOOLCHAIN_PATH_NO_SLASH}/")
else()
    set(TOOLCHAIN_PATH_WITH_SLASH "")
endif()

# MUST before project()
if(CROSS_COMPILE)
  set(CMAKE_C_COMPILER ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE}-gcc)
  set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE}-g++)
  set(CMAKE_AR ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE}-ar)
  set(CMAKE_RANLIB ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE}-ranlib)
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
  set(TOOLCHAIN_FILE "${CMAKE_CURRENT_BINARY_DIR}/toolchain.cmake")
  file(WRITE ${TOOLCHAIN_FILE}
"# ------------------------------------------------------------------------------
# toolchain.cmake
# ------------------------------------------------------------------------------

# this is required
set(CMAKE_SYSTEM_NAME Linux)

# specify the cross compiler
set(CMAKE_C_COMPILER ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE}-g++)
set(CMAKE_AR ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE}-ar)
set(CMAKE_RANLIB ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE}-ranlib)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
\n"
  )
endif()

# ------------------------------------------------------------------------------
# Project
# ------------------------------------------------------------------------------

project("libghttp" C)

# ------------------------------------------------------------------------------
# Get and Display infomation
# ------------------------------------------------------------------------------

message(STATUS "CMake version: " ${CMAKE_VERSION})
message(STATUS "CMake system name: " ${CMAKE_SYSTEM_NAME})
message(STATUS "C compiler: " ${CMAKE_C_COMPILER})
message(STATUS "CXX compiler: " ${CMAKE_CXX_COMPILER})

c_compiler_prefix(C_COMPILER_PREFIX)
if(C_COMPILER_PREFIX)
  message(STATUS "C compiler prefix: " ${C_COMPILER_PREFIX})
endif()

c_compiler_machine(C_COMPILER_MACHINE)
if(C_COMPILER_MACHINE)
  message(STATUS "C compiler machine infomation: " ${C_COMPILER_MACHINE})
endif()

# ------------------------------------------------------------------------------
# Build type
# ------------------------------------------------------------------------------

set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}
  CACHE STRING "Choose the type of build: None Debug Release Coverage" FORCE)

if(CMAKE_BUILD_TYPE)
  message(STATUS "CMake build type: " ${CMAKE_BUILD_TYPE})
endif()

# Default C / CXX flags
if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall")
endif()

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g -ggdb -O0 -Wall")
set(CMAKE_C_FLAGS_RELEASE "-O3 -DNDEBUG  -Wall")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -DDEFAULT_LOG_LEVEL=LOG_LEVEL_INFO")
set(CMAKE_C_FLAGS_COVERAGE "${CMAKE_C_FLAGS_DEBUG} -fprofile-arcs -ftest-coverage")

if(NOT CROSS_COMPILE)
  if(CPACK_ARCH STREQUAL "x64")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -m64")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -m64")
    set(CMAKE_C_FLAGS_COVERAGE "${CMAKE_C_FLAGS_COVERAGE} -m64")
  elseif(CPACK_ARCH STREQUAL "x86")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -m32")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -m32")
    set(CMAKE_C_FLAGS_COVERAGE "${CMAKE_C_FLAGS_COVERAGE} -m32")
  endif()
endif()

set(CMAKE_CXX_FLAGS ${CMAKE_C_FLAGS})
set(CMAKE_CXX_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG})
set(CMAKE_CXX_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})
set(CMAKE_CXX_FLAGS_COVERAGE ${CMAKE_C_FLAGS_COVERAGE})

# ------------------------------------------------------------------------------
# Version
# ------------------------------------------------------------------------------

set(VERSION_MAJOR 2)
set(VERSION_MINOR 1)
set(VERSION_PATCH 0)
set(RELEASE_VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH})
message(STATUS "${PROJECT_NAME} release version: " ${RELEASE_VERSION})

get_commit_id(BUILD_VERSION)
if(BUILD_VERSION)
  message(STATUS "${PROJECT_NAME} build version: " ${BUILD_VERSION})
endif()

# ------------------------------------------------------------------------------
# target static and shared
# ------------------------------------------------------------------------------

option(WITH_STATIC "Build static library." ON)
option(WITH_SHARED "Build shared library." OFF)

if (NOT WITH_STATIC AND NOT WITH_SHARED)
  message(FATAL_ERROR "Need to choose static or shared build!")
endif()

# ------------------------------------------------------------------------------
# SSL/TLS feature
# ------------------------------------------------------------------------------

option(WITH_WOLFSSL "Build with WOLFSSL." OFF)
option(WITH_MBEDTLS "Build with MBEDTLS." OFF)
option(WITH_OPENSSL "Build with OPENSSL." OFF)

count_true(ssl_options_count
  WITH_WOLFSSL
  WITH_MBEDTLS
  WITH_OPENSSL
  )
if(ssl_options_count EQUAL "1")
  set(WITH_TLS ON)
  if(WITH_WOLFSSL)
    set(WOLFSSL_PREFIX ${PROJECT_BINARY_DIR}/third_party/wolfssl)
    set(WOLFSSL_INCLUDE_DIRS ${WOLFSSL_PREFIX}/include)
    set(WOLFSSL_LIBRARIES ${WOLFSSL_PREFIX}/lib)
  elseif(WITH_MBEDTLS)
    set(MBEDTLS_PREFIX ${PROJECT_BINARY_DIR}/third_party/mbedtls)
    set(MBEDTLS_INCLUDE_DIRS ${MBEDTLS_PREFIX}/include)
    set(MBEDTLS_LIBRARIES ${MBEDTLS_PREFIX}/lib)
  elseif(WITH_OPENSSL)
    set(OPENSSL_PREFIX ${PROJECT_BINARY_DIR}/third_party/openssl)
    set(OPENSSL_INCLUDE_DIRS ${OPENSSL_PREFIX}/include)
    set(OPENSSL_LIBRARIES ${OPENSSL_PREFIX}/lib)
  endif()
elseif(ssl_options_count GREATER "1")
  message(FATAL_ERROR "Only one ssl library can be selected when build!")
endif()

# ------------------------------------------------------------------------------
# Document
# ------------------------------------------------------------------------------

find_program(DOXYGEN doxygen)
if(DOXYGEN)
  add_custom_target(doc
    COMMAND doxygen ghttp.Doxyfile
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/doc)
endif()

# ------------------------------------------------------------------------------
# Subdirectory
# ------------------------------------------------------------------------------

set(DEPENDS_DIRS ${PROJECT_SOURCE_DIR}/deps)

add_subdirectory(third_party)
add_subdirectory(include)
add_subdirectory(src)

# ------------------------------------------------------------------------------
# Test
# ------------------------------------------------------------------------------

option(ENABLE_TESTING "Build tests." ON)

if(ENABLE_TESTING)
  find_program(VALGRIND valgrind)
  if(VALGRIND)
    # Ctest configuration variables must be set BEFORE include(Ctest)
    set(MEMORYCHECK_COMMAND ${VALGRIND})
    # Check process children and give detail for each leak
    set(MEMORYCHECK_COMMAND_OPTIONS
      "${MEMORYCHECK_COMMAND_OPTIONS} --leak-check=yes --show-reachable=yes")
    set(MEMORYCHECK_COMMAND_OPTIONS
      "${MEMORYCHECK_COMMAND_OPTIONS} --trace-children=yes --track-fds=yes")
    # Set error code.
    set(MEMORYCHECK_COMMAND_OPTIONS
      "${MEMORYCHECK_COMMAND_OPTIONS} --error-exitcode=255")
    # Generate suppression hint.
    set(MEMORYCHECK_COMMAND_OPTIONS
      "${MEMORYCHECK_COMMAND_OPTIONS} --gen-suppressions=all")
    # Set suppression file
    set(MEMORYCHECK_COMMAND_OPTIONS
      "${MEMORYCHECK_COMMAND_OPTIONS} --suppressions=${CMAKE_CURRENT_LIST_DIR}/valgrind.supp")
  endif()
  include (CTest)
  enable_testing()
  add_subdirectory(tests)
endif()

# ------------------------------------------------------------------------------
# Pack
# ------------------------------------------------------------------------------

set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_VENDOR "${PROJECT_NAME}")
set(CPACK_PACKAGE_DESCRIPTION "${PROJECT_NAME}")
set(CPACK_PACKAGE_HOMEPAGE_URL "")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_FILE_README "${PROJECT_SOURCE_DIR}/README.md")

set(CPACK_PACKAGE_VERSION_MAJOR "${VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${VERSION_PATCH}")
set(CPACK_PACKAGE_VERSION_FULL "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}")

string(REGEX REPLACE
  "([A-Za-z0-9_\\.]+)\\-([A-Za-z0-9_\\.]+)\\-([A-Za-z0-9_\\.]+)" "\\1-\\2"
  C_COMPILE_ARCH_OS ${C_COMPILER_MACHINE})

set(CPACK_PACKAGE_FILE_NAME
  ${CPACK_PACKAGE_NAME}_v${CPACK_PACKAGE_VERSION_FULL})

if(CPACK_ARCH)
  set(CPACK_PACKAGE_FILE_NAME
    ${CPACK_PACKAGE_FILE_NAME}_${CPACK_ARCH})
endif()
if(CPACK_SOC)
  set(CPACK_PACKAGE_FILE_NAME
    ${CPACK_PACKAGE_FILE_NAME}_${CPACK_SOC})
endif()
if(CPACK_LIBC)
  set(CPACK_PACKAGE_FILE_NAME
    ${CPACK_PACKAGE_FILE_NAME}_${CPACK_LIBC})
endif()
if(CPACK_GCCVER)
  set(CPACK_PACKAGE_FILE_NAME
    ${CPACK_PACKAGE_FILE_NAME}_${CPACK_GCCVER})
endif()
if(CMAKE_BUILD_TYPE)
  set(CPACK_PACKAGE_FILE_NAME
    ${CPACK_PACKAGE_FILE_NAME}_${CMAKE_BUILD_TYPE})
endif()

set(CPACK_GENERATOR "TGZ")
include (CPack)
