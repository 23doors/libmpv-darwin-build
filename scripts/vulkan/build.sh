#!/bin/sh

set -e # exit immediately if a command exits with a non-zero status
set -u # treat unset variables as an error

# cmake weird fix
export PATH="/opt/homebrew/bin:$PATH"

cd ${SRC_DIR}

cp ${PROJECT_DIR}/scripts/vulkan/meson.build ./meson.build

meson setup build_cross \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${OUTPUT_DIR}"
cmake ./subprojects/vulkan \
    -B build_cross \
    -DCMAKE_INSTALL_PREFIX="${OUTPUT_DIR}" \
    -DBUILD_STATIC=OFF \
    -DUPDATE_DEPS=On \
    -DUSE_GAS=On
make -C build_cross
make -C build_cross install
