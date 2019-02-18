# - Try to find Libbamf and its GTK component
#
# Copyright (C) 2018 Konstantin Pugin <ria.freelander@gmail.com>
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1.  Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 2.  Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER AND ITS CONTRIBUTORS ``AS
# IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR ITS
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


INCLUDE(FindPackageHandleStandardArgs)
include(GNUInstallDirs)
FIND_PACKAGE(PkgConfig QUIET)
PKG_CHECK_MODULES(PC_BAMF QUIET libbamf3)

FIND_LIBRARY(BAMF_LIB_LIBRARY
    NAMES bamf3
    HINTS ${PC_BAMF_LIBDIR}
          ${PC_BAMF_LIBRARY_DIRS}
)
FIND_PATH(BAMF_LIB_INCLUDE
    NAMES libbamf/libbamf.h
    HINTS ${PC_BAMF_INCLUDEDIR}
          ${PC_BAMF_INCLUDE_DIRS}
    PATH_SUFFIXES libbamf3
)

SET(BAMF_LIB_INCLUDE_DIRS ${BAMF_LIB_INCLUDE})

# Version detection
SET(BAMF_LIB_VERSION "${PC_BAMF_VERSION}")
SET(BAMF_VERSION "${BAMF_LIB_VERSION}")

if(BAMF_LIB_LIBRARY AND BAMF_LIB_INCLUDE_DIRS)
	set(BAMF_LIB_FOUND TRUE)
else()
	set(BAMF_LIB_FOUND FALSE)
endif()

mark_as_advanced(
	BAMF_LIB_LIBRARY
    BAMF_LIB_INCLUDE_DIRS
)
if(BAMF_LIB_FOUND)
    list(APPEND BAMF_LIBRARIES
                "${BAMF_LIB_LIBRARY}")
    list(APPEND BAMF_INCLUDE_DIRS
                "${BAMF_LIB_INCLUDE_DIRS}")
    set(BAMF_DEFINITIONS
            ${BAMF_DEFINITIONS}
            ${PC_BAMF_DEFINITIONS})
    if(NOT TARGET BAMF::LIB)
        add_library(BAMF::LIB UNKNOWN IMPORTED)
        set_target_properties(BAMF::LIB PROPERTIES
            IMPORTED_LOCATION "${BAMF_LIB_LIBRARY}"
            INTERFACE_COMPILE_OPTIONS "${PC_BAMF_DEFINITIONS}"
            INTERFACE_INCLUDE_DIRECTORIES "${BAMF_LIB_INCLUDE_DIRS}"
        )
    endif()
    list(APPEND BAMF_TARGETS
                "BAMF::LIB")
endif()
get_filename_component(BAMF_LIBDIR ${BAMF_LIB_LIBRARY} DIRECTORY)

find_program(BAMF_DAEMON_EXECUTABLE
	bamfdaemon
	HINTS ${CMAKE_INSTALL_FULL_LIBDIR}
		  ${CMAKE_INSTALL_FULL_LIBEXECDIR}
		  ${BAMF_LIBDIR}
	PATH_SUFFIXES bamf
)

SET(BAMF_DAEMON_VERSION "${BAMF_VERSION}")
if(BAMF_DAEMON_EXECUTABLE)
	set(BAMF_DAEMON_FOUND TRUE)
else()
	set(BAMF_DAEMON_FOUND FALSE)
endif()

mark_as_advanced(
	BAMF_DAEMON_EXECUTABLE
)
if(BAMF_DAEMON_FOUND)
	if(NOT TARGET BAMF::DAEMON)
	    add_executable(BAMF::DAEMON IMPORTED)
	endif()
	list(APPEND BAMF_TARGETS
	            "BAMF::DAEMON")
endif()

if(BAMF_DAEMON_FOUND OR BAMF_LIB_FOUND)
	set(BAMF_EXISTS TRUE)
endif()

FIND_PACKAGE_HANDLE_STANDARD_ARGS(BAMF
	REQUIRED_VARS
		BAMF_EXISTS	
    HANDLE_COMPONENTS
    VERSION_VAR
        BAMF_VERSION)


if(BAMF_LIBRARIES)
    list(REMOVE_DUPLICATES BAMF_LIBRARIES)
endif()
if(BAMF_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES BAMF_INCLUDE_DIRS)
endif()
if(BAMF_DEFINITIONS)
    list(REMOVE_DUPLICATES BAMF_DEFINITIONS)
endif()
if(BAMF_TARGETS)
    list(REMOVE_DUPLICATES BAMF_TARGETS)
endif()