#!/bin/sh

cd ${SOURCES_DIR}/freetype
meson setup build \
    --cross-file ${PROJECT_DIR}/cross-files/${OS}-${ARCH}.ini \
    --prefix="${PREFIX}" \
    -Dbrotli=disabled \
    -Dbzip2=disabled \
    -Dharfbuzz=enabled \
    -Dmmap=disabled \
    -Dpng=enabled \
    -Dtests=disabled \
    -Dzlib=enabled
meson compile -C build
meson install -C build
