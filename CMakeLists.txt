cmake_minimum_required(VERSION 3.0)

project("libghttp" C)

include(GNUInstallDirs)

message(STATUS "CMake version: " ${CMAKE_VERSION})
message(STATUS "CMake system name: " ${CMAKE_SYSTEM_NAME})

# version
SET(LIBGHTTP_VERSION_MAJOR 2)
SET(LIBGHTTP_VERSION_MINOR 0)
SET(LIBGHTTP_VERSION_PATCH 0)
SET(LIBGHTTP_VERSION ${LIBGHTTP_VERSION_MAJOR}.${LIBGHTTP_VERSION_MINOR}.${LIBGHTTP_VERSION_PATCH})
message(STATUS "Libghttp version: " ${LIBGHTTP_VERSION})

option(ENABLE_TLS "Build libghttp with SSL/TLS feature." OFF)

if(${ENABLE_TLS} STREQUAL ON)
    
endif()

option(ENABLE_TESTING "Build libghttp tests." OFF)

if(${ENABLE_TESTING} STREQUAL ON)
    enable_testing()
    add_subdirectory(tests)
endif()

set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE}
    CACHE STRING "Choose the type of build: None Debug Release Coverage Check"
    FORCE)

set(CMAKE_C_FLAGS_RELEASE     "-O2")
set(CMAKE_C_FLAGS_DEBUG       "-O0 -g3")
set(CMAKE_C_FLAGS_COVERAGE    "-O0 -g3")
set(CMAKE_C_FLAGS_CHECK       "-O0 -g3")


add_subdirectory(src)

