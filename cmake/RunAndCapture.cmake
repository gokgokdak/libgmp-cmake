if(NOT DEFINED OUTPUT_FILE)
  message(FATAL_ERROR "OUTPUT_FILE is required.")
endif()

if(NOT DEFINED PROGRAM)
  message(FATAL_ERROR "PROGRAM is required.")
endif()

string(REGEX REPLACE "^\"(.*)\"$" "\\1" OUTPUT_FILE "${OUTPUT_FILE}")
string(REGEX REPLACE "^\"(.*)\"$" "\\1" PROGRAM "${PROGRAM}")

set(_args)
if(DEFINED ARGC AND NOT ARGC STREQUAL "")
  math(EXPR _last_index "${ARGC} - 1")
  if(_last_index GREATER_EQUAL 0)
    foreach(_index RANGE 0 ${_last_index})
      set(_name "ARG_${_index}")
      set(_value "${${_name}}")
      string(REGEX REPLACE "^\"(.*)\"$" "\\1" _value "${_value}")
      list(APPEND _args "${_value}")
    endforeach()
  endif()
elseif(DEFINED ARGS AND NOT ARGS STREQUAL "")
  string(REPLACE "|" ";" _decoded_args "${ARGS}")
  set(_args ${_decoded_args})
endif()

get_filename_component(_output_dir "${OUTPUT_FILE}" DIRECTORY)
file(MAKE_DIRECTORY "${_output_dir}")

execute_process(
  COMMAND "${PROGRAM}" ${_args}
  RESULT_VARIABLE _result
  OUTPUT_VARIABLE _stdout
  ERROR_VARIABLE _stderr
)

if(NOT _result EQUAL 0)
  file(REMOVE "${OUTPUT_FILE}")
  message(FATAL_ERROR "Command failed: ${PROGRAM} ${_args}\n${_stderr}")
endif()

file(WRITE "${OUTPUT_FILE}" "${_stdout}")
