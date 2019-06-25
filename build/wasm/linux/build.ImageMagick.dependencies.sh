#!/bin/bash
set -e

export PLATFORM="WASM"
export CPPFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
export FLAGS="-O3 --bind -s WASM=1 -s ALLOW_MEMORY_GROWTH=1"
export STRICT_FLAGS="${FLAGS} -Wall"
export CONFIGURE="emconfigure ./configure"
export CMAKE_COMMAND="emconfigure cmake"
export CMAKE_OPTIONS="-D CMAKE_CXX_COMPILER=em++ -D CMAKE_C_COMPILER=emcc"
export MAKE="emcmake make"
export CONDITIONAL_DISABLE_SHARED="--disable-shared"
export PKG_PATH="/usr/local/lib/pkgconfig"
export HEIF_HACK=true
export LIBXML_OPTIONS=""
export SIMD_OPTIONS="-DWITH_SIMD=0"
export SSE_OPTIONS="--disable-sse"

# Build zlib
cd zlib
chmod +x ./configure
$CONFIGURE --static
$MAKE install CFLAGS="$FLAGS"

# Build libxml
cd ../libxml
autoreconf -fiv
$CONFIGURE --with-python=no --enable-static --disable-shared $LIBXML_OPTIONS CFLAGS="$FLAGS"
$MAKE install

# Build libpng
cd ../png
autoreconf -fiv
$CONFIGURE --disable-mips-msa --disable-arm-neon --disable-powerpc-vsx --disable-shared CFLAGS="$FLAGS"
$MAKE install

# Build freetype
cd ../freetype
./autogen.sh
$CONFIGURE --disable-shared --without-bzip2 CFLAGS="$FLAGS"
$MAKE install
make clean
mkdir build
cd build
$CMAKE_COMMAND .. -DCMAKE_INSTALL_PREFIX=/usr/local -DENABLE_SHARED=off -DCMAKE_DISABLE_FIND_PACKAGE_BZip2=TRUE -DCMAKE_C_FLAGS="$FLAGS"
$MAKE install
cd ..
# Build libjpeg-turbo
cd ../jpeg
$CMAKE_COMMAND . -DCMAKE_INSTALL_PREFIX=/usr/local -DENABLE_SHARED=off ${SIMD_OPTIONS} -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="$FLAGS"
$MAKE install

# Build libtiff
cd ../tiff
autoreconf -fiv
$CONFIGURE ${CONDITIONAL_DISABLE_SHARED} CFLAGS="$FLAGS"
$MAKE install

# Build libwebp
cd ../webp
autoreconf -fiv
chmod +x ./configure
$CONFIGURE --enable-libwebpmux --enable-libwebpdemux --disable-shared CFLAGS="${FLAGS}"
$MAKE install

# Build openjpeg
cd ../openjpeg
$CMAKE_COMMAND . -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=off -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="$FLAGS" || true
$CMAKE_COMMAND . -DCMAKE_INSTALL_PREFIX=/usr/local -DBUILD_SHARED_LIBS=off -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS="$FLAGS"
$MAKE install
cp bin/libopenjp2.a /usr/local/lib

# Build lcms
cd ../lcms
autoreconf -fiv
$CONFIGURE --disable-shared --prefix=/usr/local CFLAGS="$FLAGS"
$MAKE install

# Build libde265
cd ../libde265
autoreconf -fiv
chmod +x ./configure
$CONFIGURE --disable-shared $SSE_OPTIONS --disable-dec265 --prefix=/usr/local CFLAGS="$FLAGS" CXXFLAGS="$FLAGS"
$MAKE install

# Build libheif
cd ../libheif
autoreconf -fiv
chmod +x ./configure
$CONFIGURE --disable-shared --disable-go --prefix=/usr/local CFLAGS="$FLAGS" CXXFLAGS="$FLAGS" PKG_CONFIG_PATH="$PKG_PATH"
if [ "$HEIF_HACK" = true ]; then
    for f in examples/*.cc; do echo "" > $f; done
fi
$MAKE install

# Build libraw
cd ../libraw
chmod +x ./version.sh
chmod +x ./shlib-version.sh
chmod +x ./configure
autoreconf -fiv
$CONFIGURE --disable-shared --disable-examples --disable-openmp --disable-jpeg --disable-jasper --prefix=/usr/local  CFLAGS="$FLAGS" CXXFLAGS="$FLAGS"
$MAKE install

