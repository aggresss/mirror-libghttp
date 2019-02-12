include(ExternalProject)

if(WITH_STATIC)
    set(THIRDPARTY_WITH_STATIC, "yes")
else()
    set(THIRDPARTY_WITH_STATIC, "no")
endif()

if(WITH_SHARED)
    set(THIRDPARTY_WITH_SHARED, "yes")
else()
    set(THIRDPARTY_WITH_SHARED, "no")
endif()

if(USE_WOLFSSL)
    ExternalProject_Add(wolfssl
        EXCLUDE_FROM_ALL TRUE
        GIT_REPOSITORY aggresss@link.router7.com:git/wolfssl
        GIT_TAG v3.15.7-stable
        SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/wolfssl
        CONFIGURE_COMMAND ./autogen.sh &&
            ./configure
            --enable-static=${THIRDPARTY_WITH_STATIC}
            --enable-shared=${THIRDPARTY_WITH_SHARED}
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
