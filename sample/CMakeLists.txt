CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
PROJECT(myclient)

INCLUDE(GNUInstallDirs)
INCLUDE(FindPkgConfig)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -Wall")

pkg_check_modules(pkgs REQUIRED
	glib-2.0
	gio-2.0
	gio-unix-2.0
	gthread-2.0
)

pkg_check_modules(include_pkgs REQUIRED
	iotivity
)

FOREACH(flag ${pkgs_CFLAGS})
	SET(EXTRA_CFLAGS "${EXTRA_CFLAGS} ${flag}")
ENDFOREACH(flag)

FOREACH(flag ${include_pkgs_CFLAGS})
	SET(EXTRA_CFLAGS "${EXTRA_CFLAGS} ${flag}")
ENDFOREACH(flag)

INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/include)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${EXTRA_CFLAGS} -fprofile-arcs -ftest-coverage")
SET(CMAKE_CXX_FLAGS ${CMAKE_C_FLAGS})

SET(SRCS
	src/main.c
)

ADD_EXECUTABLE(${PROJECT_NAME} ${SRCS})
TARGET_LINK_LIBRARIES(${PROJECT_NAME}
	/usr/lib/liboctbstack.a
	/usr/lib/liblogger.a
	/usr/lib/libconnectivity_abstraction.a
	/usr/lib/libocsrm.a
	/usr/lib/libmbedx509.a
	/usr/lib/libmbedtls.a
	/usr/lib/libmbedcrypto.a
	/usr/lib/libcoap.a
	/usr/lib/libroutingmanager.a
	/usr/lib/libc_common.a
	${pkgs_LDFLAGS} "-lgcov --coverage")

INSTALL(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_BINDIR})

