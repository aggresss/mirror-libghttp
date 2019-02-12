include(ExternalProject)

if(WITH_STATIC)
    set(THIRDPARTY_STATIC, "--enable-static")
else()
    set(THIRDPARTY_STATIC, "--disable-static")
endif()

if(WITH_SHARED)
    set(THIRDPARTY_SHARED, "--enable-shared")
else()
    set(THIRDPARTY_SHARED, "--disable-shared")
endif()

if(USE_WOLFSSL)
    ExternalProject_Add(wolfssl
        EXCLUDE_FROM_ALL TRUE
        GIT_REPOSITORY https://github.com/wolfssl/wolfssl.git
        GIT_TAG v3.15.7-stable
        SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/wolfssl
        CONFIGURE_COMMAND ./autogen.sh &&
            ./configure
            --enable-static
            --disable-shared
            --disable-debug
            --host=${C_COMPILER_PREFIX}
            --prefix=${CMAKE_CURRENT_BINARY_DIR}/wolfssl/output
        BUILD_COMMAND make
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND make install)
    set(wolfssl_INCLUDE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/wolfssl/output/include PARENT_SCOPE)
    set(wolfssl_LIBRARIES ${CMAKE_CURRENT_BINARY_DIR}/wolfssl/output/lib PARENT_SCOPE)
elseif(USE_MBEDTLS)

elseif(USE_OPENSSL)

endif()
