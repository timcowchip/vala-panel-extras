set(PLUGIN_NAME volume)
set(VALA_FILES
    ${PLUGIN_NAME}.vala
    )
vala_precompile(VALA_C vala-panel-extras-${PLUGIN_NAME}
    ${VALA_FILES}
PACKAGES
    ${CORE_PACKAGES}
    internal
    alsa
    ${CANBERRA_PACKAGE}
OPTIONS
    --vapidir=${CMAKE_SOURCE_DIR}/vapi
    --vapidir=${CMAKE_BINARY_DIR}/lib
    --vapidir=${CMAKE_BINARY_DIR}/vapi
    --target-glib=2.50
    --gresources=${CMAKE_CURRENT_SOURCE_DIR}/${PLUGIN_NAME}.gresource.xml
    --thread
    ${CANBERRA_DEFINE}
)
#####
# Plugin Library
#####

add_executable (vala-panel-extras-${PLUGIN_NAME}
    ${VALA_C}
    ${RESOURCES}
)
if(ENABLE_LIBCANBERRA)
    set(CANBERRA_LIB PkgConfig::CANBERRA)
else()
    set(CANBERRA_LIB)
endif()

target_link_libraries (vala-panel-extras-${PLUGIN_NAME} PkgConfig::ALSA ${CANBERRA_LIB} internal)
add_custom_target(vala-files-${PLUGIN_NAME} SOURCES ${VALA_FILES})
# Install plugin stuffs
install(TARGETS vala-panel-extras-${PLUGIN_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/org.valapanel.${PLUGIN_NAME}.desktop DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications)
