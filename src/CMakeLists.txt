# process config file
configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/http_config.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/http_config.h"
)
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
    set(external_libs wolfssl)
    set(external_INCLUDE_DIRS ${wolfssl_INCLUDE_DIRS})
    set(external_LIBRARIES ${wolfssl_LIBRARIES})
elseif(USE_MBEDTLS)

elseif(USE_OPENSSL)

endif()

include_directories(${external_INCLUDE_DIRS})

# build static target
if(WITH_STATIC)
    add_library(ghttp_static STATIC ${src_libghttp})
    set_target_properties(ghttp_static PROPERTIES OUTPUT_NAME ghttp)
    add_dependencies(ghttp_static ${external_libs})
    target_link_libraries(ghttp_static ${external_LIBRARIES})

    install(TARGETS ghttp_static
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
            PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
endif(WITH_STATIC)

# build shared target
if(WITH_SHARED)
    add_library(ghttp_shared SHARED ${src_libghttp})
    set_target_properties(ghttp_shared PROPERTIES OUTPUT_NAME ghttp)
    set_target_properties(ghttp_shared PROPERTIES VERSION ${LIBGHTTP_VERSION} SOVERSION ${LIBGHTTP_VERSION_MAJOR})
    target_link_libraries(ghttp_shared ${external_LIBRARIES})

    install(TARGETS ghttp_shared
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
            PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
endif(WITH_SHARED)

add_custom_target(lib DEPENDS ghttp_static)
if(WITH_SHARED)
    add_dependencies(lib ghttp_shared)
endif()
