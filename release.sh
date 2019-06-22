#!/usr/bin/env bash
# Release package

set -e

# | Arch | SOC | LIBC | GCC version | Toolchain prefix |
# Notice: Use "none" as placeholder.
declare -a PLATFORM=( \
#    "Arm     Hi3518EV200    uclibc  4.8.3   arm-hisiv300-linux               " \
#    "Arm     Hi3516C        uclibc  4.9.4   arm-hisiv500-linux-uclibcgnueabi " \
#    "Arm     Mstar316DM     none    4.8.3   arm-linux-gnueabihf-gcc          " \
#    "Mips    T20            uclibc  4.7.2   mips-linux-uclibc-gnu            " \
    "x86      Intel          glibc    none   none                             " \
#    "x64     none           none    none    none                             " \
)

declare -a BUILD_TYPE=( \
    "Release" \
    "Debug" \
)

# linux shell color support.
BLACK="\\033[30m"
RED="\\033[31m"
GREEN="\\033[32m"
YELLOW="\\033[33m"
BLUE="\\033[34m"
MAGENTA="\\033[35m"
CYAN="\\033[36m"
WHITE="\\033[37m"
NORMAL="\\033[m"
LIGHT="\\033[1m"
INVERT="\\033[7m"

VERSION=$(head -n1 CHANGELOG.md | awk '{print $2}' | xargs echo)
if [ "x${VERSION}" = "x" ]; then
    echo -e "${LIGHT}${RED}No release version has been detected.${NORMAL}"
    exit 1
fi

SOURCE_PATH="${PWD}"
RELEASE_PATH="${PWD}/release/v${VERSION}"
REBUILD_TYPE=""

if [ ! -d ${RELEASE_PATH} ]; then
    mkdir -p ${RELEASE_PATH}
fi

mkdir -p build
cd build

for P in "${PLATFORM[@]}"
do
    declare -a ARRAY=(${P})
    ARCH=${ARRAY[0]}
    SOC=${ARRAY[1]}
    LIBC=${ARRAY[2]}
    GCCVER=${ARRAY[3]}
    TOOLCHAIN_PREFIX=${ARRAY[4]}

    CMAKE_OPTION=""
    BUILD_DIR=""
    if [ "${ARCH}" != "none" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCPACK_ARCH=${ARCH}"
        BUILD_DIR="${ARCH}_"
    fi
    if [ "${SOC}" != "none" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCPACK_SOC=${SOC}"
        BUILD_DIR="${BUILD_DIR}${SOC}_"
    fi
    if [ "${LIBC}" != "none" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCPACK_LIBC=${LIBC}"
        BUILD_DIR="${BUILD_DIR}${LIBC}_"
    fi
    if [ "${GCCVER}" != "none" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCPACK_GCCVER=${GCCVER}"
        BUILD_DIR="${BUILD_DIR}${GCCVER}"
    fi
    if [ "${TOOLCHAIN_PREFIX}" != "none" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCROSS_COMPILE=${TOOLCHAIN_PREFIX}"
    fi

    # Strip last "_"
    if [ "${BUILD_DIR: -1}" = "_"  ]; then
        BUILD_DIR="${BUILD_DIR%_}"
    fi

    mkdir -p ${BUILD_DIR}
    cd ${BUILD_DIR}

    for B in ${BUILD_TYPE[@]}
    do
        echo -e "========== BUILD: [${CYAN}${LIGHT}${BUILD_DIR}_${BUILD_TYPE}${NORMAL}] =========="
        if ls ${RELEASE_PATH}/*${BUILD_DIR}_${B}.tar.gz > /dev/null 2>&1; then
            case ${REBUILD_TYPE} in
                ALL)
                    rm -rf ${RELEASE_PATH}/*${BUILD_DIR}_${B}.tar.gz
                    ;;
                NONE)
                    continue
                    ;;
                *)
                    echo -e "[${CYAN}${LIGHT}${BUILD_DIR}_${B}${NORMAL}] has exist, rebuild again ? [y/n/Y/N]"
                    read isRebuild
                    case ${isRebuild} in
                        y)
                            rm -rf ${RELEASE_PATH}/*${BUILD_DIR}_${B}.tar.gz
                            ;;
                        Y)
                            REBUILD_TYPE="ALL"
                            rm -rf ${RELEASE_PATH}/*${BUILD_DIR}_${B}.tar.gz
                            ;;
                        N)
                            REBUILD_TYPE="NONE"
                            continue
                            ;;
                        *)
                            continue
                            ;;
                    esac
                    ;;
            esac
        fi
        rm -rf ${B}
        mkdir -p ${B}
        cd ${B}
        cmake ${SOURCE_PATH} -DCMAKE_BUILD_TYPE=${B} ${CMAKE_OPTION}
        make package
        cp *${BUILD_DIR}_${B}.tar.gz ${RELEASE_PATH}/
        cd ..
    done

    cd ..
done

cd ..

echo -e "\n${LIGHT}${GREEN}Release version ${VERSION} successful.${NORMAL}\n"
exit 0
