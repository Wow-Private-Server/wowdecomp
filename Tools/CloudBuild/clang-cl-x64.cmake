# Cross-compile the x64 client on Linux with clang-cl and lld-link. Run setup.sh first.
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_VERSION 10.0)
set(CMAKE_SYSTEM_PROCESSOR AMD64)

if (DEFINED ENV{MSVC_ROOT})
    set(MSVC_ROOT $ENV{MSVC_ROOT})
else ()
    set(MSVC_ROOT /opt/msvc)
endif ()

set(_vc ${MSVC_ROOT}/vc/lib/native)
set(_inc ${MSVC_ROOT}/sdk/c/Include/10.0.26100.0)
set(_lib ${MSVC_ROOT}/sdkx64/c)
set(_overlay ${MSVC_ROOT}/overlay.json)

find_program(_clang_cl NAMES clang-cl clang-cl-18 REQUIRED)
set(CMAKE_C_COMPILER ${_clang_cl})
set(CMAKE_CXX_COMPILER ${_clang_cl})
set(CMAKE_LINKER lld-link)
set(CMAKE_AR llvm-lib)
set(CMAKE_RC_COMPILER llvm-rc)
set(CMAKE_MT llvm-mt)
set(CMAKE_C_COMPILER_TARGET x86_64-pc-windows-msvc)
set(CMAKE_CXX_COMPILER_TARGET x86_64-pc-windows-msvc)

# compat/ goes first: it fills in the C++17 std::filesystem parts the 14.11 STL lacks.
# -Wno-everything also turns off diagnostics clang makes errors but MSVC accepts (enum narrowing).
set(_flags "-fms-compatibility-version=19.11 -vfsoverlay ${_overlay} /imsvc ${CMAKE_CURRENT_LIST_DIR}/compat /imsvc ${_vc}/include /imsvc ${_inc}/ucrt /imsvc ${_inc}/um /imsvc ${_inc}/shared -Wno-everything /w")
set(CMAKE_C_FLAGS_INIT "${_flags}")
set(CMAKE_CXX_FLAGS_INIT "${_flags}")
set(CMAKE_RC_FLAGS_INIT "/I ${_inc}/um /I ${_inc}/shared /I ${_inc}/ucrt")

set(_ldflags "/vfsoverlay:${_overlay} /libpath:${_vc}/lib/x64 /libpath:${_lib}/um/x64 /libpath:${_lib}/ucrt/x64")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${_ldflags}")
set(CMAKE_SHARED_LINKER_FLAGS_INIT "${_ldflags}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${_ldflags}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
