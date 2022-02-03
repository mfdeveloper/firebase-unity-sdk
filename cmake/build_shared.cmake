# Copyright 2019 Google
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Logic for building the shared library version of Firebase libraries.

include(build_firebase_aar)

# Build the shared library that contains the swig library. If building for
# Android, builds the srcaar file as well.
#
# Args:
#  LIBRARY_NAME: The name of the library, used to determine the targets.
#  ARTIFACT_NAME: The name used to generate the artifact id used by the srcaar.
#  OUTPUT_NAME: The output name to use for the shared library
function(build_firebase_shared LIBRARY_NAME ARTIFACT_NAME OUTPUT_NAME)

  set(shared_target "firebase_${LIBRARY_NAME}_shared")
  
  add_library(${shared_target} SHARED
    ${FIREBASE_SOURCE_DIR}/empty.cc
    $<TARGET_OBJECTS:firebase_${LIBRARY_NAME}>
    $<TARGET_OBJECTS:firebase_${LIBRARY_NAME}_swig>
  )
  
  set(SHARED_TARGET_LINK_LIB_NAMES "firebase_${LIBRARY_NAME}" "firebase_${LIBRARY_NAME}_swig")

  target_link_libraries(${shared_target}
    ${SHARED_TARGET_LINK_LIB_NAMES}
  )

  # target_include_directories(${shared_target}
  #   PUBLIC
  #     ${CMAKE_CURRENT_LIST_DIR}
  #   PRIVATE
  #     ${FIREBASE_CPP_SDK_DIR}
  #     ${FIREBASE_UNITY_DIR}
  # )

  # Update output name
  set_target_properties(${shared_target} 
    PROPERTIES
      OUTPUT_NAME "${OUTPUT_NAME}"
  )
  if(APPLE AND NOT FIREBASE_IOS_BUILD)
    # Other approach like set target link or set BUNDLE property fail due to
    # trying to treat the bundle as a directory instead of a file.
    # Only override suffix produces a single file bundle.
    set_target_properties(${shared_target} 
      PROPERTIES
        PREFIX ""
        SUFFIX ".bundle"
    )
  elseif(FIREBASE_IOS_BUILD)
    set_target_properties(${shared_target}
      PROPERTIES
        PREFIX "lib"
        SUFFIX ".a"
    )
  elseif(ANDROID)
    set_target_properties(${shared_target}
      PROPERTIES
        PREFIX "lib"
    )
  else()
    set_target_properties(${shared_target}
      PROPERTIES
        PREFIX ""
    )
  endif()

  if(ANDROID)
    target_link_options(${shared_target}
      PRIVATE
        "-llog"
        "-Wl,-z,defs"
        "-Wl,--no-undefined"
        # Link against the static libc++, which is the default done by Gradle.
        "-static-libstdc++"
    )
  endif()
  
  unity_pack_native(${shared_target})

  if(ANDROID)
    # Build the srcaar, and package it with CPack.
    string(TOUPPER ${LIBRARY_NAME} UPPER_BASENAME)

    build_firebase_aar(
      ${LIBRARY_NAME}
      ${ARTIFACT_NAME}
      ${shared_target}
      "FIREBASE_CPP_${UPPER_BASENAME}_PROGUARD"
    )
  endif()

endfunction()