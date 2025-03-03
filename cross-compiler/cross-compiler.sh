# !/usr/bin/env bash
# https://wiki.osdev.org/GCC_Cross-Compiler

RED="\e[31m"
GREEN="\e[32m"
ENDCOLOR="\e[0m"

echo -e "${GREEN}==> Updating APT repositories...${ENDCOLOR}"
sudo apt-get update

echo "${GREEN}==> Installation of dependencies...${ENDCOLOR}"
if ! sudo apt-get install -y \
       build-essential bison flex libgmp3-dev libmpc-dev \
       libmpfr-dev texinfo wget libisl-dev; then
  echo "${RED}Failed to install dependecies.${ENDCOLOR}" >&2
  exit 1
fi

echo "${GREEN}==> Creating the ~/src and ~/ directories...${ENDCOLOR}"
mkdir -p $HOME/opt/cross
mkdir -p "$HOME/src"
cd "$HOME/src"

echo "${GREEN}==> Downloading and extracting Binutils...${ENDCOLOR}"
if wget https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.xz; then
  tar -xf binutils-2.40.tar.xz
  rm -f binutils-2.40.tar.xz
else
  echo "${RED}Failed to download Binutils.${ENDCOLOR}" >&2
fi

echo "${GREEN}==> Downloading and extracting GCC...${ENDCOLOR}"
if wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz; then
  tar -xf gcc-13.2.0.tar.xz
  rm -f gcc-13.2.0.tar.xz
else
  echo "${RED}Failed to download GCC.${ENDCOLOR}" >&2
fi

echo "${GREEN}===> Add the installation prefix to the PATH...${ENDCOLOR}"

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

echo "===> Compile the binutils..."
mkdir build-binutils
cd build-binutils
../binutils-2.40/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install

cd $HOME/src

# The $PREFIX/bin dir _must_ be in the PATH. We did that above. 
which -- $TARGET-as || echo "$TARGET-as is not in the PATH"

mkdir build-gcc
cd build-gcc
../gcc-13.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls \
    --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx
make all-gcc
make all-target-libgcc
make all-target-libstdc++-v3
make install-gcc
make install-target-libgcc
make install-target-libstdc++-v3

echo 'export PATH="$HOME/opt/cross/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc