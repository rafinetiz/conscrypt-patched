#/system/bin/sh

MODDIR=${0%/*}
TMP_LOCAL_DIR="/data/local/conscrypt_tmp"

remount_apex_writeable() {
  local pkgname=$1
  # create temporary directory
  # mkdir ${TMP_LOCAL_DIR}/${pkgname}

  cp ${MODDIR}/empty.img ${TMP_LOCAL_DIR}/mod.img

  # mount point for our image
  mkdir ${TMP_LOCAL_DIR}/mnt
  mount -t ext4 ${TMP_LOCAL_DIR}/mod.img ${TMP_LOCAL_DIR}/mnt

  # copy original 
  cp -pr /apex/${pkgname}/* ${TMP_LOCAL_DIR}/mnt
  touch ${TMP_LOCAL_DIR}/mnt/activated
  
  umount ${TMP_LOCAL_DIR}/mnt
  umount /apex/${pkgname}

  mount -t ext4 ${TMP_LOCAL_DIR}/mod.img /apex/${pkgname}
  chcon -R u:object_r:system_file:s0 /apex/${pkgname}
  chcon -R u:object_r:system_lib_file:s0 /apex/${pkgname}/lib*
}

rm -rf ${TMP_LOCAL_DIR}
mkdir -p ${TMP_LOCAL_DIR}

remount_apex_writeable "com.android.conscrypt"

stop
mv /system/framework/conscrypt.jar /apex/com.android.conscrypt/javalib/conscrypt.jar
debug_ramdisk/su -c 'start'