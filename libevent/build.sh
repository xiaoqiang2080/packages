#!/bin/bash

#################################################################################
# Comment: Estuary Application Build.sh for libevent
# Author: Chris
# Date : 2017/02/25
#################################################################################

BUILDDIR=$(cd $1; pwd) # that is ${builddir}/packages/builddir/${packagename}/
DISTRO=$2 # such as Ubuntu, CentOS, Debian and so on 
ROOTFS=$(cd $3; pwd) # that is ${builddir}/distro/${DISTRO}
KERNEL_DIR=$(cd $4; pwd) # that is ${buildir}/kernel
CROSS=$5  # such as aarch64-linux-gnu- on X86 platform or "" on ARM64 platform
PACK_TYPE=$6 # such as "tar", "rpm", "deb" or "all"
PACK_SAVE_DIR=$(cd $7; pwd) # that is ${builddir}/packages/${DISTRO}
INSTALLDIR=$8  # default to "/usr/estuary/"

PACKAGE_DIR=`pwd`/packages
CUR_PKG="libevent"
VERSION="2.1.7"

#
# Use ${CROSS}gcc to compile source codes under ${BUILDDIR}
# In addition, use ${INSTALLDIR}/bin, ${INSTALLDIR}/libs, and 
# ${INSTALLDIR}/includes to install packages 
# 
# However if it needs to install two or more version of the same package
# it must be installed into ${INSTALLDIR}/${CUR_PKG}/{bin,includes,libs} accordingly 
# 

case $DISTRO in
    CentOS)
        echo "begin to build $CUR_PKG-$VERSION ..."
    ;;
    Debian | Ubuntu)
        exit 0
    ;;
    *)
        echo "unkown system: $DISTRO"
        exit 0
    ;;
esac
#
# Generate the corresponding packages files 
#
#Generate tar file which MUST contain setup.sh 
if [ ! -d ${BUILDDIR}/tar ] ; then
    mkdir -p ${BUILDDIR}/tar
fi

if [ ! -d ${BUILDDIR}/rpm ] ; then
    mkdir -p ${BUILDDIR}/rpm
fi

if [ ! -d ${BUILDDIR}/deb ] ; then
    mkdir -p ${BUILDDIR}/deb
fi

if [ x"${PACK_TYPE}" == x"all" ] || [ x"${PACK_TYPE}" == x"tar" ] ; then
    pushd ${BUILDDIR}/tar
    cp ${PACKAGE_DIR}/${CUR_PKG}/setup.sh ./
    cp ${PACKAGE_DIR}/${CUR_PKG}/remove.sh ./
    #cp other files to ./
    cp ${PACKAGE_DIR}/${CUR_PKG}/${CUR_PKG}-${VERSION}*.tar.gz ./
    tar -czvf ../${CUR_PKG}-${VERSION}.tar.gz ./
    popd > /dev/null
    
    sudo cp ${BUILDDIR}/${CUR_PKG}-${VERSION}.tar.gz ${PACK_SAVE_DIR}/
fi

#Use rpmbuild to generete rpm file
if [ x"${PACK_TYPE}" == x"all" ] || [ x"${PACK_TYPE}" == x"rpm" ] ; then
    #Build rpm file firstly 
    sudo cp ${BUILDDIR}/${CUR_PKG}-${VERSION}.rpm ${PACK_SAVE_DIR}/
fi

#Generate deb files
if [ x"${PACK_TYPE}" == x"all" ] || [ x"${PACK_TYPE}" == x"deb" ] ; then
    #Build deb file firstly 
    sudo cp ${BUILDDIR}/${CUR_PKG}-${VERSION}.deb ${PACK_SAVE_DIR}/
fi

exit 0
