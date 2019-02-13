# process config file
configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/http_config.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/http_config.h"
    @ONLY)
if (NOT ${CMAKE_CURRENT_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    include_directories(${CMAKE_CURRENT_BINARY_DIR})
endif()

include_directories(${PROJECT_SOURCE_DIR}/include)

set(src_libghttp
    ghttp.c
    http_base64.c
    http_date.c
    http_hdrs.c
    http_req.c
    http_resp.c
    http_trans.c
    http_uri.c
    )

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
    add_library(ghttp_static STATIC ${src_libghttp})
    set_target_properties(ghttp_static PROPERTIES OUTPUT_NAME ghttp)
    if (USE_WOLFSSL OR USE_MBEDTLS OR USE_OPENSSL)
        add_dependencies(ghttp_static ${depends_external})
    endif()
    install(TARGETS ghttp_static
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        )
endif(WITH_STATIC)

# build shared target
if(WITH_SHARED)
    add_library(ghttp_shared SHARED ${src_libghttp})
    set_target_properties(ghttp_shared PROPERTIES OUTPUT_NAME ghttp)
    set_target_properties(ghttp_shared PROPERTIES VERSION ${LIBGHTTP_VERSION} SOVERSION ${LIBGHTTP_VERSION_MAJOR})
    if(WITH_TLS)
        add_dependencies(ghttp_shared ${depends_external})
    endif()
    install(TARGETS ghttp_shared
        DESTINATION ${CMAKE_INSTALL_LIBDIR}
        PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
        )
endif(WITH_SHARED)


add_custom_target(lib)
if(WITH_STATIC)
    add_dependencies(lib ghttp_static)
endif()

if(WITH_SHARED)
    add_dependencies(lib ghttp_shared)
endif()
