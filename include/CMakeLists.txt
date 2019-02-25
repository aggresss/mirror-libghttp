# ------------------------------------------------------------------------------
# libghttp/include CMakeLists.txt
# ------------------------------------------------------------------------------

# export head file
file(GLOB ghttp_headers
  ghttp.h
  ghttp_constants.h
  )
install(FILES ${ghttp_headers}
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/ghttp
  PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
  )
