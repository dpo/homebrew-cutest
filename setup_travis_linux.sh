#!/bin/bash
set -ev

# Install LinuxBrew.
sudo apt-get update
sudo apt-get install build-essential curl git file python-setuptools m4 ruby texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev libgsl0-dev
echo -ne '\n' | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"

# Symlink GCC to avoid installing Homebrew GCC.
gccver=$(gcc -dumpversion |cut -d. -f1,2)
ln -s $(which gcc) $HOME/.linuxbrew/bin/gcc-${gccver}
ln -s $(which g++) $HOME/.linuxbrew/bin/g++-$(g++ -dumpversion |cut -d. -f1,2)

# Ensure GFORTRAN is available.
sudo apt-get -y install gfortran-${gccver}
ln -s $(which gfortran-${gccver}) $HOME/.linuxbrew/bin/gfortran-${gccver}
ln -s $(which gfortran-${gccver}) $HOME/.linuxbrew/bin/gfortran

# Ensure BLAS and LAPACK are available.
sudo apt-get -y install libblas-dev liblapack-dev
