cmake_minimum_required(VERSION 3.0)

project("libghttp" C)

include(GNUInstallDirs)

message(STATUS "CMake version: " ${CMAKE_VERSION})
message(STATUS "CMake system name: " ${CMAKE_SYSTEM_NAME})

# Version
SET(LIBGHTTP_VERSION_MAJOR 2)
SET(LIBGHTTP_VERSION_MINOR 0)
SET(LIBGHTTP_VERSION_PATCH 0)
SET(LIBGHTTP_VERSION ${LIBGHTTP_VERSION_MAJOR}.${LIBGHTTP_VERSION_MINOR}.${LIBGHTTP_VERSION_PATCH})
message(STATUS "Libghttp version: " ${LIBGHTTP_VERSION})

# SSL/TLS feature
option(USE_WOLFSSL "Build libghttp WOLFSSL." OFF)
option(USE_MBEDTLS "Build libghttp MBEDTLS." OFF)
option(USE_OPENSSL "Build libghttp OPENSSL." OFF)

# Returns a list of arguments that evaluate to true
function(count_true output_count_var)
    set(lst)
    foreach(option_var IN LISTS ARGN)
        if(${option_var})
        list(APPEND lst ${option_var})
        endif()
    endforeach()
    list(LENGTH lst lst_len)
    set(${output_count_var} ${lst_len} PARENT_SCOPE)
endfunction()

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
add_subdirectory(src)

