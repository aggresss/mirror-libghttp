# ------------------------------------------------------------------------------
# lighttp/src CMakeLists.txt
# ------------------------------------------------------------------------------

set(CURRENT_TARGET "ghttp")

# process config file
configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/http_config.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/http_config.h"
    @ONLY)
if (NOT ${CMAKE_CURRENT_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    include_directories(${CMAKE_CURRENT_BINARY_DIR})
endif()

include_directories(${PROJECT_SOURCE_DIR}/include)

set(SRCS_${CURRENT_TARGET}
    ghttp.c
    http_base64.c
    http_date.c
    http_hdrs.c
    http_req.c
    http_resp.c
    http_trans.c
    http_uri.c
    )

foreach(f IN LISTS SRCS_${CURRENT_TARGET})
  get_filename_component(b ${f} NAME)
  set_source_files_properties(${f} PROPERTIES
    COMPILE_DEFINITIONS "__FILE_NAME__=\"${b}\"")
endforeach()

if(USE_WOLFSSL)
    set(depends_external external-wolfssl)
    include_directories(${WOLFSSL_INCLUDE_DIRS})
    link_directories(${WOLFSSL_LIBRARIES})
elseif(USE_MBEDTLS)
    set(depends_external external-mbedtls)
    include_directories(${MBEDTLS_INCLUDE_DIRS})
    link_directories(${MBEDTLS_LIBRARIES})
elseif(USE_OPENSSL)
    set(depends_external external-openssl)
    include_directories(${OPENSSL_INCLUDE_DIRS})
    link_directories(${OPENSSL_LIBRARIES})
endif()

# build static target
if(WITH_STATIC)
    add_library(${CURRENT_TARGET}_STATIC STATIC ${SRCS_${CURRENT_TARGET}})
    set_target_properties(${CURRENT_TARGET}_STATIC PROPERTIES OUTPUT_NAME ${CURRENT_TARGET})
    target_compile_definitions(${CURRENT_TARGET}_STATIC PRIVATE "-D__PROJECT__=\"[${CURRENT_TARGET}]\"")
    if (USE_WOLFSSL OR USE_MBEDTLS OR USE_OPENSSL)
        add_dependencies(${CURRENT_TARGET}_STATIC ${depends_external})
    endif()
    install(TARGETS ${CURRENT_TARGET}_STATIC
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        )
endif(WITH_STATIC)

# build shared target
if(WITH_SHARED)
    add_library(${CURRENT_TARGET}_SHARED SHARED ${SRCS_${CURRENT_TARGET}})
    set_target_properties(${CURRENT_TARGET}_SHARED PROPERTIES OUTPUT_NAME ${CURRENT_TARGET})
    set_target_properties(${CURRENT_TARGET}_SHARED PROPERTIES VERSION ${LIBGHTTP_VERSION} SOVERSION ${LIBGHTTP_VERSION_MAJOR})
    target_compile_definitions(${CURRENT_TARGET}_SHARED PRIVATE "-D__PROJECT__=\"[${CURRENT_TARGET}]\"")
    if(WITH_TLS)
        add_dependencies(${CURRENT_TARGET}_SHARED ${depends_external})
    endif()
    install(TARGETS ${CURRENT_TARGET}_SHARED
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        )
endif(WITH_SHARED)


add_custom_target(lib)
if(WITH_STATIC)
    add_dependencies(lib ${CURRENT_TARGET}_STATIC)
endif()
if(WITH_SHARED)
    add_dependencies(lib ${CURRENT_TARGET}_SHARED)
endif()
