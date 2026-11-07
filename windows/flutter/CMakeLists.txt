cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
include(${EPHEMERAL_DIR}/generated_config.cmake)

# TODO: Move the rest of this into files in ephemeral/. See
# https://github.com/flutter/flutter/issues/57146.

# Serves the same purpose as list(TRANSFORM ... PREPEND ...),
# which isn't available in 3.10.
function(list_prepend LIST_NAME PREFIX)
    set(NEW_LIST "")
    foreach(element ${${LIST_NAME}})
        list(APPEND NEW_LIST "${PREFIX}${element}")
    endforeach(element)
    set(${LIST_NAME} "${NEW_LIST}" PARENT_SCOPE)
endfunction()

# === Flutter Library ===
set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/flutter_windows.dll")

# Published to parent scope for install step.
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE "${EPHEMERAL_DIR}/icudtl.dat" PARENT_SCOPE)
set(PROJECT_BUILD_DIR "${PROJECT_DIR}/build/" PARENT_SCOPE)
set(AOT_LIBRARY "${PROJECT_DIR}/build/windows/x64/app.so" PARENT_SCOPE)

list(APPEND FLUTTER_LIBRARY_HEADERS
  "flutter_export.h"
  "flutter_windows.h"
  "flutter_messenger.h"
  "flutter_plugin_registrar.h"
  "flutter_texture_registrar.h"
)
list_prepend(FLUTTER_LIBRARY_HEADERS "${EPHEMERAL_DIR}/cpp_client_wrapper/include/flutter/")
add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}"
)
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}")
add_dependencies(flutter flutter_assemble)

# === Wrapper ===
list(APPEND CPP_WRAPPER_SOURCES_CORE
  "core_implementations.cc"
  "standard_codec.cc"
)
list_prepend(CPP_WRAPPER_SOURCES_CORE "${EPHEMERAL_DIR}/cpp_client_wrapper/")
list(APPEND CPP_WRAPPER_SOURCES_PLUGIN
  "plugin_registrar.cc"
)
list_prepend(CPP_WRAPPER_SOURCES_PLUGIN "${EPHEMERAL_DIR}/cpp_client_wrapper/")
list(APPEND CPP_WRAPPER_SOURCES_APP
  "flutter_engine.cc"
  "flutter_view_controller.cc"
)
list_prepend(CPP_WRAPPER_SOURCES_APP "${EPHEMERAL_DIR}/cpp_client_wrapper/")

# Wrapper sources needed to embed a Flutter application.
add_library(flutter_wrapper_app STATIC
  ${CPP_WRAPPER_SOURCES_APP}
  ${CPP_WRAPPER_SOURCES_CORE}
)

# Wrapper sources needed for a plugin.
add_library(flutter_wrapper_plugin STATIC
  ${CPP_WRAPPER_SOURCES_PLUGIN}
  ${CPP_WRAPPER_SOURCES_CORE}
)

# Set target attributes for the wrappers.
foreach(target FLUTTER_WRAPPER_APP FLUTTER_WRAPPER_PLUGIN)
  string(TOLOWER ${target} target_lower)
  if(TARGET ${target_lower})
    apply_standard_settings(${target_lower})
    set_target_properties(${target_lower} PROPERTIES
      POSITION_INDEPENDENT_CODE ON)
    set_target_properties(${target_lower} PROPERTIES
      CXX_VISIBILITY_PRESET hidden)
    target_link_libraries(${target_lower} PUBLIC flutter)
    target_include_directories(${target_lower} PUBLIC
      "${EPHEMERAL_DIR}/cpp_client_wrapper/include"
    )
    add_dependencies(${target_lower} flutter_assemble)
  endif()
endforeach()

# === Flutter tool backend ===
# _phony_ target that is always built and runs the Flutter tool's
# build script, to keep the bundle, ephemeral, and generated files up to
# date.
add_custom_target(flutter_assemble DEPENDS
  "${FLUTTER_LIBRARY}"
  ${FLUTTER_LIBRARY_HEADERS}
  ${CPP_WRAPPER_SOURCES_APP}
  ${CPP_WRAPPER_SOURCES_PLUGIN}
  ${CPP_WRAPPER_SOURCES_CORE}
)
add_custom_command(
  TARGET flutter_assemble
  PRE_BUILD
  COMMAND ${CMAKE_COMMAND} -E env
    ${FLUTTER_TOOL_ENVIRONMENT}
    "${FLUTTER_ROOT}/packages/flutter_tools/bin/tool_backend.bat"
      ${FLUTTER_TARGET_PLATFORM} $<CONFIG>
  VERBATIM
)
