if(USE_WOLFSSL)
    set(link_external wolfssl)
    include_directories(${WOLFSSL_INCLUDE_DIRS})
    link_directories(${WOLFSSL_LIBRARIES})
elseif(USE_MBEDTLS)
    set(link_external mbedtls)
    include_directories(${MBEDTLS_INCLUDE_DIRS})
    link_directories(${MBEDTLS_LIBRARIES})
elseif(USE_OPENSSL)
    set(link_external openssl)
    include_directories(${OPENSSL_INCLUDE_DIRS})
    link_directories(${OPENSSL_LIBRARIES})
endif()

include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(${PROJECT_SOURCE_DIR}/deps)
link_directories(${PROJECT_BINARY_DIR}/src)
set(src_test_ghttp
    ${PROJECT_SOURCE_DIR}/deps/log/log.c
    ${PROJECT_SOURCE_DIR}/deps/flag/flag.c
    test_ghttp.c
    )

add_executable(test_ghttp ${src_test_ghttp})
add_dependencies(test_ghttp lib)
target_link_libraries(test_ghttp ghttp)
if (WITH_TLS)
    target_link_libraries(test_ghttp ${link_external})
endif()

add_test(NAME test_http_get COMMAND test_ghttp --http_get)

