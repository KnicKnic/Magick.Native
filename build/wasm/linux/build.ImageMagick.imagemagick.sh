#!/bin/bash
set -e

export FLAGS="-O3"
export STRICT_FLAGS="${FLAGS} -Wall"
export CONFIGURE="emconfigure ./configure"
export CMAKE_COMMAND="emconfigure cmake"
export MAKE="emcmake make"
export CPPFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
export CONDITIONAL_DISABLE_SHARED="--disable-shared"
export PKG_PATH="/usr/local/lib/pkgconfig"
export HEIF_HACK=true
export LIBXML_OPTIONS=""
export SIMD_OPTIONS="-DWITH_SIMD=0"
export SSE_OPTIONS="--disable-sse"

buildImageMagick() {
    local quantum=$1

    # Set ImageMagick variables
    local hdri=no
    local depth=8
    if [ "$quantum" == "Q16" ]; then
        depth=16
    elif [ "$quantum" == "Q16-HDRI" ]; then
        quantum_name=Q16HDRI
        depth=16
        hdri=yes
    fi

    $CONFIGURE --disable-shared --disable-openmp --enable-static --enable-delegate-build --without-threads --without-magick-plus-plus --disable-docs --without-bzlib --without-lzma --without-x --with-quantum-depth=$depth --enable-hdri=$hdri CFLAGS="$STRICT_FLAGS" CXXFLAGS="$STRICT_FLAGS" PKG_CONFIG_PATH="$PKG_PATH"
    $MAKE install
}

# Build ImageMagick
cd ../ImageMagick
autoreconf -fiv
buildImageMagick "Q8"