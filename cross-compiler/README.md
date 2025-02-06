# Cross Compiler i686-elf

## Part 1: Run the installation script

```bash
bash cross-compiler.sh
```

## Part 2: Explanation

A **cross compiler** is a compiler capable of building programs for a platform other than the one on which it is running.  
In this case, we want to build a toolchain targeting the 32-bit **i686 architecture** using the ELF format (`i686-elf`). This is particularly useful (and **strongly recommended**) when creating an **operating system or other bare-metal software**, because it ensures the compiler and tools do not depend on the host system’s libraries or headers. Instead, they produce binaries specifically for the i686 architecture without pulling in unwanted dependencies from the host environment.

Below is a step-by-step procedure (inspired by the [OSDev Wiki](https://wiki.osdev.org/GCC_Cross-Compiler)) to install the dependencies, download, and compile a **GCC** cross compiler targeting `i686-elf`.

### Installing Dependencies
```bash
sudo apt-get update
sudo apt-get install -y build-essential bison flex libgmp3-dev libmpc-dev \
                     libmpfr-dev texinfo wget libisl-dev
```

### Retrieve binutils and gcc sources
```bash
mkdir $HOME/opt/cross
mkdir $HOME/src
cd $HOME/src
wget https://ftp.gnu.org/gnu/binutils/binutils-2.40.tar.xz
wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz

tar -xJf binutils-2.40.tar.xz
tar -xJf gcc-13.2.0.tar.xz

rm -rf binutils-2.40.tar.xz gcc-13.2.0.tar.xz
```
### Add the installation prefix to the current shell session's PATH
```bash
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
```

### Build and install binutils
```bash
cd $HOME/src
mkdir build-binutils
cd build-binutils
../binutils-2.40/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install
```
### Build GCC.
```bash
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
```
### Testing
```bash
$HOME/opt/cross/bin/$TARGET-gcc --version
```

### Add to PATH
```bash
export PATH="$HOME/opt/cross/bin:$PATH"
```
