#!/bin/bash
check_executeable() {
  local exec_name=$1
  local message=$2

  which $exec_name &>/dev/null

  if [[ $? -ne 0 ]]; then
    echo -e "the command\e[1;31m" $exec_name "\e[0m was not found. make sure its installed"
    echo "try:" $message

    exit 1
  fi
}

ensure_zero() {
  $@

  local code=$?
  if [[ $code -ne 0 ]]; then
    echo -e "\e[1;31mcommand" $1 "return non-zero exit code\e[0m" $code
    exit $code
  fi
}

setup_apktool() {
  local version=$1

  if [[ ! -e "lib/apktool_$version.jar" ]]; then
    echo -e "\e[33mdownloading apktool binaries\e[0m"
    wget -nv --show-progress "https://github.com/iBotPeaches/Apktool/releases/download/v$version/apktool_$version.jar" -O lib/apktool_$version.jar

    if [[ $? -eq 0 ]]; then
      echo -e "\e[32mdownload success\e[0m"
    else
      # wget still created the output file even though the remote url is 40x, 50x, etc.
      # so we need to remove it manually incase of failure
      rm -rf "lib/apktool_$version.jar"
    fi
  fi

  APKTOOL="lib/apktool_$version.jar"
}

apktool() {
  java -jar $APKTOOL $@
}

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <jarfile>"
  exit 1
fi

check_executeable "java" "apt install openjdk-21-jdk-headless"
check_executeable "zipalign" "apt install zipalign"
check_executeable "patch" "apt install patch"
check_executeable "wget" "apt install wget"
check_executeable "zip" "apt install zip"

if [[ -z $APKTOOL_VERSION ]]; then
  APKTOOL_VERSION="2.11.0"
fi

setup_apktool $APKTOOL_VERSION

jarfile=$1

echo -e "\e[33mdecompiling jar file...\e[0m"
ensure_zero apktool d -f -r -o $jarfile.tmp $jarfile

echo -e "\e[33mpatching classes...\e[0m"
ensure_zero patch $jarfile.tmp/smali/com/android/org/conscrypt/TrustManagerImpl.smali patches/TrustManagerImpl.patch

echo -e "\e[33mrecompiling jar file...\e[0m"
ensure_zero apktool b --api-level 35 -c -o build/$jarfile $jarfile.tmp
rm -r $jarfile.tmp

echo -e "\e[33mzipaligning jar file...\e[0m"
ensure_zero zipalign 4 build/$jarfile build/$jarfile.aligned.jar
ensure_zero zipalign -cv 4 build/$jarfile.aligned.jar

rm -r build/$jarfile
ensure_zero mv build/$jarfile.aligned.jar magisk-module/system/framework/$jarfile

echo -e "\e[33mbuilding magisk module...\e[0m"
if [[ -d "dist" ]]; then
  rm -r dist
fi

mkdir dist
cd magisk-module
ensure_zero zip -r ../dist/module.zip *
cd ..

echo -e "\e[32mbuilding success..."
echo -e "module saved at" $(realpath dist/module.zip)
echo -e "now you can flash it to magisk!\e[0m"