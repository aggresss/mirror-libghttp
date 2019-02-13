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


add_test(NAME test_ghttp_get COMMAND test_ghttp --http_get)

