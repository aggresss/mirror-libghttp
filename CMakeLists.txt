cmake_minimum_required(VERSION 3.0)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake;${CMAKE_MODULE_PATH}")
include(Utilities)
include(GNUInstallDirs)

project("libghttp" C)

# Get and Display infomation
message(STATUS "CMake version: " ${CMAKE_VERSION})
message(STATUS "CMake system name: " ${CMAKE_SYSTEM_NAME})

c_compiler_prefix(C_COMPILER_PREFIX)
if(C_COMPILER_PREFIX)
    message(STATUS "C_COMPILER_PREFIX: " ${C_COMPILER_PREFIX})
endif()

# Version
set(LIBGHTTP_VERSION_MAJOR 2)
set(LIBGHTTP_VERSION_MINOR 0)
set(LIBGHTTP_VERSION_PATCH 0)
set(LIBGHTTP_VERSION ${LIBGHTTP_VERSION_MAJOR}.${LIBGHTTP_VERSION_MINOR}.${LIBGHTTP_VERSION_PATCH})
message(STATUS "Libghttp version: " ${LIBGHTTP_VERSION})

# target static and shared
option(WITH_STATIC "Build libghttp static library." ON)
option(WITH_SHARED "Build libghttp shared library." OFF)

if (NOT WITH_STATIC AND NOT WITH_SHARED)
    message(FATAL_ERROR "Need to choose static or shared libghttp build!")
endif()

# SSL/TLS feature
option(USE_WOLFSSL "Build libghttp WOLFSSL." OFF)
option(USE_MBEDTLS "Build libghttp MBEDTLS." OFF)
option(USE_OPENSSL "Build libghttp OPENSSL." OFF)

count_true(ssl_options_count
    USE_WOLFSSL
    USE_MBEDTLS
    USE_OPENSSL
)
if(ssl_options_count GREATER "1")
    message(FATAL_ERROR "Only one ssl library can be selected when libghttp build!")
endif()

# Test 
option(ENABLE_TESTING "Build libghttp tests." OFF)

if(${ENABLE_TESTING} STREQUAL ON)
    enable_testing()
    add_subdirectory(tests)
endif()

# Document
add_custom_target(apidoc
    COMMAND doxygen ghttp.doxyfile
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/doc)

# Build type
set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}
    CACHE STRING "Choose the type of build: None Debug Release Coverage Check"
    FORCE)

set(CMAKE_C_FLAGS_RELEASE     "-O2")
set(CMAKE_C_FLAGS_DEBUG       "-O0 -g3")
set(CMAKE_C_FLAGS_COVERAGE    "-O0 -g3")
set(CMAKE_C_FLAGS_CHECK       "-O0 -g3")

# Subdirectory
add_subdirectory(third_party)
add_subdirectory(include)
add_subdirectory(src)

