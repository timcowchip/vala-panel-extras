# Translations.cmake, CMake macros written for Marlin, feel free to re-use them
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

find_package(Gettext REQUIRED)

macro (add_translations_directory NLS_PACKAGE)
    add_custom_target (i18n ALL COMMENT “Building i18n messages.”)
    # be sure that all languages are present
    # Using all usual languages code from https://www.gnu.org/software/gettext/manual/html_node/Language-Codes.html#Language-Codes
    # Rare language codes should be added on-demand.
    set (LANGUAGES_NEEDED aa ab ae af ak am an ar as ast av ay az ba be bg bh bi bm bn bo br bs ca ce ch ckb co cr cs cu cv cy da de dv dz ee el en_AU en_CA en_GB eo es et eu fa ff fi fj fo fr fr_CA fy ga gd gl gn gu gv ha he hi ho hr ht hu hy hz ia id ie ig ii ik io is it iu ja jv ka kg ki kj kk kl km kn ko kr ks ku kv kw ky la lb lg li ln lo lt lu lv mg mh mi mk ml mn mo mr ms mt my na nb nd ne ng nl nn nb nr nv ny oc oj om or os pa pi pl ps pt pt_BR qu rm rn ro ru rue rw sa sc sd se sg si sk sl sm sma sn so sq sr ss st su sv sw ta te tg th ti tk tl tn to tr ts tt tw ty ug uk ur uz ve vi vo wa wo xh yi yo za zh zh_CN zh_HK zh_TW zu)
    string (REPLACE ";" " " LINGUAS "${LANGUAGES_NEEDED}")
    configure_file (${CMAKE_CURRENT_SOURCE_DIR}/LINGUAS.in ${CMAKE_CURRENT_BINARY_DIR}/LINGUAS)
    foreach (LANGUAGE_NEEDED ${LANGUAGES_NEEDED})
        create_po_file (${LANGUAGE_NEEDED})
    endforeach (LANGUAGE_NEEDED ${LANGUAGES_NEEDED})
    # generate .mo from .po
    file (GLOB PO_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.po)
    foreach (PO_INPUT ${PO_FILES})
        get_filename_component (PO_INPUT_BASE ${PO_INPUT} NAME_WE)
        set (MO_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PO_INPUT_BASE}.mo)
        set (PO_COPY ${CMAKE_CURRENT_BINARY_DIR}/${PO_INPUT_BASE}.po)
        file (COPY ${PO_INPUT} DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
        add_custom_command (TARGET i18n COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} -o ${MO_OUTPUT} ${PO_INPUT})

        install (FILES ${MO_OUTPUT} DESTINATION
            share/locale/${PO_INPUT_BASE}/LC_MESSAGES
            RENAME ${NLS_PACKAGE}.mo
            COMPONENT ${ARGV1})
    endforeach (PO_INPUT ${PO_FILES})
    #Create *.desktop files
    file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_SOURCE_DIR}/ ${CMAKE_SOURCE_DIR}/*.desktop.plugin.in)
    foreach(PLUGIN_DESKTOP_IN_FILE ${SOURCE_FILES})
        get_filename_component( BASE_NAME ${PLUGIN_DESKTOP_IN_FILE} NAME )
        string(REGEX REPLACE ".desktop.plugin.in$" "" PLUGIN_FILE ${BASE_NAME})
        get_filename_component( BASE_DIRECTORY ${PLUGIN_DESKTOP_IN_FILE} PATH )
        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/${BASE_DIRECTORY})
        add_custom_command (TARGET i18n COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} --desktop --keyword=Name --keyword=Description --keyword=Help -d ${CMAKE_CURRENT_BINARY_DIR} --template ${CMAKE_SOURCE_DIR}/${PLUGIN_DESKTOP_IN_FILE} -o ${CMAKE_BINARY_DIR}/${BASE_DIRECTORY}/${PLUGIN_FILE}.plugin)
    endforeach()
    file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_SOURCE_DIR}/ ${CMAKE_SOURCE_DIR}/*.desktop.in)
    foreach(DESKTOP_IN_FILE ${SOURCE_FILES})
        get_filename_component( BASE_NAME ${DESKTOP_IN_FILE} NAME )
        string(REGEX REPLACE ".desktop.in$" "" PLUGIN_FILE ${BASE_NAME})
        get_filename_component( BASE_DIRECTORY ${DESKTOP_IN_FILE} PATH )
        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/${BASE_DIRECTORY})
        add_custom_command (TARGET i18n COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} --desktop -d ${CMAKE_CURRENT_BINARY_DIR} --template ${CMAKE_SOURCE_DIR}/${DESKTOP_IN_FILE} -o ${CMAKE_BINARY_DIR}/${BASE_DIRECTORY}/${PLUGIN_FILE}.desktop)
    endforeach()
    file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_SOURCE_DIR}/ ${CMAKE_SOURCE_DIR}/*.desktop.xfce.in)
    foreach(XFCE_DESKTOP_IN_FILE ${SOURCE_FILES})
        get_filename_component( BASE_NAME ${XFCE_DESKTOP_IN_FILE} NAME )
        string(REGEX REPLACE ".desktop.xfce.in$" "" PLUGIN_FILE ${BASE_NAME})
        get_filename_component( BASE_DIRECTORY ${XFCE_DESKTOP_IN_FILE} PATH )
        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/${BASE_DIRECTORY})
        add_custom_command (TARGET i18n COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} --desktop --keyword=Name --keyword=Comment --keyword=Help -d ${CMAKE_CURRENT_BINARY_DIR} --template ${CMAKE_SOURCE_DIR}/${XFCE_DESKTOP_IN_FILE} -o ${CMAKE_BINARY_DIR}/${BASE_DIRECTORY}/${PLUGIN_FILE}.desktop)
    endforeach()
    file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_SOURCE_DIR}/ ${CMAKE_SOURCE_DIR}/*.appdata.xml.in)
    foreach(APPDATA_XML_IN_FILE ${SOURCE_FILES})
        get_filename_component( BASE_NAME ${APPDATA_XML_IN_FILE} NAME )
        string(REGEX REPLACE ".appdata.xml.in$" "" PLUGIN_FILE ${BASE_NAME})
        get_filename_component( BASE_DIRECTORY ${APPDATA_XML_IN_FILE} PATH )
        file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/${BASE_DIRECTORY})
        add_custom_command (TARGET i18n COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} --xml -Lappdata -d ${CMAKE_CURRENT_BINARY_DIR} --template ${CMAKE_SOURCE_DIR}/${APPDATA_XML_IN_FILE} -o ${CMAKE_BINARY_DIR}/${BASE_DIRECTORY}/${PLUGIN_FILE}.appdata.xml)
    endforeach()
endmacro (add_translations_directory)

# Apply the right default template.
macro (create_po_file LANGUAGE_NEEDED)
    set (FILE ${CMAKE_CURRENT_SOURCE_DIR}/${LANGUAGE_NEEDED}.po)
    if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${LANGUAGE_NEEDED}.po)
        file (APPEND ${FILE} "msgid \"\"\n")
        file (APPEND ${FILE} "msgstr \"\"\n")
        file (APPEND ${FILE} "\"MIME-Version: 1.0\\n\"\n")
        file (APPEND ${FILE} "\"Content-Type: text/plain; charset=UTF-8\\n\"\n")

        if ("${LANGUAGE_NEEDED}" STREQUAL "ja"
            OR "${LANGUAGE_NEEDED}" STREQUAL "vi"
            OR "${LANGUAGE_NEEDED}" STREQUAL "ko")
                file (APPEND ${FILE} "\"Plural-Forms: nplurals=2; plural=n == 1 ? 0 : 1;\\n\"\n")
        elseif ("${LANGUAGE_NEEDED}" STREQUAL "en"
            OR "${LANGUAGE_NEEDED}" STREQUAL "de"
            OR "${LANGUAGE_NEEDED}" STREQUAL "nl"
            OR "${LANGUAGE_NEEDED}" STREQUAL "sv"
            OR "${LANGUAGE_NEEDED}" STREQUAL "nb"
            OR "${LANGUAGE_NEEDED}" STREQUAL "nn"
            OR "${LANGUAGE_NEEDED}" STREQUAL "nb"
            OR "${LANGUAGE_NEEDED}" STREQUAL "no"
            OR "${LANGUAGE_NEEDED}" STREQUAL "fo"
            OR "${LANGUAGE_NEEDED}" STREQUAL "es"
            OR "${LANGUAGE_NEEDED}" STREQUAL "pt"
            OR "${LANGUAGE_NEEDED}" STREQUAL "it"
            OR "${LANGUAGE_NEEDED}" STREQUAL "bg"
            OR "${LANGUAGE_NEEDED}" STREQUAL "he"
            OR "${LANGUAGE_NEEDED}" STREQUAL "fi"
            OR "${LANGUAGE_NEEDED}" STREQUAL "et"
            OR "${LANGUAGE_NEEDED}" STREQUAL "eo"
            OR "${LANGUAGE_NEEDED}" STREQUAL "hu"
            OR "${LANGUAGE_NEEDED}" STREQUAL "tr"
            OR "${LANGUAGE_NEEDED}" STREQUAL "es")
                file (APPEND ${FILE} "\"Plural-Forms: nplurals=2; plural=n != 1;\\n\"\n")
        elseif ("${LANGUAGE_NEEDED}" STREQUAL "fr"
            OR "${LANGUAGE_NEEDED}" STREQUAL "fr_CA"
            OR "${LANGUAGE_NEEDED}" STREQUAL "pt_BR")
                file (APPEND ${FILE} "\"Plural-Forms: nplurals=2; plural=n>1;\\n\"\n")
        elseif ("${LANGUAGE_NEEDED}" STREQUAL "lv")
                file (APPEND ${FILE} "\"Plural-Forms: nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n != 0 ? 1 : 2;\\n\"\n")
        elseif ("${LANGUAGE_NEEDED}" STREQUAL "ro")
                file (APPEND ${FILE} "\"Plural-Forms: nplurals=3; plural=n==1 ? 0 : (n==0 || (n%100 > 0 && n%100 < 20)) ? 1 : 2;\\n\"\n")
        elseif ("${LANGUAGE_NEEDED}" STREQUAL "lt")
                file (APPEND ${FILE} "\"Plural-Forms: nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && (n%100<10 || n%100>=20) ? 1 : 2;\\n\"\n")
        elseif ("${LANGUAGE_NEEDED}" STREQUAL "ru"
            OR "${LANGUAGE_NEEDED}" STREQUAL "uk"
            OR "${LANGUAGE_NEEDED}" STREQUAL "be"
            OR "${LANGUAGE_NEEDED}" STREQUAL "sr"
            OR "${LANGUAGE_NEEDED}" STREQUAL "hr")
                file (APPEND ${FILE} "\"Plural-Forms: nplurals=3; plural=n%10==1 && n%100!=11 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;\\n\"\n")
        elseif ("${LANGUAGE_NEEDED}" STREQUAL "cs"
            OR "${LANGUAGE_NEEDED}" STREQUAL "sk")
                file (APPEND ${FILE} "\"Plural-Forms: nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;\\n\"\n")
        elseif ("${LANGUAGE_NEEDED}" STREQUAL "pl")
                file (APPEND ${FILE} "\"Plural-Forms: nplurals=3; plural=n==1 ? 0 : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? 1 : 2;\\n\"\n")
        elseif ("${LANGUAGE_NEEDED}" STREQUAL "sl")
                file (APPEND ${FILE} "\"Plural-Forms: nplurals=4; plural=n%100==1 ? 0 : n%100==2 ? 1 : n%100==3 || n%100==4 ? 2 : 3;\\n\"\n")
        endif ()

    endif ()
endmacro (create_po_file)

macro (add_translations_catalog NLS_PACKAGE)
    add_custom_target (pot COMMENT “Building translation catalog.”)
    find_program (XGETTEXT_EXECUTABLE xgettext)

    set(C_SOURCE "")
    set(VALA_SOURCE "")
    set(GLADE_SOURCE "")
    set(PLUGIN_DESKTOP_SOURCE "")
    set(DESKTOP_SOURCE "")
    set(GSETTINGS_SOURCE "")
    set(APPDATA_SOURCE "")

    foreach(FILES_INPUT ${ARGN})
        set(BASE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${FILES_INPUT})

        file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/ ${BASE_DIRECTORY}/*.c)
        foreach(C_FILE ${SOURCE_FILES})
            set(C_SOURCE ${C_SOURCE} ${C_FILE})
        endforeach()

        file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/ ${BASE_DIRECTORY}/*.vala)
        foreach(VALA_C_FILE ${SOURCE_FILES})
            set(VALA_SOURCE ${VALA_SOURCE} ${VALA_C_FILE})
        endforeach()

        file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/ ${BASE_DIRECTORY}/*.ui)
        foreach(GLADE_C_FILE ${SOURCE_FILES})
            set(GLADE_SOURCE ${GLADE_SOURCE} ${GLADE_C_FILE})
        endforeach()

        file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/ ${BASE_DIRECTORY}/*.desktop.plugin.in)
        foreach(PLUGIN_DESKTOP_IN_FILE ${SOURCE_FILES})
            set(PLUGIN_DESKTOP_SOURCE ${PLUGIN_DESKTOP_SOURCE} ${PLUGIN_DESKTOP_IN_FILE})
        endforeach()

        file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/ ${BASE_DIRECTORY}/*.desktop.xfce.in)
        foreach(XFCE_DESKTOP_IN_FILE ${SOURCE_FILES})
            set(XFCE_DESKTOP_SOURCE ${XFCE_DESKTOP_SOURCE} ${XFCE_DESKTOP_IN_FILE})
        endforeach()

        file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/ ${BASE_DIRECTORY}/*.gschema.xml.in)
        foreach(GSETTINGS_IN_FILE ${SOURCE_FILES})
            set(GSETTINGS_SOURCE ${GSETTINGS_SOURCE} ${GSETTINGS_IN_FILE})
        endforeach()

        file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/ ${BASE_DIRECTORY}/*.appdata.xml.in)
        foreach(APPDATA_IN_FILE ${SOURCE_FILES})
            set(APPDATA_SOURCE ${APPDATA_SOURCE} ${APPDATA_IN_FILE})
        endforeach()

        file (GLOB_RECURSE SOURCE_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/ ${BASE_DIRECTORY}/*.desktop.in)
        foreach(DESKTOP_IN_FILE ${SOURCE_FILES})
            set(DESKTOP_SOURCE ${DESKTOP_SOURCE} ${DESKTOP_IN_FILE})
        endforeach()
    endforeach()

    set(BASE_XGETTEXT_COMMAND
        ${XGETTEXT_EXECUTABLE} -d ${NLS_PACKAGE}
        -o ${CMAKE_CURRENT_SOURCE_DIR}/${NLS_PACKAGE}.pot
        --add-comments="/" --keyword="_" --keyword="N_" --keyword="C_:1c,2" --keyword="NC_:1c,2" --keyword="ngettext:1,2" --keyword="Q_:1g" --from-code=UTF-8)

   set(CONTINUE_FLAG "")

    IF(NOT "${C_SOURCE}" STREQUAL "")
        add_custom_command(TARGET pot WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${BASE_XGETTEXT_COMMAND} ${C_SOURCE})
        set(CONTINUE_FLAG "-j")
    ENDIF()

    IF(NOT "${VALA_SOURCE}" STREQUAL "")
        add_custom_command(TARGET pot WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${BASE_XGETTEXT_COMMAND} ${CONTINUE_FLAG} -LC\# ${VALA_SOURCE})
        set(CONTINUE_FLAG "-j")
    ENDIF()

    IF(NOT "${GLADE_SOURCE}" STREQUAL "")
        add_custom_command (TARGET pot WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${BASE_XGETTEXT_COMMAND} ${CONTINUE_FLAG} -LGlade ${GLADE_SOURCE})
        set(CONTINUE_FLAG "-j")
    ENDIF()

    IF(NOT "${APPDATA_SOURCE}" STREQUAL "")
        add_custom_command (TARGET pot WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${BASE_XGETTEXT_COMMAND} ${CONTINUE_FLAG} -Lappdata ${APPDATA_SOURCE})
        set(CONTINUE_FLAG "-j")
    ENDIF()

    IF(NOT "${PLUGIN_DESKTOP_SOURCE}" STREQUAL "")
        add_custom_command (TARGET pot WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${BASE_XGETTEXT_COMMAND} ${CONTINUE_FLAG} -Ldesktop -kName -kDescription -kHelp ${PLUGIN_DESKTOP_SOURCE})
        set(CONTINUE_FLAG "-j")
    ENDIF()

    IF(NOT "${XFCE_DESKTOP_SOURCE}" STREQUAL "")
        add_custom_command (TARGET pot WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${BASE_XGETTEXT_COMMAND} ${CONTINUE_FLAG} -Ldesktop -kName -kComment -kHelp ${XFCE_DESKTOP_SOURCE})
        set(CONTINUE_FLAG "-j")
    ENDIF()

    IF(NOT "${DESKTOP_SOURCE}" STREQUAL "")
        add_custom_command (TARGET pot WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${BASE_XGETTEXT_COMMAND} ${CONTINUE_FLAG} -Ldesktop ${DESKTOP_SOURCE})
        set(CONTINUE_FLAG "-j")
    ENDIF()

    IF(NOT "${GSETTINGS_SOURCE}" STREQUAL "")
        add_custom_command (TARGET pot WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} COMMAND ${BASE_XGETTEXT_COMMAND} ${CONTINUE_FLAG} -LGsettings ${XML_SOURCE})
    ENDIF()
endmacro ()
