# ------------------------------------------------------------------------------
# libghttp/third_party CMakeLists.txt
# ------------------------------------------------------------------------------

include(ExternalProject)

if(WITH_STATIC)
  set(THIRDPARTY_WITH_STATIC "yes")
else()
  set(THIRDPARTY_WITH_STATIC "no")
endif()

if(WITH_SHARED)
  set(THIRDPARTY_WITH_SHARED "yes")
else()
  set(THIRDPARTY_WITH_SHARED "no")
endif()

if(WITH_WOLFSSL)
  ExternalProject_Add(external-wolfssl
    EXCLUDE_FROM_ALL TRUE
    BUILD_IN_SOURCE TRUE
    URL https://github.com/wolfSSL/wolfssl/archive/v3.15.7-stable.tar.gz
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ./autogen.sh &&
      ./configure
        CC=${CMAKE_C_COMPILER}
        CXX=${CMAKE_CXX_COMPILER}
        --enable-static=${THIRDPARTY_WITH_STATIC}
        --enable-shared=${THIRDPARTY_WITH_SHARED}
        --disable-debug
        --host=${C_COMPILER_MACHINE}
        --prefix=${WOLFSSL_PREFIX}
    BUILD_COMMAND make
    INSTALL_COMMAND make install
    TEST_COMMAND ""
    )
  install(DIRECTORY ${WOLFSSL_PREFIX}/include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
  install(DIRECTORY ${WOLFSSL_PREFIX}/lib/
    DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
elseif(WITH_MBEDTLS)

elseif(WITH_OPENSSL)

endif()
