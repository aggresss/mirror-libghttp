include(ExternalProject)

if(USE_WOLFSSL)
    ExternalProject_Add(external-wolfssl
        GIT_REPOSITORY https://github.com/wolfssl/wolfssl.git
        GIT_TAG v3.15.7-stable
        SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/wolfssl
        CONFIGURE_COMMAND ./autogen.sh &&
            ./configure
            --enable-static
            --enable-shared
            --disable-debug
            --host=CC=${CMAKE_C_COMPILER_PREFIX}
            --prefix=${CMAKE_CURRENT_SOURCE_DIR}/wolfssl/output/${TARGET_HOST}
        BUILD_COMMAND make
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND make install
    )
endif(USE_WOLFSSL)

