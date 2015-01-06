#!/bin/bash
set -e

# Install LinuxBrew.
sudo apt-get update
sudo apt-get install build-essential curl git m4 ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev
echo -ne '\n' | ruby -e "$(wget -O- https://raw.github.com/Homebrew/linuxbrew/go/install)"

# Symlink GCC to avoid installing Homebrew GCC.
ln -s $(which gcc) $HOME/.linuxbrew/bin/gcc-$(gcc -dumpversion |cut -d. -f1,2)
ln -s $(which g++) $HOME/.linuxbrew/bin/g++-$(g++ -dumpversion |cut -d. -f1,2)
ln -s $(which gfortran) $HOME/.linuxbrew/bin/gfortran-$(gfortran -dumpversion |cut -d. -f1,2)

# Ensure BLAS and LAPACK are available.
sudo apt-get -y install libblas-dev liblapack-dev