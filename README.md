# Patched conscrypt.jar magisk module

Bypass SSL Unpinning by patching android conscrypt.jar

# Requirement

1. rooted device with magisk

# Building

1. clone this repository
2. pull your conscrypt.jar from your device to this cloned directory (conscrpyt.jar usually located at /apex/com.android.conscrypt/javalib)
3. run `./patch.sh conscrypt.jar` to patch the jar binary and build the magisk module
4. push the module (`dist/module.zip`) to your device and flash it through magisk or TWRP

# note

1.you can specify the apktool version which will be used by adding APKTOOL_VERSION env before running the script.
eg: `$ APKTOOL_VERSION=2.10.0 ./patch.sh conscrypt.jar`

2.if you device getting bootloopped after installing the module. follow these step

```
1. boot to TWRP
2. goto File Manager and change the directory to /data/adb
3. delete conscrypt-patched directory

```

# Disabling/Uninstalling

just remove the module from Magisk Manager or delete /data/adb/conscrypt-patched directory
