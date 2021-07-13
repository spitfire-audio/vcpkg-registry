vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AndyBrown91/libarchive
    REF 63298dce96a18d5a7b5b018e7fd9486432211ff9   #v3.4.3
    SHA512  2e39cdcf76d0ae9141d1d281b4a33915fedebdba75303fa321bc76ed2c7c92d98843162eab48b3f6218091ef1d1062f288e90f14ef877710f73a690174d8f994
    HEAD_REF windows-long-path-fix
    PATCHES
        fix-buildsystem.patch
        fix-dependencies.patch
        fix-cpu-set.patch
        disable-warnings.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    bzip2   ENABLE_BZip2
    libxml2 ENABLE_LIBXML2
    lz4     ENABLE_LZ4
    lzma    ENABLE_LZMA
    lzo     ENABLE_LZO
    openssl ENABLE_OPENSSL
    zstd    ENABLE_ZSTD
    # The below features should be added to CONTROL
    #pcre    ENABLE_PCREPOSIX
    #nettle  ENABLE_NETTLE
    #expat   ENABLE_EXPAT
    #libgcc  ENABLE_LibGCC
    #cng     ENABLE_CNG
    #tar     ENABLE_TAR # Tool build option?
    #cpio    ENABLE_CPIO # Tool build option?
    #cat     ENABLE_CAT # Tool build option?
    #xattr   ENABLE_XATTR # Tool support option?
    #acl     ENABLE_ACL # Tool support option?
    #iconv   ENABLE_ICONV # iconv support option?
    #libb2   ENABLE_LIBB2
)

if(FEATURES MATCHES "pcre")
else()
    list(APPEND FEATURE_OPTIONS -DPOSIX_REGEX_LIB=NONE)
endif()

list(APPEND FEATURE_OPTIONS -DENABLE_ZLIB=ON)
# Needed for configure_file
set(ENABLE_ZLIB ON)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_PCREPOSIX=OFF
        -DENABLE_NETTLE=OFF
        -DENABLE_EXPAT=OFF
        -DENABLE_LibGCC=OFF
        -DENABLE_CNG=OFF
        -DENABLE_TAR=OFF
        -DENABLE_CPIO=OFF
        -DENABLE_CAT=OFF
        -DENABLE_XATTR=OFF
        -DENABLE_ACL=OFF
        -DENABLE_ICONV=OFF
        -DENABLE_LIBB2=OFF
        -DENABLE_TEST=OFF
        -DENABLE_WERROR=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

foreach(HEADER ${CURRENT_PACKAGES_DIR}/include/archive.h ${CURRENT_PACKAGES_DIR}/include/archive_entry.h)
    file(READ ${HEADER} CONTENTS)
    string(REPLACE "(!defined LIBARCHIVE_STATIC)" "0" CONTENTS "${CONTENTS}")
    file(WRITE ${HEADER} "${CONTENTS}")
endforeach()

file(INSTALL ${CURRENT_PORT_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)