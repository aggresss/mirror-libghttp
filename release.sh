#!/usr/bin/env bash
# Release package

set -e

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

# version
VERSION=$(head -n1 CHANGELOG.md | awk '{print $2}' | xargs echo)
if [ "x${VERSION}" = "x" ]; then
    echo -e "${LIGHT}${RED}No release version has been detected.${NORMAL}"
    exit 1
fi

# release file
RELEASE_FILE=""
if [[ "$1" ]];then
    RELEASE_FILE=$1
else
    RELEASE_FILE="release.csv"
fi

RELEASE_TEMPLATE="# Arch #,# SOC #,# LIBC #,# GCC Version #,# Toolchain Prefix #,# Toolchain Path #,# Toolchain Sysroot #,# Custom Flags #"
if [ ! -f ${RELEASE_FILE} ];then
    echo -e "${LIGHT}${RED}\nPlease make release file like this:"
    echo -e "${YELLOW}${RELEASE_TEMPLATE}"
    echo -e "${NORMAL}Notice:"
    echo -e "    1. Use \"none\" as placeholder."
    echo -e "    2. Use \",\" as separator."
    echo -e "\n"
    exit 1
fi

declare -a PLATFORM=()
echo -e "\n${LIGHT}${GREEN}${RELEASE_TEMPLATE}"
while IFS= read -r line || [[ "$line" ]]; do
    if [[ ! $line == \#* ]] && [[ "$line" ]]; then
        echo "$line";
        PLATFORM+=("$line")
    fi
done < $RELEASE_FILE
echo -e "${NORMAL}"

# release type
declare -a BUILD_TYPE=( \
    "Debug" \
    "Release" \
)

# build
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
    INSTANCE=`echo "${P}" | sed 's/,/\n/g'`
    INSTANCE_ARG_NUM=`echo "${INSTANCE}" | awk 'END{print NR}'`
    if [ $INSTANCE_ARG_NUM != 8 ];then
        echo -e "\n${LIGHT}${RED}Release file arguments error."
        echo -e "${YELLOW}${P}\n${NORMAL}"
        exit 1
    fi
    ARCH=`echo "${INSTANCE}" | sed -n '1p' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'`
    echo "ARCH: ${ARCH}"
    SOC=`echo "${INSTANCE}" | sed -n '2p' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'`
    echo "SOC: ${SOC}"
    LIBC=`echo "${INSTANCE}" | sed -n '3p' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'`
    echo "LIBC: ${LIBC}"
    GCCVER=`echo "${INSTANCE}" | sed -n '4p' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'`
    echo "GCCVER: ${GCCVER}"
    TOOLCHAIN_PREFIX=`echo "${INSTANCE}" | sed -n '5p' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'`
    echo "TOOLCHAIN_PREFIX: ${TOOLCHAIN_PREFIX}"
    TOOLCHAIN_PATH=`echo "${INSTANCE}" | sed -n '6p' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'`
    echo "TOOLCHAIN_PATH: ${TOOLCHAIN_PATH}"
    TOOLCHAIN_SYSROOT=`echo "${INSTANCE}" | sed -n '7p' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g'`
    echo "TOOLCHAIN_SYSROOT: ${TOOLCHAIN_SYSROOT}"
    CUSTOM_FLAGS=`echo "${INSTANCE}" | sed -n '8p' | sed 's/^[ \t]*//g' | sed 's/[ \t]*$//g' | sed 's/\r\|\|\r\n\|\|\n//g'`
    echo "CUSTOM_FLAGS: ${CUSTOM_FLAGS}"

    CMAKE_OPTION=""
    BUILD_DIR=""
    if [ "${ARCH}" != "none" ] && [ "${ARCH}" != "" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCPACK_ARCH=${ARCH}"
        BUILD_DIR="${ARCH}_"
    fi
    if [ "${SOC}" != "none" ] && [ "${SOC}" != "" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCPACK_SOC=${SOC}"
        BUILD_DIR="${BUILD_DIR}${SOC}_"
    fi
    if [ "${LIBC}" != "none" ] && [ "${LIBC}" != "" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCPACK_LIBC=${LIBC}"
        BUILD_DIR="${BUILD_DIR}${LIBC}_"
    fi
    if [ "${GCCVER}" != "none" ] && [ "${GCCVER}" != "" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCPACK_GCCVER=${GCCVER}"
        BUILD_DIR="${BUILD_DIR}${GCCVER}"
    fi
    if [ "${TOOLCHAIN_PREFIX}" != "none" ] && [ "${TOOLCHAIN_PREFIX}" != "" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCROSS_COMPILE=${TOOLCHAIN_PREFIX}"
    fi
    if [ "${TOOLCHAIN_PATH}" != "none" ] && [ "${TOOLCHAIN_PATH}" != "" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DTOOLCHAIN_PATH=${TOOLCHAIN_PATH}"
    fi
    if [ "${TOOLCHAIN_SYSROOT}" != "none" ] && [ "${TOOLCHAIN_SYSROOT}" != "" ]; then
        CMAKE_OPTION="${CMAKE_OPTION} -DCMAKE_SYSROOT=${TOOLCHAIN_SYSROOT}"
    fi
    if [ "${CUSTOM_FLAGS}" != "none" ] && [ "${CUSTOM_FLAGS}" != "" ]; then
        CUSTOM_FLAGS_NO_SPACE=`echo "${CUSTOM_FLAGS}" | sed 's/ /,/g'`
        echo "${CUSTOM_FLAGS_NO_SPACE}"
        CMAKE_OPTION="${CMAKE_OPTION} -DCUSTOM_FLAGS=${CUSTOM_FLAGS_NO_SPACE}"
    fi

    # Strip last "_"
    if [ "${BUILD_DIR: -1}" = "_"  ]; then
        BUILD_DIR="${BUILD_DIR%_}"
    fi

    mkdir -p ${BUILD_DIR}
    cd ${BUILD_DIR}

    for B in ${BUILD_TYPE[@]}
    do
        echo -e "========== BUILD: [${CYAN}${LIGHT}${BUILD_DIR}_${B}${NORMAL}] =========="
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
        CMAKE_EXECUTE="cmake -DCMAKE_BUILD_TYPE=${B} ${CMAKE_OPTION} ${SOURCE_PATH}"
        eval ${CMAKE_EXECUTE}
        echo -e "\n${LIGHT}${GREEN}${CMAKE_EXECUTE}${NORMAL}\n"
        make package
        cp *${BUILD_DIR}_${B}.tar.gz ${RELEASE_PATH}/
        cd ..
    done

    cd ..
done

cd ${SOURCE_PATH}
COMMIT_ID=`git rev-parse HEAD`

cd ${RELEASE_PATH}
echo "Version: ${VERSION}" > release_info.txt
echo "Commit ID: ${COMMIT_ID}" >> release_info.txt
echo "MD5:" >> release_info.txt
ls -1 *.tar.gz | xargs md5sum >> release_info.txt

cp -f ${SOURCE_PATH}/CHANGELOG.md ${RELEASE_PATH}/

echo -e "\n${LIGHT}${GREEN}Release version ${VERSION} successful.${NORMAL}\n"
exit 0

