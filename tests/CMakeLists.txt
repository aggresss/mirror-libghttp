if(USE_WOLFSSL)
  set(link_external wolfssl m)
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
include_directories(${DEPENDS_DIRS})

link_directories(${PROJECT_BINARY_DIR}/src)
set(SRCS_1
  test_ghttp.c
  )
aux_source_directory(${DEPENDS_DIRS}/log SRCS_1)
aux_source_directory(${DEPENDS_DIRS}/flag SRCS_1)

foreach(f IN LISTS SRCS_1)
  get_filename_component(b ${f} NAME)
  set_source_files_properties(${f} PROPERTIES
    COMPILE_DEFINITIONS "__FILE_NAME__=\"${b}\"")
endforeach()

set(TARGET_1 "test_ghttp")
add_executable(${TARGET_1} ${SRCS_1})
add_dependencies(${TARGET_1} lib)
target_compile_options(${TARGET_1} PRIVATE -std=c99)
target_compile_definitions(${TARGET_1} PRIVATE "-D__PROJECT__=\"[${TARGET_1}]\"")
target_link_libraries(${TARGET_1} ghttp)
if (WITH_TLS)
  target_link_libraries(${TARGET_1} ${link_external})
endif()

add_test(NAME test_http_get COMMAND test_ghttp --http_get)

