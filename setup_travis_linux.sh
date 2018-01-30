#!/bin/bash
set -ev

# Install LinuxBrew.
sudo apt-get update
sudo apt-get install build-essential curl git file python-setuptools m4 texinfo libbz2-dev libcurl4-openssl-dev libexpat-dev libncurses-dev zlib1g-dev libgsl0-dev

HOME=/home/linuxbrew  # install linuxbrew here so we can install the glibc bottle
sudo mkdir $HOME
sudo chown "$USER:" $HOME
LINUXBREW=$HOME/.linuxbrew
git clone https://github.com/Linuxbrew/brew $LINUXBREW

# Ensure BLAS and LAPACK are available.
sudo apt-get -y install libblas-dev liblapack-dev
