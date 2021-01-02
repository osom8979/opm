cmake_minimum_required (VERSION 3.3)

set (CMAKE_EXPORT_COMPILE_COMMANDS ON)
set (OPWM_NAME opwm)
set (OPWM_VERSION 0.1)
set (DWM_VERSION 6.2)

project (opwm)

add_executable (${OPWM_NAME}
    draw.c
    dwm.c
    util.c)
target_compile_definitions (
    ${OPWM_NAME} PRIVATE
    _DEFAULT_SOURCE
    _BSD_SOURCE
    _POSIX_C_SOURCE=2
    XINERAMA
    DWM_VERSION=\"${DWM_VERSION}\"
    OPWM_VERSION=\"${OPWM_VERSION}\")
target_include_directories (
    ${OPWM_NAME} PRIVATE
    /usr/X11R6/include
    /usr/include/freetype2
    ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/dwm)
target_compile_options (
    ${OPWM_NAME} PRIVATE
    -std=c99
    -pedantic
    -Wall
    -Wno-deprecated-declarations)
target_link_libraries (
    ${OPWM_NAME} PRIVATE
    -L/usr/X11R6/lib
    -lX11
    -lXinerama
    -lfontconfig
    -lXft)

set (COMPILE_COMMANDS_NAME cc)
set (COMPILE_COMMANDS_SRC "${CMAKE_BINARY_DIR}/compile_commands.json")
set (COMPILE_COMMANDS_DEST "${CMAKE_SOURCE_DIR}/compile_commands.json")
add_custom_target (${COMPILE_COMMANDS_NAME} DEPENDS ${COMPILE_COMMANDS_DEST})
add_custom_command (
    OUTPUT ${COMPILE_COMMANDS_DEST}
    COMMAND ${CMAKE_COMMAND} -E copy "${COMPILE_COMMANDS_SRC}" "${COMPILE_COMMANDS_DEST}"
    DEPENDS ${OPWM_NAME} ${COMPILE_COMMANDS_SRC}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR})

install (TARGETS ${OPWM_NAME})

