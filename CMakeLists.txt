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

# Build type
set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}
    CACHE STRING "Choose the type of build: None Debug Release Coverage"
    FORCE
    )

if(CMAKE_BUILD_TYPE)
    message(STATUS "CMake build type: " ${CMAKE_BUILD_TYPE})
endif()

# Default C / CXX flags
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_C_FLAGS " -Wall -D__FILE_NAME__='\"$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"' -D__PROJECT__='\"[${CMAKE_PROJECT_NAME}]\"' ")
    set(CMAKE_CXX_FLAGS " -Wall -D__FILE_NAME__='\"$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"' -D__PROJECT__='\"[${CMAKE_PROJECT_NAME}]\"' ")
endif()

set(CMAKE_C_FLAGS_DEBUG " -g -ggdb -O0 -Wall -D__FILE_NAME__='\"$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"' -D__PROJECT__='\"[${CMAKE_PROJECT_NAME}]\"' ")
set(CMAKE_CXX_FLAGS_DEBUG " -g -ggdb -O0 -Wall -D__FILE_NAME__='\"$(subst ${CMAKE_SOURCE_DIR}/,,$(abspath $<))\"' -D__PROJECT__='\"[${CMAKE_PROJECT_NAME}]\"' ")

set(CMAKE_C_FLAGS_RELEASE " -O3 -Wall -DDEFAULT_LOG_LEVEL=LOG_LEVEL_INFO -D__PROJECT__='\"[${CMAKE_PROJECT_NAME}]\"' ")
set(CMAKE_CXX_FLAGS_RELEASE " -O3 -Wall -DDEFAULT_LOG_LEVEL=LOG_LEVEL_INFO -D__PROJECT__='\"[${CMAKE_PROJECT_NAME}]\"' ")

set(CMAKE_C_FLAGS_COVERAGE " ${CMAKE_C_FLAGS_DEBUG} -fprofile-arcs -ftest-coverage")
set(CMAKE_CXX_FLAGS_COVERAGE " ${CMAKE_C_FLAGS_DEBUG} -fprofile-arcs -ftest-coverage")

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
if(ssl_options_count EQUAL "1")
    set(WITH_TLS ON)
endif()
if(ssl_options_count GREATER "1")
    message(FATAL_ERROR "Only one ssl library can be selected when libghttp build!")
endif()

# Document
add_custom_target(apidoc
    COMMAND doxygen ghttp.doxyfile
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/doc)

# Subdirectory
add_subdirectory(third_party)
add_subdirectory(include)
add_subdirectory(src)

# Test 
option(ENABLE_TESTING "Build libghttp tests." ON)

if(ENABLE_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()

