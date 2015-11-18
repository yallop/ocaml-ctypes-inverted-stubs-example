#!/usr/bin/env bash
set -ex

export OPAMYES=1

x="$(uname -m)"
case "$x" in
    x86_64)
        build=x86_64-pc-cygwin
        host=x86_64-w64-mingw32
        MINGW_TOOL_PREFIX=${host}-
	SWITCH=4.02.3+mingw64c
        ;;
    *)
        build=i686-pc-cygwin
        host=i686-w64-mingw32
        MINGW_TOOL_PREFIX=${host}-
	SWITCH=4.02.3+mingw32c
        ;;
esac

export AR=${MINGW_TOOL_PREFIX}ar.exe
export AS=${MINGW_TOOL_PREFIX}as.exe
export CC=${MINGW_TOOL_PREFIX}gcc.exe
export CPP=${MINGW_TOOL_PREFIX}cpp.exe
export CPPFILT=${MINGW_TOOL_PREFIX}c++filt.exe
export CXX=${MINGW_TOOL_PREFIX}g++.exe
export DLLTOOL=${MINGW_TOOL_PREFIX}dlltool.exe
export DLLWRAP=${MINGW_TOOL_PREFIX}dllwrap.exe
export GCOV=${MINGW_TOOL_PREFIX}gcov.exe
export LD=${MINGW_TOOL_PREFIX}ld.exe
export NM=${MINGW_TOOL_PREFIX}nm.exe
export OBJCOPY=${MINGW_TOOL_PREFIX}objcopy.exe
export OBJDUMP=${MINGW_TOOL_PREFIX}objdump.exe
export RANLIB=${MINGW_TOOL_PREFIX}ranlib.exe
export RC=${MINGW_TOOL_PREFIX}windres.exe
export READELF=${MINGW_TOOL_PREFIX}readelf.exe
export SIZE=${MINGW_TOOL_PREFIX}size.exe
export STRINGS=${MINGW_TOOL_PREFIX}strings.exe
export STRIP=${MINGW_TOOL_PREFIX}strip.exe
export WINDMC=${MINGW_TOOL_PREFIX}windmc.exe
export WINDRES=${MINGW_TOOL_PREFIX}windres.exe

export PATH=/usr/$host/sys-root/mingw/bin:$PATH

tar xf opam.tar.xz
bash opam*/install.sh
opam init mingw 'https://github.com/fdopen/opam-repository-mingw.git' --comp ${SWITCH} --switch ${SWITCH}
eval `opam config env`
#opam install depext depext-cygwinports
opam install depext-cygwinports
# opam depext ctypes-foreign
cygwin-install install libffi pkg-config
opam install --verbose ctypes-foreign ctypes xmlm
make && make test
