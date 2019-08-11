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
  string(REGEX REPLACE "[-]$" "" CROSS_COMPILE_NO_MINUS ${CROSS_COMPILE})
  set(CMAKE_C_COMPILER ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE_NO_MINUS}-gcc)
  set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE_NO_MINUS}-g++)
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

  if(TOOLCHAIN_PATH)
    find_program(CMAKE_AR ${CROSS_COMPILE_NO_MINUS}-ar PATHS ${TOOLCHAIN_PATH_WITH_SLASH})
    find_program(CMAKE_RANLIB ${CROSS_COMPILE_NO_MINUS}-ranlib PATHS ${TOOLCHAIN_PATH_WITH_SLASH})
  else()
    find_program(CMAKE_AR ${CROSS_COMPILE_NO_MINUS}-ar)
    find_program(CMAKE_RANLIB ${CROSS_COMPILE_NO_MINUS}-ranlib)
  endif(TOOLCHAIN_PATH)

  set(TOOLCHAIN_FILE "${CMAKE_CURRENT_BINARY_DIR}/toolchain.cmake")
  file(WRITE ${TOOLCHAIN_FILE}
"# ------------------------------------------------------------------------------
# toolchain.cmake
# ------------------------------------------------------------------------------
# this is required
set(CMAKE_SYSTEM_NAME Linux)
# specify the cross compiler
set(CMAKE_C_COMPILER ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE_NO_MINUS}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PATH_WITH_SLASH}${CROSS_COMPILE_NO_MINUS}-g++)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
\n"
  )

endif(CROSS_COMPILE)

# ------------------------------------------------------------------------------
# Project
# ------------------------------------------------------------------------------

project("libghttp" C)

# ------------------------------------------------------------------------------
# OS Specific
# ------------------------------------------------------------------------------

if (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
  set(WINDOWS TRUE)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
  set(LINUX TRUE)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
  set(OSX TRUE)
else()
  message(DEPRECATION "No support for system: " ${CMAKE_SYSTEM_NAME})
endif()

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

if(CUSTOM_FLAGS)
  string(REPLACE "," " " CUSTOM_FLAGS_WITH_SPACE ${CUSTOM_FLAGS})
endif()

# Default C / CXX flags
if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CUSTOM_FLAGS_WITH_SPACE} -Wall")
endif()

set(CMAKE_C_FLAGS_DEBUG "${CUSTOM_FLAGS_WITH_SPACE} -g -ggdb -O0 -Wall")
set(CMAKE_C_FLAGS_RELEASE "${CUSTOM_FLAGS_WITH_SPACE} -O3 -DNDEBUG  -Wall")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -DDEFAULT_LOG_LEVEL=LOG_LEVEL_INFO")
set(CMAKE_C_FLAGS_COVERAGE "${CMAKE_C_FLAGS_DEBUG} -fprofile-arcs -ftest-coverage")

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

option(BUILD_STATIC "Build static library." ON)
option(BUILD_SHARED "Build shared library." OFF)

if (NOT BUILD_STATIC AND NOT BUILD_SHARED)
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
# ExternalProject
# ------------------------------------------------------------------------------

#set{EXTERNAL_POJECT_1 xxx}
#ExternalProject_Add(${EXTERNAL_POJECT_1}
#  SOURCE_DIR ${CMAKE_SOURCE_DIR}/${EXTERNAL_POJECT_1}
#  CMAKE_ARGS
#    -DCMAKE_INSTALL_PREFIX:PATH=${PROJECT_BINARY_DIR}/${EXTERNAL_POJECT_1}
#    -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
#    -DCROSS_COMPILE=${CROSS_COMPILE}
#    -DTOOLCHAIN_PATH=${TOOLCHAIN_PATH}
#    -DCMAKE_SYSROOT=${CMAKE_SYSROOT}
#    -DCUSTOM_FLAGS=${CUSTOM_FLAGS}
#  TEST_COMMAND ""
#  )
#set(EXTERNAL_POJECT_1_PREFIX ${PROJECT_BINARY_DIR}/${EXTERNAL_POJECT_1})
#
#install(DIRECTORY ${EXTERNAL_POJECT_1_PREFIX}/include/
#  DESTINATION include
#  )
#install(DIRECTORY ${EXTERNAL_POJECT_1_PREFIX}/lib/
#  DESTINATION lib
#  )

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
      "${MEMORYCHECK_COMMAND_OPTIONS} --leak-check=yes --show-reachable=no --undef-value-errors=no")
    set(MEMORYCHECK_COMMAND_OPTIONS
      "${MEMORYCHECK_COMMAND_OPTIONS} --trace-children=yes --track-fds=no --track-origins=no")
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
