# Install script for directory: /Users/atman/code/pylon/nng/src

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xlibraryx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES
    "/Users/atman/code/pylon/nng/libnng.0.0.0.dylib"
    "/Users/atman/code/pylon/nng/libnng.dylib"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libnng.0.0.0.dylib"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libnng.dylib"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      execute_process(COMMAND /usr/bin/install_name_tool
        -add_rpath "/usr/local/lib"
        "${file}")
      if(CMAKE_INSTALL_DO_STRIP)
        execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip" "${file}")
      endif()
    endif()
  endforeach()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xlibraryx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE STATIC_LIBRARY FILES "/Users/atman/code/pylon/nng/libnng_static.a")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libnng_static.a" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libnng_static.a")
    execute_process(COMMAND "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ranlib" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libnng_static.a")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/nng.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/compat/nanomsg" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/compat/nanomsg/nn.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/supplemental/http" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/supplemental/http/http.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/supplemental/tls" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/supplemental/tls/tls.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/supplemental/util" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/supplemental/util/options.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/supplemental/util" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/supplemental/util/platform.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/bus0" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/bus0/bus.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/pair0" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/pair0/pair.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/pair1" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/pair1/pair.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/pipeline0" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/pipeline0/push.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/pipeline0" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/pipeline0/pull.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/pubsub0" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/pubsub0/pub.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/pubsub0" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/pubsub0/sub.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/reqrep0" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/reqrep0/req.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/reqrep0" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/reqrep0/rep.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/survey0" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/survey0/survey.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/protocol/survey0" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/protocol/survey0/respond.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/transport/inproc" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/transport/inproc/inproc.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/transport/ipc" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/transport/ipc/ipc.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/transport/tcp" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/transport/tcp/tcp.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/nng/transport/ws" TYPE FILE FILES "/Users/atman/code/pylon/nng/src/transport/ws/websocket.h")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/atman/code/pylon/nng/src/compat/nanomsg/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/supplemental/base64/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/supplemental/http/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/supplemental/sha1/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/supplemental/tls/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/supplemental/util/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/supplemental/websocket/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/protocol/bus0/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/protocol/pair0/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/protocol/pair1/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/protocol/pipeline0/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/protocol/pubsub0/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/protocol/reqrep0/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/protocol/survey0/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/transport/inproc/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/transport/ipc/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/transport/tcp/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/transport/tls/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/transport/ws/cmake_install.cmake")
  include("/Users/atman/code/pylon/nng/src/transport/zerotier/cmake_install.cmake")

endif()

