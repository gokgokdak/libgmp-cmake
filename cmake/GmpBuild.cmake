include_guard(GLOBAL)

include(CheckCSourceCompiles)
include(CheckSymbolExists)
include(CheckIncludeFile)
include(CheckTypeSize)
include(TestBigEndian)

set(GMP_LIB_VERSION "15.0.5")
set(GMP_LIB_SOVERSION "10")
set(GMPXX_LIB_VERSION "11.0.7")
set(GMPXX_LIB_SOVERSION "4")

set(GMP_ROOT_SOURCES
  assert.c
  compat.c
  errno.c
  extract-dbl.c
  invalid.c
  memory.c
  mp_bpl.c
  mp_clz_tab.c
  mp_dv_tab.c
  mp_get_fns.c
  mp_minv_tab.c
  mp_set_fns.c
  nextprime.c
  primesieve.c
  tal-reent.c
  version.c
)

set(GMP_MPN_FUNCTIONS
  add add_1 add_n sub sub_1 sub_n cnd_add_n cnd_sub_n cnd_swap neg com
  mul_1 addmul_1 submul_1
  add_err1_n add_err2_n add_err3_n sub_err1_n sub_err2_n sub_err3_n
  lshift rshift dive_1 diveby3 divis divrem divrem_1 divrem_2
  fib2_ui fib2m mod_1 mod_34lsub1 mode1o pre_divrem_1 pre_mod_1 dump
  mod_1_1 mod_1_2 mod_1_3 mod_1_4 lshiftc
  mul mul_fft mul_n sqr mul_basecase sqr_basecase nussbaumer_mul
  mulmid_basecase toom42_mulmid mulmid_n mulmid
  random random2 pow_1
  rootrem sqrtrem sizeinbase get_str set_str compute_powtab
  scan0 scan1 popcount hamdist cmp zero_p
  perfsqr perfpow strongfibo
  gcd_11 gcd_22 gcd_1 gcd gcdext_1 gcdext gcd_subdiv_step
  gcdext_lehmer
  div_q tdiv_qr jacbase jacobi_2 jacobi get_d
  matrix22_mul matrix22_mul1_inverse_vector
  hgcd_matrix hgcd2 hgcd_step hgcd_reduce hgcd hgcd_appr
  hgcd2_jacobi hgcd_jacobi
  mullo_n mullo_basecase sqrlo sqrlo_basecase
  toom22_mul toom32_mul toom42_mul toom52_mul toom62_mul
  toom33_mul toom43_mul toom53_mul toom54_mul toom63_mul
  toom44_mul
  toom6h_mul toom6_sqr toom8h_mul toom8_sqr
  toom_couple_handling
  toom2_sqr toom3_sqr toom4_sqr
  toom_eval_dgr3_pm1 toom_eval_dgr3_pm2
  toom_eval_pm1 toom_eval_pm2 toom_eval_pm2exp toom_eval_pm2rexp
  toom_interpolate_5pts toom_interpolate_6pts toom_interpolate_7pts
  toom_interpolate_8pts toom_interpolate_12pts toom_interpolate_16pts
  invertappr invert binvert mulmod_bnm1 sqrmod_bnm1 mulmod_bknp1
  div_qr_1 div_qr_1n_pi1
  div_qr_2 div_qr_2n_pi1 div_qr_2u_pi1
  sbpi1_div_q sbpi1_div_qr sbpi1_divappr_q
  dcpi1_div_q dcpi1_div_qr dcpi1_divappr_q
  mu_div_qr mu_divappr_q mu_div_q
  bdiv_q_1
  sbpi1_bdiv_q sbpi1_bdiv_qr sbpi1_bdiv_r
  dcpi1_bdiv_q dcpi1_bdiv_qr
  mu_bdiv_q mu_bdiv_qr
  bdiv_q bdiv_qr broot brootinv bsqrt bsqrtinv
  divexact bdiv_dbm1c redc_1 redc_2 redc_n powm powlo sec_powm
  sec_mul sec_sqr sec_div_qr sec_div_r sec_pi1_div_qr sec_pi1_div_r
  sec_add_1 sec_sub_1 sec_invert
  trialdiv remove
  and_n andn_n nand_n ior_n iorn_n nior_n xor_n xnor_n
  copyi copyd zero sec_tabselect
  comb_tables
  umul udiv
  invert_limb sqr_diagonal sqr_diag_addlsh1
  mul_2 mul_3 mul_4 mul_5 mul_6
  addmul_2 addmul_3 addmul_4 addmul_5 addmul_6 addmul_7 addmul_8
  addlsh1_n sublsh1_n rsblsh1_n rsh1add_n rsh1sub_n
  addlsh2_n sublsh2_n rsblsh2_n
  addlsh_n sublsh_n rsblsh_n
  add_n_sub_n addaddmul_1msb0
)

set(GMP_MPN_OPTIONAL_FUNCTIONS
  umul udiv
  invert_limb sqr_diagonal sqr_diag_addlsh1
  mul_2 mul_3 mul_4 mul_5 mul_6
  addmul_2 addmul_3 addmul_4 addmul_5 addmul_6 addmul_7 addmul_8
  addlsh1_n sublsh1_n rsblsh1_n rsh1add_n rsh1sub_n
  addlsh2_n sublsh2_n rsblsh2_n
  addlsh_n sublsh_n rsblsh_n
  add_n_sub_n addaddmul_1msb0
)

function(_gmp_replace_undef content_var macro value)
  string(REPLACE "#undef ${macro}\r\n" "#define ${macro} ${value}\r\n" _tmp "${${content_var}}")
  string(REPLACE "#undef ${macro}\n" "#define ${macro} ${value}\n" _tmp "${_tmp}")
  set(${content_var} "${_tmp}" PARENT_SCOPE)
endfunction()

function(_gmp_escape_c_string out_var value)
  set(_escaped "${value}")
  string(REPLACE "\\" "\\\\" _escaped "${_escaped}")
  string(REPLACE "\"" "\\\"" _escaped "${_escaped}")
  set(${out_var} "${_escaped}" PARENT_SCOPE)
endfunction()

function(_gmp_extract_mparam_value file macro out_var)
  file(STRINGS "${file}" _line REGEX "^#define[ \t]+${macro}[ \t]+")
  if(_line)
    string(REGEX REPLACE "^#define[ \t]+${macro}[ \t]+([^ \t/]+).*$" "\\1" _value "${_line}")
    set(${out_var} "${_value}" PARENT_SCOPE)
  else()
    set(${out_var} "" PARENT_SCOPE)
  endif()
endfunction()

function(_gmp_write_c_wrapper output source operation)
  file(TO_CMAKE_PATH "${source}" _source_path)
  file(WRITE "${output}" "#define OPERATION_${operation} 1\n#include \"${_source_path}\"\n")
endfunction()

function(_gmp_write_asm_wrapper output source)
  file(TO_CMAKE_PATH "${source}" _source_path)
  file(WRITE "${output}" "include(`${_source_path}')\n")
endfunction()

function(_gmp_add_test_asm_source out_var generated_root output_stem source_file m4_executable)
  set(_generated_tests_dir "${generated_root}/tests")
  file(MAKE_DIRECTORY "${_generated_tests_dir}")

  get_filename_component(_source_name "${source_file}" NAME)
  set(_wrapper "${_generated_tests_dir}/${_source_name}")
  _gmp_write_asm_wrapper("${_wrapper}" "${source_file}")

  set(_generated_s "${_generated_tests_dir}/${output_stem}.s")
  set(_m4_command
    "${CMAKE_COMMAND}"
    -DOUTPUT_FILE="${_generated_s}"
    -DPROGRAM="${m4_executable}"
    -DARGC=2
    -DARG_0=-DPIC
    -DARG_1="${_wrapper}"
    -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/RunAndCapture.cmake")
  add_custom_command(
    OUTPUT "${_generated_s}"
    COMMAND ${_m4_command}
    DEPENDS "${_wrapper}" "${source_file}" "${generated_root}/config.m4"
    WORKING_DIRECTORY "${_generated_tests_dir}"
    VERBATIM
  )
  set_source_files_properties("${_generated_s}" PROPERTIES GENERATED TRUE)
  set(${out_var} "${_generated_s}" PARENT_SCOPE)
endfunction()

function(_gmp_get_mulfunc_choices function_name out_var)
  set(_choices "")
  if(function_name STREQUAL "add_n" OR function_name STREQUAL "sub_n")
    list(APPEND _choices "aors_n")
  elseif(function_name STREQUAL "add_err1_n" OR function_name STREQUAL "sub_err1_n")
    list(APPEND _choices "aors_err1_n")
  elseif(function_name STREQUAL "add_err2_n" OR function_name STREQUAL "sub_err2_n")
    list(APPEND _choices "aors_err2_n")
  elseif(function_name STREQUAL "add_err3_n" OR function_name STREQUAL "sub_err3_n")
    list(APPEND _choices "aors_err3_n")
  elseif(function_name STREQUAL "cnd_add_n" OR function_name STREQUAL "cnd_sub_n")
    list(APPEND _choices "cnd_aors_n")
  elseif(function_name STREQUAL "sec_add_1" OR function_name STREQUAL "sec_sub_1")
    list(APPEND _choices "sec_aors_1")
  elseif(function_name STREQUAL "addmul_1" OR function_name STREQUAL "submul_1")
    list(APPEND _choices "aorsmul_1")
  elseif(function_name STREQUAL "mul_2" OR function_name STREQUAL "addmul_2")
    list(APPEND _choices "aormul_2")
  elseif(function_name STREQUAL "mul_3" OR function_name STREQUAL "addmul_3")
    list(APPEND _choices "aormul_3")
  elseif(function_name STREQUAL "mul_4" OR function_name STREQUAL "addmul_4")
    list(APPEND _choices "aormul_4")
  elseif(function_name STREQUAL "popcount" OR function_name STREQUAL "hamdist")
    list(APPEND _choices "popham")
  elseif(function_name MATCHES "^(and_n|andn_n|nand_n|ior_n|iorn_n|nior_n|xor_n|xnor_n)$")
    list(APPEND _choices "logops_n")
  elseif(function_name STREQUAL "lshift" OR function_name STREQUAL "rshift")
    list(APPEND _choices "lorrshift")
  elseif(function_name STREQUAL "addlsh1_n")
    list(APPEND _choices "aorslsh1_n" "aorrlsh1_n" "aorsorrlsh1_n")
  elseif(function_name STREQUAL "sublsh1_n")
    list(APPEND _choices "aorslsh1_n" "sorrlsh1_n" "aorsorrlsh1_n")
  elseif(function_name STREQUAL "rsblsh1_n")
    list(APPEND _choices "aorrlsh1_n" "sorrlsh1_n" "aorsorrlsh1_n")
  elseif(function_name STREQUAL "addlsh2_n")
    list(APPEND _choices "aorslsh2_n" "aorrlsh2_n" "aorsorrlsh2_n")
  elseif(function_name STREQUAL "sublsh2_n")
    list(APPEND _choices "aorslsh2_n" "sorrlsh2_n" "aorsorrlsh2_n")
  elseif(function_name STREQUAL "rsblsh2_n")
    list(APPEND _choices "aorrlsh2_n" "sorrlsh2_n" "aorsorrlsh2_n")
  elseif(function_name STREQUAL "addlsh_n")
    list(APPEND _choices "aorslsh_n" "aorrlsh_n" "aorsorrlsh_n")
  elseif(function_name STREQUAL "sublsh_n")
    list(APPEND _choices "aorslsh_n" "sorrlsh_n" "aorsorrlsh_n")
  elseif(function_name STREQUAL "rsblsh_n")
    list(APPEND _choices "aorrlsh_n" "sorrlsh_n" "aorsorrlsh_n")
  elseif(function_name STREQUAL "rsh1add_n" OR function_name STREQUAL "rsh1sub_n")
    list(APPEND _choices "rsh1aors_n")
  elseif(function_name STREQUAL "sec_div_qr" OR function_name STREQUAL "sec_div_r")
    list(APPEND _choices "sec_div")
  elseif(function_name STREQUAL "sec_pi1_div_qr" OR function_name STREQUAL "sec_pi1_div_r")
    list(APPEND _choices "sec_pi1_div")
  endif()
  set(${out_var} "${_choices}" PARENT_SCOPE)
endfunction()

function(_gmp_extract_native_macros source_file out_var)
  set(_defs "")
  file(READ "${source_file}" _content)

  string(REGEX MATCHALL "MULFUNC_PROLOGUE\\([^\\)]*\\)" _mulfunc_matches "${_content}")
  foreach(_match IN LISTS _mulfunc_matches)
    string(REGEX REPLACE "^MULFUNC_PROLOGUE\\(([^\\)]*)\\)$" "\\1" _body "${_match}")
    string(REGEX REPLACE "[ \t\r\n]+" ";" _tokens "${_body}")
    foreach(_token IN LISTS _tokens)
      if(_token)
        list(APPEND _defs "HAVE_NATIVE_mpn_${_token}")
      endif()
    endforeach()
  endforeach()

  string(REGEX MATCHALL "PROLOGUE\\(mpn_[^,\r\n\\)]+" _prologue_matches "${_content}")
  foreach(_match IN LISTS _prologue_matches)
    string(REGEX REPLACE "^PROLOGUE\\(mpn_" "" _name "${_match}")
    if(_name)
      list(APPEND _defs "HAVE_NATIVE_mpn_${_name}")
    endif()
  endforeach()

  list(REMOVE_DUPLICATES _defs)
  set(${out_var} "${_defs}" PARENT_SCOPE)
endfunction()

function(_gmp_collect_directory_sources out_var directory pattern)
  file(GLOB _sources CONFIGURE_DEPENDS "${directory}/${pattern}")
  list(SORT _sources)
  set(${out_var} "${_sources}" PARENT_SCOPE)
endfunction()

function(_gmp_get_native_function_name function_name out_var)
  if(function_name STREQUAL "pre_divrem_1")
    set(_native_name "preinv_divrem_1")
  elseif(function_name STREQUAL "pre_mod_1")
    set(_native_name "preinv_mod_1")
  elseif(function_name STREQUAL "dive_1")
    set(_native_name "divexact_1")
  else()
    set(_native_name "${function_name}")
  endif()
  set(${out_var} "${_native_name}" PARENT_SCOPE)
endfunction()

function(_gmp_collect_mpn_sources out_var native_defs_var generated_root mparam_file asm_enabled mpn_dirs asm_dependency_dirs m4_executable)
  set(_sources "")
  set(_native_defs "")

  file(MAKE_DIRECTORY "${generated_root}/mpn")

  if(asm_enabled)
    set(_asm_dep_files "")
    foreach(_dir IN LISTS asm_dependency_dirs)
      file(GLOB_RECURSE _dir_files CONFIGURE_DEPENDS
        "${CMAKE_CURRENT_SOURCE_DIR}/${_dir}/*.asm"
        "${CMAKE_CURRENT_SOURCE_DIR}/${_dir}/*.m4")
      list(APPEND _asm_dep_files ${_dir_files})
    endforeach()
    list(APPEND _asm_dep_files "${generated_root}/config.m4")
  endif()

  foreach(_fn IN LISTS GMP_MPN_FUNCTIONS)
    set(_found FALSE)
    set(_is_optional FALSE)
    if(_fn IN_LIST GMP_MPN_OPTIONAL_FUNCTIONS)
      set(_is_optional TRUE)
    endif()

    _gmp_get_native_function_name("${_fn}" _native_name)
    if(asm_enabled AND "HAVE_NATIVE_mpn_${_native_name}" IN_LIST _native_defs)
      continue()
    endif()

    _gmp_get_mulfunc_choices("${_fn}" _choices)
    set(_bases "${_fn}")
    list(APPEND _bases ${_choices})

    foreach(_dir IN LISTS mpn_dirs)
      if(_found)
        break()
      endif()
      foreach(_base IN LISTS _bases)
        if(_found)
          break()
        endif()
        foreach(_ext IN ITEMS asm c)
          set(_candidate "${CMAKE_CURRENT_SOURCE_DIR}/mpn/${_dir}/${_base}.${_ext}")
          if(EXISTS "${_candidate}")
            if(_ext STREQUAL "c")
              set(_wrapper "${generated_root}/mpn/${_fn}.c")
              _gmp_write_c_wrapper("${_wrapper}" "${_candidate}" "${_fn}")
              list(APPEND _sources "${_wrapper}")
            elseif(_ext STREQUAL "asm")
              set(_wrapper "${generated_root}/mpn/${_fn}.asm")
              _gmp_write_asm_wrapper("${_wrapper}" "${_candidate}")
              set(_generated_s "${generated_root}/mpn/${_fn}.s")
              set(_m4_command
                "${CMAKE_COMMAND}"
                -DOUTPUT_FILE="${_generated_s}"
                -DPROGRAM="${m4_executable}"
                -DARGC=3
                -DARG_0=-DPIC
                -DARG_1=-DOPERATION_${_fn}
                -DARG_2="${_wrapper}"
                -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/RunAndCapture.cmake")
              add_custom_command(
                OUTPUT "${_generated_s}"
                COMMAND ${_m4_command}
                DEPENDS "${_wrapper}" "${_candidate}" ${_asm_dep_files}
                WORKING_DIRECTORY "${generated_root}/mpn"
                VERBATIM
              )
              set_source_files_properties("${_generated_s}" PROPERTIES GENERATED TRUE)
              list(APPEND _sources "${_generated_s}")

              if(_fn STREQUAL "invert_limb")
                set(_table_candidate "${CMAKE_CURRENT_SOURCE_DIR}/mpn/${_dir}/invert_limb_table.asm")
                if(EXISTS "${_table_candidate}")
                  set(_table_wrapper "${generated_root}/mpn/invert_limb_table.asm")
                  _gmp_write_asm_wrapper("${_table_wrapper}" "${_table_candidate}")
                  set(_table_generated_s "${generated_root}/mpn/invert_limb_table.s")
                  set(_table_m4_command
                    "${CMAKE_COMMAND}"
                    -DOUTPUT_FILE="${_table_generated_s}"
                    -DPROGRAM="${m4_executable}"
                    -DARGC=2
                    -DARG_0=-DPIC
                    -DARG_1="${_table_wrapper}"
                    -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/RunAndCapture.cmake")
                  add_custom_command(
                    OUTPUT "${_table_generated_s}"
                    COMMAND ${_table_m4_command}
                    DEPENDS "${_table_wrapper}" "${_table_candidate}" ${_asm_dep_files}
                    WORKING_DIRECTORY "${generated_root}/mpn"
                    VERBATIM
                  )
                  set_source_files_properties("${_table_generated_s}" PROPERTIES GENERATED TRUE)
                  list(APPEND _sources "${_table_generated_s}")
                endif()
              endif()
            endif()

            _gmp_extract_native_macros("${_candidate}" _defs)
            list(APPEND _native_defs ${_defs})
            set(_found TRUE)
            break()
          endif()
        endforeach()
      endforeach()
    endforeach()

    if(NOT _found AND NOT _is_optional)
      string(JOIN " " _dirs_display ${mpn_dirs})
      message(FATAL_ERROR "No implementation for mpn/${_fn} was found in path: ${_dirs_display}")
    endif()
  endforeach()

  list(REMOVE_DUPLICATES _sources)
  list(REMOVE_DUPLICATES _native_defs)
  set(${out_var} "${_sources}" PARENT_SCOPE)
  set(${native_defs_var} "${_native_defs}" PARENT_SCOPE)
endfunction()

function(_gmp_generate_config_m4 output_file source_root limb_bits limb_bytes num_bits mparam_file m4_includes gsym_prefix lsym_prefix align_logarithmic host_dos64)
  _gmp_extract_mparam_value("${mparam_file}" "SQR_TOOM2_THRESHOLD" _sqr_toom2)
  _gmp_extract_mparam_value("${mparam_file}" "BMOD_1_TO_MOD_1_THRESHOLD" _bmod_threshold)

  file(TO_CMAKE_PATH "${source_root}" _src_root)
  string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" _config_m4_processor)

  set(_text ".text")
  set(_data ".data")
  set(_globl ".globl")
  set(_globl_attr "")
  set(_align_fill_0x90 "no")
  set(_type_directive "")
  set(_size_directive "")
  set(_rodata_directive ".section .rodata")
  set(_have_coff_type "no")

  if(_config_m4_processor MATCHES "^(x86_64|amd64|x86|i[3-6]86)$")
    set(_align_fill_0x90 "yes")
  endif()

  if(host_dos64)
    set(_rodata_directive ".section .rdata,\"dr\"")
    set(_have_coff_type "yes")
  elseif(APPLE)
    set(_rodata_directive ".section __TEXT,__const")
  elseif(_config_m4_processor MATCHES "^(aarch64|arm64)$")
    set(_type_directive ".type\t$1,%$2")
    set(_size_directive ".size\t$1,$2")
  else()
    set(_type_directive ".type\t$1,@$2")
    set(_size_directive ".size\t$1,$2")
  endif()

  set(_content "dnl config.m4. Generated by CMake.\n")
  string(APPEND _content "changequote(<,>)\n")
  string(APPEND _content "ifdef(<__CONFIG_M4_INCLUDED__>,,<\n")
  string(APPEND _content "define(<CONFIG_TOP_SRCDIR>,<`${_src_root}'>)\n")
  string(APPEND _content "define(<WANT_ASSERT>, <0>)\n")
  string(APPEND _content "define(<WANT_PROFILING>, <no>)\n")
  string(APPEND _content "define(<M4WRAP_SPURIOUS>, <no>)\n")
  string(APPEND _content "define(<TEXT>, <${_text}>)\n")
  string(APPEND _content "define(<DATA>, <${_data}>)\n")
  string(APPEND _content "define(<LABEL_SUFFIX>, <:>)\n")
  string(APPEND _content "define(<GLOBL>, <${_globl}>)\n")
  string(APPEND _content "define(<GLOBL_ATTR>, <${_globl_attr}>)\n")
  string(APPEND _content "define(<GSYM_PREFIX>, <${gsym_prefix}>)\n")
  string(APPEND _content "define(<RODATA>, <${_rodata_directive}>)\n")
  string(APPEND _content "define(<TYPE>, <${_type_directive}>)\n")
  string(APPEND _content "define(<SIZE>, <${_size_directive}>)\n")
  string(APPEND _content "define(<LSYM_PREFIX>, <${lsym_prefix}>)\n")
  string(APPEND _content "define(<W32>, <.long>)\n")
  string(APPEND _content "define(<ALIGN_LOGARITHMIC>, <${align_logarithmic}>)\n")
  string(APPEND _content "define(<ALIGN_FILL_0x90>, <${_align_fill_0x90}>)\n")
  string(APPEND _content "define(<HAVE_COFF_TYPE>, <${_have_coff_type}>)\n")
  string(APPEND _content "define(<SIZEOF_UNSIGNED>, <4>)\n")
  string(APPEND _content "define(<GMP_LIMB_BITS>, <${limb_bits}>)\n")
  string(APPEND _content "define(<GMP_LIMB_BYTES>, <${limb_bytes}>)\n")
  string(APPEND _content "define(<GMP_NAIL_BITS>, <0>)\n")
  string(APPEND _content "define(<GMP_NUMB_BITS>, <${num_bits}>)\n")
  if(_sqr_toom2)
    string(APPEND _content "define(<SQR_TOOM2_THRESHOLD>, <${_sqr_toom2}>)\n")
  endif()
  if(_bmod_threshold)
    string(APPEND _content "define(<BMOD_1_TO_MOD_1_THRESHOLD>, <${_bmod_threshold}>)\n")
  endif()
  string(APPEND _content ">)\n")
  string(APPEND _content "changequote(`,')\n")
  string(APPEND _content "ifdef(`__CONFIG_M4_INCLUDED__',,`\n")
  string(APPEND _content "include(CONFIG_TOP_SRCDIR`/mpn/asm-defs.m4')\n")
  foreach(_include_file IN LISTS m4_includes)
    string(APPEND _content "include_mpn(`${_include_file}')\n")
  endforeach()
  string(APPEND _content "')\n")
  string(APPEND _content "define(`__CONFIG_M4_INCLUDED__')\n")

  file(WRITE "${output_file}" "${_content}")
endfunction()

function(_gmp_generate_config_header output_file limb_bits use_long_long_limb native_macros asm_enabled family_macro lsym_prefix host_dos64 have_calling_conventions)
  set(_package_name "GNU MP")
  set(_package_tarname "gmp")
  set(_package_version "${PROJECT_VERSION}")
  set(_package_string "${_package_name} ${_package_version}")
  set(_package_bugreport "gmp-bugs@gmplib.org (see https://gmplib.org/manual/Reporting-Bugs.html)")
  set(_package_url "https://gmplib.org/")

  check_include_file("inttypes.h" HAVE_INTTYPES_H)
  check_include_file("memory.h" HAVE_MEMORY_H)
  check_include_file("strings.h" HAVE_STRINGS_H)
  check_include_file("string.h" HAVE_STRING_H)
  check_include_file("stdint.h" HAVE_STDINT_H)
  check_include_file("stdlib.h" HAVE_STDLIB_H)
  check_include_file("sys/stat.h" HAVE_SYS_STAT_H)
  check_include_file("sys/time.h" HAVE_SYS_TIME_H)
  check_include_file("sys/types.h" HAVE_SYS_TYPES_H)
  check_include_file("unistd.h" HAVE_UNISTD_H)
  check_include_file("sys/mman.h" HAVE_SYS_MMAN_H)
  check_include_file("locale.h" HAVE_LOCALE_H)
  check_include_file("langinfo.h" HAVE_LANGINFO_H)
  check_include_file("nl_types.h" HAVE_NL_TYPES_H)
  check_include_file("float.h" HAVE_FLOAT_H)
  check_symbol_exists(alarm "unistd.h" HAVE_ALARM)
  check_symbol_exists(getpagesize "unistd.h" HAVE_GETPAGESIZE)
  check_symbol_exists(gettimeofday "sys/time.h" HAVE_GETTIMEOFDAY)
  check_symbol_exists(localeconv "locale.h" HAVE_LOCALECONV)
  check_symbol_exists(mmap "sys/mman.h" HAVE_MMAP)
  check_symbol_exists(mprotect "sys/mman.h" HAVE_MPROTECT)
  check_symbol_exists(nl_langinfo "langinfo.h" HAVE_NL_LANGINFO)
  check_symbol_exists(raise "signal.h" HAVE_RAISE)
  check_symbol_exists(sigaction "signal.h" HAVE_SIGACTION)
  check_symbol_exists(sysconf "unistd.h" HAVE_SYSCONF)

  check_c_source_compiles(
    "int main(void) { __attribute__ ((const)) int f(void); return 0; }"
    HAVE_ATTRIBUTE_CONST)
  check_c_source_compiles(
    "int main(void) { __attribute__ ((malloc)) void *f(void); return 0; }"
    HAVE_ATTRIBUTE_MALLOC)
  check_c_source_compiles(
    "typedef unsigned int __attribute__ ((mode (QI))) qi; int main(void) { qi x = 0; return (int)x; }"
    HAVE_ATTRIBUTE_MODE)
  check_c_source_compiles(
    "__attribute__ ((noreturn)) void f(void) { for (;;) {} } int main(void) { return 0; }"
    HAVE_ATTRIBUTE_NORETURN)
  check_c_source_compiles(
    "#include <stddef.h>\nint main(void) { ptrdiff_t x = 0; return (int) x; }"
    HAVE_PTRDIFF_T)

  test_big_endian(_gmp_words_big_endian)

  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/config.in" _config_content)

  _gmp_replace_undef(_config_content STDC_HEADERS 1)
  _gmp_replace_undef(_config_content HAVE_DECL_FGETC 1)
  _gmp_replace_undef(_config_content HAVE_DECL_FSCANF 1)
  _gmp_replace_undef(_config_content HAVE_DECL_UNGETC 1)
  _gmp_replace_undef(_config_content HAVE_DECL_VFPRINTF 1)
  _gmp_replace_undef(_config_content HAVE_INTMAX_T 1)
  _gmp_replace_undef(_config_content HAVE_INTPTR_T 1)
  _gmp_replace_undef(_config_content HAVE_LONG_DOUBLE 1)
  _gmp_replace_undef(_config_content HAVE_LONG_LONG 1)
  _gmp_replace_undef(_config_content HAVE_MEMSET 1)
  _gmp_replace_undef(_config_content HAVE_STRCHR 1)
  _gmp_replace_undef(_config_content HAVE_STRERROR 1)
  _gmp_replace_undef(_config_content HAVE_STRNLEN 1)
  _gmp_replace_undef(_config_content HAVE_STRTOL 1)
  _gmp_replace_undef(_config_content HAVE_STRTOUL 1)
  _gmp_replace_undef(_config_content HAVE_VSNPRINTF 1)
  _gmp_replace_undef(_config_content WANT_FFT 1)
  _gmp_replace_undef(_config_content WANT_TMP_REENTRANT 1)
  _gmp_replace_undef(_config_content PACKAGE "\"${_package_tarname}\"")
  _gmp_replace_undef(_config_content PACKAGE_BUGREPORT "\"${_package_bugreport}\"")
  _gmp_replace_undef(_config_content PACKAGE_NAME "\"${_package_name}\"")
  _gmp_replace_undef(_config_content PACKAGE_STRING "\"${_package_string}\"")
  _gmp_replace_undef(_config_content PACKAGE_TARNAME "\"${_package_tarname}\"")
  _gmp_replace_undef(_config_content PACKAGE_URL "\"${_package_url}\"")
  _gmp_replace_undef(_config_content PACKAGE_VERSION "\"${_package_version}\"")
  _gmp_replace_undef(_config_content SIZEOF_UNSIGNED 4)
  _gmp_replace_undef(_config_content SIZEOF_UNSIGNED_SHORT 2)
  _gmp_replace_undef(_config_content SIZEOF_UNSIGNED_LONG "${GMP_SIZEOF_UNSIGNED_LONG}")
  _gmp_replace_undef(_config_content SIZEOF_MP_LIMB_T "${GMP_LIMB_BYTES}")
  _gmp_replace_undef(_config_content SIZEOF_VOID_P "${CMAKE_SIZEOF_VOID_P}")
  _gmp_replace_undef(_config_content VERSION "\"${_package_version}\"")
  _gmp_replace_undef(_config_content RETSIGTYPE void)
  if(lsym_prefix)
    _gmp_replace_undef(_config_content LSYM_PREFIX "\"${lsym_prefix}\"")
  endif()
  if(host_dos64)
    _gmp_replace_undef(_config_content HOST_DOS64 1)
  endif()
  if(MSVC)
    _gmp_replace_undef(_config_content HAVE_UNISTD_H 1)
  endif()

  foreach(_macro IN ITEMS
      HAVE_ALARM HAVE_FLOAT_H HAVE_GETPAGESIZE HAVE_GETTIMEOFDAY
      HAVE_INTTYPES_H HAVE_LANGINFO_H HAVE_LOCALECONV HAVE_LOCALE_H
      HAVE_MEMORY_H HAVE_MMAP HAVE_MPROTECT HAVE_NL_LANGINFO
      HAVE_NL_TYPES_H HAVE_PTRDIFF_T HAVE_STDINT_H HAVE_STDLIB_H
      HAVE_STRING_H HAVE_STRINGS_H HAVE_SYSCONF HAVE_SYS_MMAN_H
      HAVE_SYS_STAT_H HAVE_SYS_TIME_H HAVE_SYS_TYPES_H HAVE_UNISTD_H
      HAVE_RAISE HAVE_SIGACTION HAVE_ATTRIBUTE_CONST HAVE_ATTRIBUTE_MALLOC
      HAVE_ATTRIBUTE_MODE HAVE_ATTRIBUTE_NORETURN)
    if(${_macro})
      _gmp_replace_undef(_config_content "${_macro}" 1)
    endif()
  endforeach()

  if(HAVE_SYS_TIME_H)
    _gmp_replace_undef(_config_content TIME_WITH_SYS_TIME 1)
  endif()

  if(_gmp_words_big_endian)
    _gmp_replace_undef(_config_content HAVE_LIMB_BIG_ENDIAN 1)
    _gmp_replace_undef(_config_content HAVE_DOUBLE_IEEE_BIG_ENDIAN 1)
  else()
    _gmp_replace_undef(_config_content HAVE_LIMB_LITTLE_ENDIAN 1)
    _gmp_replace_undef(_config_content HAVE_DOUBLE_IEEE_LITTLE_ENDIAN 1)
  endif()

  if(family_macro)
    _gmp_replace_undef(_config_content "${family_macro}" 1)
  endif()

  if(asm_enabled)
    foreach(_macro IN LISTS native_macros)
      _gmp_replace_undef(_config_content "${_macro}" 1)
    endforeach()
  else()
    _gmp_replace_undef(_config_content NO_ASM 1)
  endif()

  if(have_calling_conventions)
    _gmp_replace_undef(_config_content HAVE_CALLING_CONVENTIONS 1)
  endif()

  file(WRITE "${output_file}" "${_config_content}")
endfunction()

function(_gmp_generate_public_header output_file limb_bits use_long_long_limb)
  file(READ "${CMAKE_CURRENT_SOURCE_DIR}/gmp-h.in" _header_content)

  _gmp_escape_c_string(_compiler_path "${CMAKE_C_COMPILER}")
  _gmp_escape_c_string(_compiler_flags "${CMAKE_C_FLAGS}")

  string(REPLACE "@HAVE_HOST_CPU_FAMILY_power@" "0" _header_content "${_header_content}")
  string(REPLACE "@HAVE_HOST_CPU_FAMILY_powerpc@" "0" _header_content "${_header_content}")
  string(REPLACE "@GMP_LIMB_BITS@" "${limb_bits}" _header_content "${_header_content}")
  string(REPLACE "@GMP_NAIL_BITS@" "0" _header_content "${_header_content}")

  if(use_long_long_limb)
    set(_long_long_limb "#define _LONG_LONG_LIMB 1")
  else()
    set(_long_long_limb "/* #undef _LONG_LONG_LIMB */")
  endif()
  string(REPLACE "@DEFN_LONG_LONG_LIMB@" "${_long_long_limb}" _header_content "${_header_content}")

  string(REPLACE "#define __GMP_LIBGMP_DLL  @LIBGMP_DLL@"
    "#if defined(_WIN32) || defined(__CYGWIN__)\n#if defined(GMP_SHARED)\n#define __GMP_LIBGMP_DLL  1\n#else\n#define __GMP_LIBGMP_DLL  0\n#endif\n#else\n#define __GMP_LIBGMP_DLL  0\n#endif"
    _header_content "${_header_content}")
  string(REPLACE "#ifdef _MSC_VER\n#define __GMP_EXTERN_INLINE  __inline\n#endif"
    "#ifdef _MSC_VER\n#define __GMP_EXTERN_INLINE  static __inline\n#endif"
    _header_content "${_header_content}")

  string(REPLACE "@CC@" "${_compiler_path}" _header_content "${_header_content}")
  string(REPLACE "@CFLAGS@" "${_compiler_flags}" _header_content "${_header_content}")

  file(WRITE "${output_file}" "${_header_content}")
endfunction()

function(_gmp_generate_windows_unistd_header output_file)
  file(WRITE "${output_file}" "#pragma once\n#include <io.h>\n#include <process.h>\n#ifndef STDOUT_FILENO\n#define STDOUT_FILENO 1\n#endif\n#ifndef isatty\n#define isatty _isatty\n#endif\n#ifndef unlink\n#define unlink _unlink\n#endif\n#ifndef fileno\n#define fileno _fileno\n#endif\n#ifndef getpid\n#define getpid _getpid\n#endif\n")
endfunction()

function(_gmp_add_generator_executable target_name source_file)
  add_executable("${target_name}" EXCLUDE_FROM_ALL "${CMAKE_CURRENT_SOURCE_DIR}/${source_file}")
  target_include_directories("${target_name}" PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
  if(NOT WIN32)
    target_link_libraries("${target_name}" PRIVATE m)
  endif()
endfunction()

function(_gmp_add_generator_command output_file generator_target)
  set(_args ${ARGN})
  list(LENGTH _args _argc)
  if(CMAKE_CROSSCOMPILING AND CMAKE_CROSSCOMPILING_EMULATOR)
    set(_program "${CMAKE_CROSSCOMPILING_EMULATOR}")
    list(INSERT _args 0 "$<TARGET_FILE:${generator_target}>")
    list(LENGTH _args _argc)
  else()
    set(_program "$<TARGET_FILE:${generator_target}>")
  endif()
  set(_command
    "${CMAKE_COMMAND}"
    -DOUTPUT_FILE="${output_file}"
    -DPROGRAM=${_program}
    -DARGC=${_argc})
  math(EXPR _last_index "${_argc} - 1")
  if(_last_index GREATER_EQUAL 0)
    foreach(_index RANGE 0 ${_last_index})
      list(GET _args ${_index} _arg)
      list(APPEND _command "-DARG_${_index}=${_arg}")
    endforeach()
  endif()
  list(APPEND _command -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/RunAndCapture.cmake")
  add_custom_command(
    OUTPUT "${output_file}"
    COMMAND ${_command}
    DEPENDS "${generator_target}"
    VERBATIM
  )
endfunction()

function(_gmp_set_target_layout target_name target_kind)
  if(target_kind STREQUAL "SHARED")
    set_target_properties("${target_name}" PROPERTIES
      RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
      LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
      ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/import")
  else()
    set_target_properties("${target_name}" PROPERTIES
      ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/static")
  endif()
endfunction()

function(_gmp_configure_common_target target_name generated_include_dir generated_mpn_dir)
  target_include_directories("${target_name}"
    PUBLIC
      "$<BUILD_INTERFACE:${generated_include_dir}>"
      "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
    PRIVATE
      "${generated_include_dir}"
      "${generated_mpn_dir}"
      "${CMAKE_CURRENT_SOURCE_DIR}")

  target_compile_definitions("${target_name}" PRIVATE __GMP_WITHIN_GMP)
  set_target_properties("${target_name}" PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    OUTPUT_NAME gmp)

  if(NOT WIN32)
    target_link_libraries("${target_name}" PUBLIC m)
  endif()
endfunction()

function(_gmp_configure_common_cxx_target target_name generated_include_dir generated_mpn_dir)
  target_include_directories("${target_name}"
    PUBLIC
      "$<BUILD_INTERFACE:${generated_include_dir}>"
      "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
    PRIVATE
      "${generated_include_dir}"
      "${generated_mpn_dir}"
      "${CMAKE_CURRENT_SOURCE_DIR}")

  target_compile_definitions("${target_name}" PRIVATE __GMP_WITHIN_GMPXX)
  set_target_properties("${target_name}" PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    OUTPUT_NAME gmpxx)
endfunction()

function(_gmp_configure_test_target target_name generated_include_dir generated_mpn_dir)
  get_filename_component(_generated_root "${generated_mpn_dir}" DIRECTORY)
  target_include_directories("${target_name}"
    PRIVATE
      "${generated_include_dir}"
      "${_generated_root}"
      "${generated_mpn_dir}"
      "${CMAKE_CURRENT_SOURCE_DIR}"
      "${CMAKE_CURRENT_SOURCE_DIR}/tests")
endfunction()

function(_gmp_add_upstream_test_executable group_name test_name source_file support_target generated_include_dir generated_mpn_dir all_targets_var)
  string(REPLACE "-" "_" _safe_name "${test_name}")
  set(_target_name "gmp_test_${group_name}_${_safe_name}")
  set(_test_name "gmp.${group_name}.${test_name}")
  set(_test_working_dir "${CMAKE_CURRENT_BINARY_DIR}/test-work/${group_name}/${test_name}")

  add_executable("${_target_name}" "${source_file}")
  _gmp_configure_test_target("${_target_name}" "${generated_include_dir}" "${generated_mpn_dir}")
  target_link_libraries("${_target_name}" PRIVATE "${support_target}")
  file(MAKE_DIRECTORY "${_test_working_dir}")
  add_test(NAME "${_test_name}" COMMAND $<TARGET_FILE:${_target_name}>)
  set_tests_properties("${_test_name}" PROPERTIES
    WORKING_DIRECTORY "${_test_working_dir}"
    SKIP_RETURN_CODE 77)

  set(_all_targets "${${all_targets_var}}")
  list(APPEND _all_targets "${_target_name}")
  set(${all_targets_var} "${_all_targets}" PARENT_SCOPE)
endfunction()

function(_gmp_add_upstream_tests generated_include_dir generated_root generated_mpn_dir asm_enabled host_dos64 m4_executable)
  if(GMP_BUILD_STATIC)
    set(_test_link_target gmp_static)
  elseif(GMP_BUILD_SHARED)
    set(_test_link_target gmp_shared)
  else()
    message(FATAL_ERROR "GMP_BUILD_TESTS requires GMP_BUILD_SHARED or GMP_BUILD_STATIC.")
  endif()

  set(_support_sources
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/memory.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/misc.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/refmpf.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/refmpn.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/refmpq.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/refmpz.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/spinner.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/tests/trace.c")

  if(asm_enabled AND CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|AMD64|amd64)$" AND NOT host_dos64)
    _gmp_add_test_asm_source(
      _calling_conventions_asm
      "${generated_root}"
      "amd64call"
      "${CMAKE_CURRENT_SOURCE_DIR}/tests/amd64call.asm"
      "${m4_executable}")
    list(APPEND _support_sources
      "${_calling_conventions_asm}"
      "${CMAKE_CURRENT_SOURCE_DIR}/tests/amd64check.c")
  endif()

  add_library(gmp_tests_support STATIC ${_support_sources})
  _gmp_configure_test_target(gmp_tests_support "${generated_include_dir}" "${generated_mpn_dir}")
  target_link_libraries(gmp_tests_support PUBLIC "${_test_link_target}")
  add_dependencies(gmp_tests_support gmp_generated)

  set(_root_tests
    t-bswap
    t-constants
    t-count_zeros
    t-hightomask
    t-modlinv
    t-popc
    t-parity
    t-sub)
  set(_mpn_tests
    t-asmtype
    t-aors_1
    t-divrem_1
    t-mod_1
    t-fat
    t-get_d
    t-instrument
    t-iord_u
    t-mp_bases
    t-perfsqr
    t-scan
    logic
    t-toom22
    t-toom32
    t-toom33
    t-toom42
    t-toom43
    t-toom44
    t-toom52
    t-toom53
    t-toom54
    t-toom62
    t-toom63
    t-toom6h
    t-toom8h
    t-toom2-sqr
    t-toom3-sqr
    t-toom4-sqr
    t-toom6-sqr
    t-toom8-sqr
    t-div
    t-mul
    t-mullo
    t-sqrlo
    t-mulmod_bnm1
    t-sqrmod_bnm1
    t-mulmid
    t-mulmod_bknp1
    t-sqrmod_bknp1
    t-addaddmul
    t-hgcd
    t-hgcd_appr
    t-matrix22
    t-invert
    t-bdiv
    t-fib2m
    t-broot
    t-brootinv
    t-minvert
    t-sizeinbase
    t-gcd_11
    t-gcd_22
    t-gcdext_1)
  set(_mpz_tests
    reuse
    t-addsub
    t-cmp
    t-mul
    t-mul_i
    t-tdiv
    t-tdiv_ui
    t-fdiv
    t-fdiv_ui
    t-cdiv_ui
    t-gcd
    t-gcd_ui
    t-lcm
    t-invert
    dive
    dive_ui
    t-sqrtrem
    convert
    io
    t-inp_str
    logic
    t-bit
    t-powm
    t-powm_ui
    t-pow
    t-div_2exp
    t-root
    t-perfsqr
    t-perfpow
    t-jac
    t-bin
    t-get_d
    t-get_d_2exp
    t-get_si
    t-set_d
    t-set_si
    t-lucm
    t-fac_ui
    t-mfac_uiui
    t-primorial_ui
    t-fib_ui
    t-lucnum_ui
    t-scan
    t-fits
    t-divis
    t-divis_2exp
    t-cong
    t-cong_2exp
    t-sizeinbase
    t-set_str
    t-aorsmul
    t-cmp_d
    t-cmp_si
    t-hamdist
    t-oddeven
    t-popcount
    t-set_f
    t-io_raw
    t-import
    t-export
    t-pprime_p
    t-nextprime
    t-remove
    t-limbs)
  set(_mpq_tests
    t-aors
    t-cmp
    t-cmp_ui
    t-cmp_si
    t-equal
    t-get_d
    t-get_str
    t-inp_str
    t-inv
    t-md_2exp
    t-set_f
    t-set_str
    io
    reuse
    t-cmp_z)
  set(_mpf_tests
    t-dm2exp
    t-conv
    t-add
    t-sub
    t-sqrt
    t-sqrt_ui
    t-muldiv
    reuse
    t-cmp_d
    t-cmp_si
    t-div
    t-fits
    t-get_d
    t-get_d_2exp
    t-get_si
    t-get_ui
    t-gsprec
    t-inp_str
    t-int_p
    t-mul_ui
    t-set
    t-set_q
    t-set_si
    t-set_ui
    t-trunc
    t-ui_div
    t-eq
    t-pow_ui)
  set(_rand_tests
    t-iset
    t-lc2exp
    t-mt
    t-rand
    t-urbui
    t-urmui
    t-urndmm)
  set(_misc_tests
    t-printf
    t-scanf)
  if(NOT MSVC)
    list(APPEND _misc_tests t-locale)
  endif()

  set(_test_targets "")
  foreach(_name IN LISTS _root_tests)
    _gmp_add_upstream_test_executable(
      root "${_name}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/${_name}.c"
      gmp_tests_support "${generated_include_dir}" "${generated_mpn_dir}" _test_targets)
  endforeach()
  foreach(_name IN LISTS _mpn_tests)
    _gmp_add_upstream_test_executable(
      mpn "${_name}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/mpn/${_name}.c"
      gmp_tests_support "${generated_include_dir}" "${generated_mpn_dir}" _test_targets)
  endforeach()
  foreach(_name IN LISTS _mpz_tests)
    _gmp_add_upstream_test_executable(
      mpz "${_name}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/mpz/${_name}.c"
      gmp_tests_support "${generated_include_dir}" "${generated_mpn_dir}" _test_targets)
  endforeach()
  foreach(_name IN LISTS _mpq_tests)
    _gmp_add_upstream_test_executable(
      mpq "${_name}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/mpq/${_name}.c"
      gmp_tests_support "${generated_include_dir}" "${generated_mpn_dir}" _test_targets)
  endforeach()
  foreach(_name IN LISTS _mpf_tests)
    _gmp_add_upstream_test_executable(
      mpf "${_name}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/mpf/${_name}.c"
      gmp_tests_support "${generated_include_dir}" "${generated_mpn_dir}" _test_targets)
  endforeach()
  foreach(_name IN LISTS _rand_tests)
    _gmp_add_upstream_test_executable(
      rand "${_name}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/rand/${_name}.c"
      gmp_tests_support "${generated_include_dir}" "${generated_mpn_dir}" _test_targets)
  endforeach()
  foreach(_name IN LISTS _misc_tests)
    _gmp_add_upstream_test_executable(
      misc "${_name}" "${CMAKE_CURRENT_SOURCE_DIR}/tests/misc/${_name}.c"
      gmp_tests_support "${generated_include_dir}" "${generated_mpn_dir}" _test_targets)
  endforeach()

  add_custom_target(gmp_tests DEPENDS ${_test_targets})
endfunction()

function(_gmp_add_verify_case_targets)
  set(_verify_targets "")

  if(GMP_BUILD_STATIC)
    add_executable(gmp_verify_static_to_exe "${CMAKE_CURRENT_SOURCE_DIR}/cmake/verify/direct.c")
    target_link_libraries(gmp_verify_static_to_exe PRIVATE gmp_static)
    list(APPEND _verify_targets gmp_verify_static_to_exe)

    add_library(gmp_verify_static_to_shared SHARED "${CMAKE_CURRENT_SOURCE_DIR}/cmake/verify/consumer.c")
    target_include_directories(gmp_verify_static_to_shared PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/verify")
    target_link_libraries(gmp_verify_static_to_shared PRIVATE gmp_static)
    list(APPEND _verify_targets gmp_verify_static_to_shared)
  endif()

  if(GMP_BUILD_SHARED)
    add_executable(gmp_verify_shared_to_exe "${CMAKE_CURRENT_SOURCE_DIR}/cmake/verify/direct.c")
    target_link_libraries(gmp_verify_shared_to_exe PRIVATE gmp_shared)
    list(APPEND _verify_targets gmp_verify_shared_to_exe)

    add_library(gmp_verify_shared_to_shared SHARED "${CMAKE_CURRENT_SOURCE_DIR}/cmake/verify/consumer.c")
    target_include_directories(gmp_verify_shared_to_shared PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/cmake/verify")
    target_link_libraries(gmp_verify_shared_to_shared PRIVATE gmp_shared)
    list(APPEND _verify_targets gmp_verify_shared_to_shared)
  endif()

  if(_verify_targets)
    add_custom_target(gmp_verify_cases DEPENDS ${_verify_targets})
  endif()
endfunction()

function(gmp_build)
  string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" _gmp_processor)

  set(_gnu_asm_toolchain OFF)
  if(CMAKE_C_COMPILER_ID MATCHES "^(GNU|Clang|AppleClang)$" AND NOT MSVC)
    set(_gnu_asm_toolchain ON)
  endif()

  set(_asm_enabled OFF)
  set(_mpn_dirs generic)
  set(_mparam_header "${CMAKE_CURRENT_SOURCE_DIR}/mpn/generic/gmp-mparam.h")
  set(_m4_includes "")
  set(_family_macro "")
  set(_gsym_prefix "")
  set(_lsym_prefix "")
  set(_align_logarithmic "no")
  set(_asm_dependency_dirs "")
  set(_host_dos64 OFF)
  set(_have_calling_conventions OFF)

  if(GMP_ENABLE_ASM)
    if(NOT _gnu_asm_toolchain)
      message(FATAL_ERROR "GMP_ENABLE_ASM requires a GNU-style compiler/assembler toolchain. Disable GMP_ENABLE_ASM to use a generic C build.")
    endif()

    if(_gmp_processor MATCHES "^(x86_64|amd64)$")
      set(_asm_enabled ON)
      set(_mpn_dirs x86_64 generic)
      set(_mparam_header "${CMAKE_CURRENT_SOURCE_DIR}/mpn/x86_64/gmp-mparam.h")
      set(_family_macro "HAVE_HOST_CPU_FAMILY_x86_64")
      set(_asm_dependency_dirs "mpn/x86_64")
      set(_m4_includes "x86_64/x86_64-defs.m4")
      if(APPLE)
        list(APPEND _m4_includes "x86_64/darwin.m4")
        set(_gsym_prefix "_")
        set(_lsym_prefix "L")
        set(_align_logarithmic "yes")
      elseif(WIN32 OR CYGWIN)
        list(APPEND _m4_includes "x86_64/dos64.m4")
        set(_lsym_prefix "L")
        set(_align_logarithmic "no")
        set(_host_dos64 ON)
      else()
        set(_lsym_prefix ".L")
        set(_align_logarithmic "no")
        set(_have_calling_conventions ON)
      endif()
      if(APPLE)
        set(_have_calling_conventions ON)
      endif()
    elseif(_gmp_processor MATCHES "^(aarch64|arm64)$")
      set(_asm_enabled ON)
      set(_mpn_dirs arm64 generic)
      set(_mparam_header "${CMAKE_CURRENT_SOURCE_DIR}/mpn/arm64/gmp-mparam.h")
      set(_asm_dependency_dirs "mpn/arm64")
      set(_m4_includes "arm64/arm64-defs.m4")
      if(APPLE)
        list(APPEND _m4_includes "arm64/darwin.m4")
        set(_gsym_prefix "_")
        set(_lsym_prefix "L")
      else()
        set(_lsym_prefix ".L")
      endif()
      set(_align_logarithmic "yes")
    else()
      message(FATAL_ERROR "GMP_ENABLE_ASM is only supported by this CMake wrapper on x86_64/AMD64 and ARM64/AArch64. Disable GMP_ENABLE_ASM for a generic C build.")
    endif()

    find_program(GMP_M4_EXECUTABLE m4 REQUIRED)
  endif()

  _gmp_extract_mparam_value("${_mparam_header}" "GMP_LIMB_BITS" GMP_LIMB_BITS)
  if(NOT GMP_LIMB_BITS)
    math(EXPR GMP_LIMB_BITS "${CMAKE_SIZEOF_VOID_P} * 8")
  endif()
  math(EXPR GMP_LIMB_BYTES "${GMP_LIMB_BITS} / 8")
  set(GMP_NUMB_BITS "${GMP_LIMB_BITS}")

  check_type_size("unsigned long" GMP_SIZEOF_UNSIGNED_LONG LANGUAGE C)
  if(GMP_LIMB_BITS EQUAL 64 AND NOT GMP_SIZEOF_UNSIGNED_LONG EQUAL 8)
    set(_use_long_long_limb ON)
  else()
    set(_use_long_long_limb OFF)
  endif()

  set(GMP_GENERATED_ROOT "${CMAKE_CURRENT_BINARY_DIR}/gmp-generated")
  set(GMP_GENERATED_INCLUDE_DIR "${GMP_GENERATED_ROOT}/include")
  file(MAKE_DIRECTORY "${GMP_GENERATED_ROOT}" "${GMP_GENERATED_INCLUDE_DIR}" "${GMP_GENERATED_ROOT}/mpn")

  if(_asm_enabled)
    _gmp_generate_config_m4(
      "${GMP_GENERATED_ROOT}/config.m4"
      "${CMAKE_CURRENT_SOURCE_DIR}"
      "${GMP_LIMB_BITS}"
      "${GMP_LIMB_BYTES}"
      "${GMP_NUMB_BITS}"
      "${_mparam_header}"
      "${_m4_includes}"
      "${_gsym_prefix}"
      "${_lsym_prefix}"
      "${_align_logarithmic}"
      "${_host_dos64}")
  endif()

  _gmp_collect_mpn_sources(
    GMP_MPN_SOURCES
    GMP_NATIVE_MACROS
    "${GMP_GENERATED_ROOT}"
    "${_mparam_header}"
    "${_asm_enabled}"
    "${_mpn_dirs}"
    "${_asm_dependency_dirs}"
    "${GMP_M4_EXECUTABLE}")

  _gmp_generate_config_header(
    "${GMP_GENERATED_INCLUDE_DIR}/config.h"
    "${GMP_LIMB_BITS}"
    "${_use_long_long_limb}"
    "${GMP_NATIVE_MACROS}"
    "${_asm_enabled}"
    "${_family_macro}"
    "${_lsym_prefix}"
    "${_host_dos64}"
    "${_have_calling_conventions}")

  _gmp_generate_public_header(
    "${GMP_GENERATED_INCLUDE_DIR}/gmp.h"
    "${GMP_LIMB_BITS}"
    "${_use_long_long_limb}")

  if(MSVC)
    _gmp_generate_windows_unistd_header("${GMP_GENERATED_INCLUDE_DIR}/unistd.h")
  endif()

  configure_file("${_mparam_header}" "${GMP_GENERATED_INCLUDE_DIR}/gmp-mparam.h" COPYONLY)

  _gmp_add_generator_executable(gmp_gen_fac gen-fac.c)
  _gmp_add_generator_executable(gmp_gen_sieve gen-sieve.c)
  _gmp_add_generator_executable(gmp_gen_fib gen-fib.c)
  _gmp_add_generator_executable(gmp_gen_bases gen-bases.c)
  _gmp_add_generator_executable(gmp_gen_trialdivtab gen-trialdivtab.c)
  _gmp_add_generator_executable(gmp_gen_jacobitab gen-jacobitab.c)
  _gmp_add_generator_executable(gmp_gen_psqr gen-psqr.c)

  _gmp_add_generator_command("${GMP_GENERATED_INCLUDE_DIR}/fac_table.h" gmp_gen_fac "${GMP_LIMB_BITS}" "0")
  _gmp_add_generator_command("${GMP_GENERATED_INCLUDE_DIR}/sieve_table.h" gmp_gen_sieve "${GMP_LIMB_BITS}")
  _gmp_add_generator_command("${GMP_GENERATED_INCLUDE_DIR}/fib_table.h" gmp_gen_fib "header" "${GMP_LIMB_BITS}" "0")
  _gmp_add_generator_command("${GMP_GENERATED_ROOT}/mpn/fib_table.c" gmp_gen_fib "table" "${GMP_LIMB_BITS}" "0")
  _gmp_add_generator_command("${GMP_GENERATED_INCLUDE_DIR}/mp_bases.h" gmp_gen_bases "header" "${GMP_LIMB_BITS}" "0")
  _gmp_add_generator_command("${GMP_GENERATED_ROOT}/mpn/mp_bases.c" gmp_gen_bases "table" "${GMP_LIMB_BITS}" "0")
  _gmp_add_generator_command("${GMP_GENERATED_INCLUDE_DIR}/trialdivtab.h" gmp_gen_trialdivtab "${GMP_LIMB_BITS}" "8000")
  _gmp_add_generator_command("${GMP_GENERATED_ROOT}/mpn/jacobitab.h" gmp_gen_jacobitab)
  _gmp_add_generator_command("${GMP_GENERATED_ROOT}/mpn/perfsqr.h" gmp_gen_psqr "${GMP_LIMB_BITS}" "0")

  set_source_files_properties(
    "${GMP_GENERATED_ROOT}/mpn/fib_table.c"
    "${GMP_GENERATED_ROOT}/mpn/mp_bases.c"
    PROPERTIES GENERATED TRUE)

  _gmp_collect_directory_sources(GMP_MPF_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/mpf" "*.c")
  _gmp_collect_directory_sources(GMP_MPQ_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/mpq" "*.c")
  _gmp_collect_directory_sources(GMP_MPZ_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/mpz" "*.c")
  _gmp_collect_directory_sources(GMP_PRINTF_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/printf" "*.c")
  _gmp_collect_directory_sources(GMP_SCANF_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/scanf" "*.c")
  _gmp_collect_directory_sources(GMP_RAND_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/rand" "*.c")
  if(GMP_ENABLE_CXX)
    _gmp_collect_directory_sources(GMP_CXX_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/cxx" "*.cc")
  endif()

  set(_common_sources
    ${GMP_ROOT_SOURCES}
    ${GMP_MPF_SOURCES}
    ${GMP_MPQ_SOURCES}
    ${GMP_MPZ_SOURCES}
    ${GMP_PRINTF_SOURCES}
    ${GMP_SCANF_SOURCES}
    ${GMP_RAND_SOURCES}
    ${GMP_MPN_SOURCES}
    "${GMP_GENERATED_INCLUDE_DIR}/fac_table.h"
    "${GMP_GENERATED_INCLUDE_DIR}/fib_table.h"
    "${GMP_GENERATED_INCLUDE_DIR}/mp_bases.h"
    "${GMP_GENERATED_INCLUDE_DIR}/sieve_table.h"
    "${GMP_GENERATED_INCLUDE_DIR}/trialdivtab.h"
    "${GMP_GENERATED_ROOT}/mpn/fib_table.c"
    "${GMP_GENERATED_ROOT}/mpn/jacobitab.h"
    "${GMP_GENERATED_ROOT}/mpn/mp_bases.c")
  list(APPEND _common_sources "${GMP_GENERATED_ROOT}/mpn/perfsqr.h")

  set(_generated_outputs
    "${GMP_GENERATED_INCLUDE_DIR}/fac_table.h"
    "${GMP_GENERATED_INCLUDE_DIR}/fib_table.h"
    "${GMP_GENERATED_INCLUDE_DIR}/mp_bases.h"
    "${GMP_GENERATED_INCLUDE_DIR}/sieve_table.h"
    "${GMP_GENERATED_INCLUDE_DIR}/trialdivtab.h"
    "${GMP_GENERATED_ROOT}/mpn/fib_table.c"
    "${GMP_GENERATED_ROOT}/mpn/jacobitab.h"
    "${GMP_GENERATED_ROOT}/mpn/mp_bases.c"
    "${GMP_GENERATED_ROOT}/mpn/perfsqr.h")
  foreach(_source IN LISTS GMP_MPN_SOURCES)
    if(_source MATCHES "^${GMP_GENERATED_ROOT}/.*\\.s$")
      list(APPEND _generated_outputs "${_source}")
    endif()
  endforeach()
  add_custom_target(gmp_generated DEPENDS ${_generated_outputs})

  if(GMP_BUILD_SHARED)
    add_library(gmp_shared SHARED ${_common_sources})
    _gmp_configure_common_target(gmp_shared "${GMP_GENERATED_INCLUDE_DIR}" "${GMP_GENERATED_ROOT}/mpn")
    target_compile_definitions(gmp_shared PRIVATE GMP_SHARED)
    add_dependencies(gmp_shared gmp_generated)
    set_target_properties(gmp_shared PROPERTIES
      VERSION "${GMP_LIB_VERSION}"
      SOVERSION "${GMP_LIB_SOVERSION}")
    _gmp_set_target_layout(gmp_shared SHARED)
    add_library(GMP::gmp_shared ALIAS gmp_shared)
  endif()

  if(GMP_BUILD_STATIC)
    add_library(gmp_static STATIC ${_common_sources})
    _gmp_configure_common_target(gmp_static "${GMP_GENERATED_INCLUDE_DIR}" "${GMP_GENERATED_ROOT}/mpn")
    add_dependencies(gmp_static gmp_generated)
    set_target_properties(gmp_static PROPERTIES
      VERSION "${GMP_LIB_VERSION}")
    _gmp_set_target_layout(gmp_static STATIC)
    add_library(GMP::gmp_static ALIAS gmp_static)
  endif()

  if(GMP_BUILD_SHARED)
    add_library(GMP::gmp ALIAS gmp_shared)
  elseif(GMP_BUILD_STATIC)
    add_library(GMP::gmp ALIAS gmp_static)
  endif()

  if(GMP_ENABLE_CXX)
    if(GMP_BUILD_SHARED)
      add_library(gmpxx_shared SHARED ${GMP_CXX_SOURCES})
      _gmp_configure_common_cxx_target(gmpxx_shared "${GMP_GENERATED_INCLUDE_DIR}" "${GMP_GENERATED_ROOT}/mpn")
      target_compile_definitions(gmpxx_shared PRIVATE GMP_SHARED)
      target_link_libraries(gmpxx_shared PUBLIC gmp_shared)
      set_target_properties(gmpxx_shared PROPERTIES
        VERSION "${GMPXX_LIB_VERSION}"
        SOVERSION "${GMPXX_LIB_SOVERSION}")
      _gmp_set_target_layout(gmpxx_shared SHARED)
      add_library(GMP::gmpxx_shared ALIAS gmpxx_shared)
    endif()

    if(GMP_BUILD_STATIC)
      add_library(gmpxx_static STATIC ${GMP_CXX_SOURCES})
      _gmp_configure_common_cxx_target(gmpxx_static "${GMP_GENERATED_INCLUDE_DIR}" "${GMP_GENERATED_ROOT}/mpn")
      target_link_libraries(gmpxx_static PUBLIC gmp_static)
      set_target_properties(gmpxx_static PROPERTIES
        VERSION "${GMPXX_LIB_VERSION}")
      _gmp_set_target_layout(gmpxx_static STATIC)
      add_library(GMP::gmpxx_static ALIAS gmpxx_static)
    endif()

    if(GMP_BUILD_SHARED)
      add_library(GMP::gmpxx ALIAS gmpxx_shared)
    elseif(GMP_BUILD_STATIC)
      add_library(GMP::gmpxx ALIAS gmpxx_static)
    endif()
  endif()

  if(GMP_BUILD_VERIFY_CASES)
    _gmp_add_verify_case_targets()
  endif()

  if(GMP_BUILD_TESTS)
    _gmp_add_upstream_tests(
      "${GMP_GENERATED_INCLUDE_DIR}"
      "${GMP_GENERATED_ROOT}"
      "${GMP_GENERATED_ROOT}/mpn"
      "${_asm_enabled}"
      "${_host_dos64}"
      "${GMP_M4_EXECUTABLE}")
  endif()

  message(STATUS "GMP asm: ${_asm_enabled}")
  message(STATUS "GMP mpn path: ${_mpn_dirs}")
  message(STATUS "GMP limb bits: ${GMP_LIMB_BITS}")
endfunction()
