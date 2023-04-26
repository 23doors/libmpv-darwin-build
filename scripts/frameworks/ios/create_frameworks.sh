#!/bin/bash

# see: MobileVLCKit cocoapods

LIBS_DIR="$1"
FRAMEWORKS_DIR="$2"

find "${LIBS_DIR}" -name "*.dylib" -type f | while read DYLIB; do
    echo "${DYLIB}"

    # create framework name: libavcodec.59.dylib -> Avcodec
    FRAMEWORK_NAME=$(basename $DYLIB .dylib | sed 's/\.[0-9]*$//' | sed 's/^lib//')
    FRAMEWORK_NAME="$(tr '[:lower:]' '[:upper:]' <<<${FRAMEWORK_NAME:0:1})${FRAMEWORK_NAME:1}"

    # framework dir
    FRAMEWORK_DIR="${FRAMEWORKS_DIR}/${FRAMEWORK_NAME}.framework"

    # determine archs
    ARCHS=$(lipo -archs "${DYLIB}")

    # determine lowest min os version across archs
    for ARCH in ${ARCHS}; do
        # determine min os version for the current arch
        ARCH_MIN_OS_VERSION=$(xcrun vtool -arch ${ARCH} -show-build "${DYLIB}" | grep minos | cut -d ' ' -f6)
        if [ -z "${ARCH_MIN_OS_VERSION}" ]; then
            ARCH_MIN_OS_VERSION=$(xcrun vtool -arch ${ARCH} -show-build "${DYLIB}" | grep version | cut -d ' ' -f4)
        fi

        # if not found throw an error
        if [ -z "${ARCH_MIN_OS_VERSION}" ]; then
            echo "Unable to find min os version for ${ARCH}"
            exit 1
        fi

        # if $MIN_OS_VERSION is null or greater than $ARCH_MIN_OS_VERSION replace it
        if [ -z "${MIN_OS_VERSION}" ] || (($(bc -l <<<"${MIN_OS_VERSION} > ${ARCH_MIN_OS_VERSION}"))); then
            MIN_OS_VERSION=${ARCH_MIN_OS_VERSION}
        fi
    done

    # copy dylib
    mkdir -p "${FRAMEWORK_DIR}"
    cp "${DYLIB}" "${FRAMEWORK_DIR}/${FRAMEWORK_NAME}"

    # replace DYLIB var
    DYLIB="${FRAMEWORK_DIR}/${FRAMEWORK_NAME}"

    codesign --force -s - "${DYLIB}"

    # update dylib id
    NEW_ID="@rpath/${FRAMEWORK_NAME}.framework/${FRAMEWORK_NAME}"
    install_name_tool \
        -id "${NEW_ID}" "${DYLIB}" \
        2>/dev/null

    # update dylib dep paths
    otool -l "${DYLIB}" |
        grep " name " |
        cut -d " " -f11 |
        tail -n +2 |
        grep "@rpath" |
        while read DEP; do
            DEP_NAME=$(basename $DEP .dylib | sed 's/\.[0-9]*$//' | sed 's/^lib//')
            DEP_NAME="$(tr '[:lower:]' '[:upper:]' <<<${DEP_NAME:0:1})${DEP_NAME:1}"

            NEW_DEP="@rpath/${DEP_NAME}.framework/${DEP_NAME}"

            install_name_tool \
                -change "${DEP}" "${NEW_DEP}" \
                "${DYLIB}" \
                2>/dev/null
        done

    codesign --remove "${DYLIB}"

    # add Info.plist
    cp ./scripts/frameworks/ios/Info.plist "${FRAMEWORK_DIR}/"
    sed -i '' 's/${FRAMEWORK_NAME}/'${FRAMEWORK_NAME}'/g' "${FRAMEWORK_DIR}/Info.plist"
    sed -i '' 's/${MIN_OS_VERSION}/'${MIN_OS_VERSION}'/g' "${FRAMEWORK_DIR}/Info.plist"
    plutil -convert binary1 "${FRAMEWORK_DIR}/Info.plist"
done
