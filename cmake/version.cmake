
function(to_hex_ncs DEC HEX)
  if(DEC EQUAL 0)
    set(${HEX} "0x0" PARENT_SCOPE)
    return()
  endif()
  while(DEC GREATER 0)
    math(EXPR _val "${DEC} % 16")
    math(EXPR DEC "${DEC} / 16")
    if(_val EQUAL 10)
      set(_val "A")
    elseif(_val EQUAL 11)
      set(_val "B")
    elseif(_val EQUAL 12)
      set(_val "C")
    elseif(_val EQUAL 13)
      set(_val "D")
    elseif(_val EQUAL 14)
      set(_val "E")
    elseif(_val EQUAL 15)
      set(_val "F")
    endif()
    set(_res "${_val}${_res}")
  endwhile()
  set(${HEX} "0x${_res}" PARENT_SCOPE)
endfunction()

math(EXPR NCS_VERSION_CODE "(${NCS_VERSION_MAJOR} << 16) + (${NCS_VERSION_MINOR} << 8)  + (${NCS_VERSION_PATCH})")

# to_hex is made available by ${ZEPHYR_BASE}/cmake/hex.cmake
to_hex_ncs(${NCS_VERSION_CODE} NCS_VERSION_NUMBER)

if(DEFINED BUILD_VERSION)
  set(ncs_banner_version BUILD_VERSION)
else()
  set(ncs_banner_version NCS_BUILD_VERSION)
endif()

add_custom_command(
  OUTPUT ${PROJECT_BINARY_DIR}/include/generated/ncs_version.h
  COMMAND ${CMAKE_COMMAND} -DZEPHYR_BASE=${ZEPHYR_BASE}
    -DOUT_FILE=${PROJECT_BINARY_DIR}/include/generated/ncs_version.h
    -DVERSION_TYPE=NCS
    # We don't want Zephyr to parse the NCS VERSION file as it is not conforming to Zephyr VERSION
    # format. Pointing to a non-existing file allows us full control from CMake instead.
    -DVERSION_FILE=${NRF_DIR}/VERSIONFILEDUMMY
    -DNCS_VERSION_CODE=${NCS_VERSION_CODE}
    -DNCS_VERSION_NUMBER=${NCS_VERSION_NUMBER}
    -DNCS_VERSION_MAJOR=${NCS_VERSION_MAJOR}
    -DNCS_VERSION_MINOR=${NCS_VERSION_MINOR}
    -DNCS_PATCHLEVEL=${NCS_VERSION_PATCH}
    -DNCS_VERSION_STRING=${NCS_VERSION}
    -DNCS_VERSION_CUSTOMIZATION="\#define;BANNER_VERSION;STRINGIFY\(${ncs_banner_version}\)"
    -P ${ZEPHYR_BASE}/cmake/gen_version_h.cmake
    DEPENDS ${NRF_DIR}/VERSION ${git_dependency}
)
add_custom_target(ncs_version_h DEPENDS ${PROJECT_BINARY_DIR}/include/generated/ncs_version.h)

add_dependencies(version_h ncs_version_h)

