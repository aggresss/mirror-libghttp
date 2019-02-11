option(WITH_STATIC "Build libghttp static library." ON)
option(WITH_SHARED "Build libghttp shared library." OFF)

if (NOT WITH_STATIC AND NOT WITH_SHARED)
    message(FATAL_ERROR "Need to choose static or shared libghttp build!")
endif()

# process config file
configure_file (
    "${CMAKE_CURRENT_SOURCE_DIR}/http_config.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/http_config.h"
)
if (NOT ${CMAKE_CURRENT_BINARY_DIR} STREQUAL ${CMAKE_CURRENT_SOURCE_DIR})
    include_directories(${CMAKE_CURRENT_BINARY_DIR})
endif()

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

# build static target
if(WITH_STATIC)
    add_library(ghttp_static STATIC ${src_libghttp})
    set_target_properties(ghttp_static PROPERTIES OUTPUT_NAME ghttp)

    install(TARGETS ghttp_static
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
            PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
endif(WITH_STATIC)

# build shared target
if(WITH_SHARED)
    add_library(ghttp_shared SHARED ${src_libghttp})
    set_target_properties(ghttp_shared PROPERTIES OUTPUT_NAME ghttp)
    set_target_properties(ghttp_shared PROPERTIES VERSION ${LIBGHTTP_VERSION} SOVERSION ${LIBGHTTP_VERSION_MAJOR})

    install(TARGETS ghttp_shared
            DESTINATION ${CMAKE_INSTALL_LIBDIR}
            PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE)
endif(WITH_SHARED)

add_custom_target(lib DEPENDS ghttp_static)
if(WITH_SHARED)
    add_dependencies(lib ghttp_shared)
endif()
