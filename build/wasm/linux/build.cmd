@echo off

docker build ../../.. -f Dockerfile -t magick-wasm-linux
docker run -it -v %~dp0output:/output -w /Native magick-wasm-linux /build/copy.Native.sh /output