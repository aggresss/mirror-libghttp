# File containing various utilities

# Returns a list of arguments that evaluate to true
function(count_true output_count_var)
    set(lst)
    foreach(option_var IN LISTS ARGN)
        if(${option_var})
        list(APPEND lst ${option_var})
        endif()
    endforeach()
    list(LENGTH lst lst_len)
    set(${output_count_var} ${lst_len} PARENT_SCOPE)
endfunction()

# Returns the ${CMAKE_C_COMPILER} prefix
function(c_compiler_prefix output_prefix)
    string(REGEX MATCH "[^/]+$" compiler_basename ${CMAKE_C_COMPILER})
    string(REGEX MATCH "[^-]+$" compiler_id ${compiler_basename})
    if(NOT ${compiler_basename} STREQUAL ${compiler_id})
        string(REPLACE "-${compiler_id}" "" compiler_prefix ${compiler_basename})
    endif()
    set(${output_prefix} ${compiler_prefix} PARENT_SCOPE)
endfunction()

# Returns the ${CMAKE_C_COMPILER} triplet
function(c_compiler_triplet output_triplet)
    execute_process(COMMAND ${CMAKE_C_COMPILER} -dumpmachine
        OUTPUT_VARIABLE compiler_triplet
        OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    set(${output_triplet} ${compiler_triplet} PARENT_SCOPE)
endfunction()