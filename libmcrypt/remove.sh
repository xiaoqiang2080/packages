#!/bin/bash

#################################################################################
# Comment: Estuary Application Remove.sh for libmcrypt
# Author: Chris
# Date : 2017/02/25
#################################################################################

# This script is to remove this package
# 
CUR_PKG="libmcrypt"

#remove the binary of libmcrypt
count=`find / -name "$CUR_PKG.so*" | wc -l`
if [ $count -gt 0 ];then
    rm -fr /usr/estuary/lib/$CUR_PKG.so*
fi

exit 0

