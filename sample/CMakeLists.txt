CMAKE_MINIMUM_REQUIRED(VERSION 2.6)
PROJECT(myclient)

INCLUDE(GNUInstallDirs)
INCLUDE(FindPkgConfig)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -Wall -Werror")

pkg_check_modules(pkgs REQUIRED
	# Please put the modules with build dependencies here.
	# e.g. glib-2.0
)

# Just separated from the above pkgs for the iotivity static build testing.
pkg_check_modules(iotivity_pkgs REQUIRED
	iotivity
)

FOREACH(flag ${pkgs_CFLAGS})
	SET(EXTRA_CFLAGS "${EXTRA_CFLAGS} ${flag}")
ENDFOREACH(flag)

FOREACH(flag ${iotivity_pkgs_CFLAGS})
	SET(EXTRA_CFLAGS "${EXTRA_CFLAGS} ${flag}")
ENDFOREACH(flag)

INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/include)

SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${EXTRA_CFLAGS}")
SET(CMAKE_CXX_FLAGS ${CMAKE_C_FLAGS})

SET(SRCS
	src/main.c
	src/security.c
)

# Build with iotivity shared library
ADD_EXECUTABLE(${PROJECT_NAME} ${SRCS})
TARGET_LINK_LIBRARIES(${PROJECT_NAME} ${pkgs_LDFLAGS} ${iotivity_pkgs_LDFLAGS})

# Build with iotivity static library
ADD_EXECUTABLE(${PROJECT_NAME}_static ${SRCS})
TARGET_LINK_LIBRARIES(${PROJECT_NAME}_static
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
	${pkgs_LDFLAGS} "-lgcov -lpthread")

ADD_CUSTOM_TARGET(oic_svr_db.dat ALL
	COMMAND json2cbor ${CMAKE_SOURCE_DIR}/json/oic_svr_db.json ${CMAKE_BINARY_DIR}/oic_svr_db.dat
	COMMENT "Generating CBOR file for SVR - oic_svr_db.dat")

INSTALL(TARGETS ${PROJECT_NAME} DESTINATION ${CMAKE_INSTALL_BINDIR})
INSTALL(TARGETS ${PROJECT_NAME}_static DESTINATION ${CMAKE_INSTALL_BINDIR})

