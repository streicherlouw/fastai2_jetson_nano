#!/bin/bash
# Install Fastai2 on Nvidia Jetson Nano running Jetpack 4.4
# Authored by Streicher Louw, April 2020, based on previous work by
# Bharat Kunwar https://github.com/brtknr
# and Jeffrey Antony https://github.com/jeffreyantony

# Download this file to your jetson with the command
# "wget https://raw.githubusercontent.com/streicherlouw/fastai2_jetson_nano/master/install_fastai2_jetpack_4_4.sh -O install_fastai2_jetpack_4_4.sh"
# then run "chmod a+x install_fastai2_jetpack_4_4.sh"
# and start the install with "sudo ./install_fastai2_jetpack_4_4.sh"
# Starting the script with sudo is iportant as it will let you type
# the password once and let it run untill completed.
# On a fast SD card, this process takes around 12-16 hours

now=`date`
echo "Start Installation of fastai2 on jetson nano at: $now"

# Pytorch build will fail without a large swap file, so set that up first
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | sudo tee --append /etc/fstab > /dev/null

# Update the nano's software
sudo apt-get -y update
sudo apt-get -y upgrade

# Create a virtual environment and activate it
sudo apt install -y python3-venv
sudo apt install -y python3-pip
sudo -H pip3 install -U jetson-stats
python3 -m venv ~/python-envs/fastai
source ~/python-envs/fastai/bin/activate
pip3 install wheel

# Install MAGMA from source
# Since fastai requires pytorch to be compiled MAGMA, this needs to be intalled first
# The authors of MAGMA does not offer binary builds, so it needs to be compiled from source
now=`date`
echo "Start installation of MAGMA at: $now"
sudo apt-get -y install gfortran
# The default jetpack 4.4 installation does not link libblas.so.3 and liblapack.so.3 to libblas.so and liblapack.so
# to make sure everything links to the same blas libraries, this section makes those links
sudo ln -s /usr/lib/aarch64-linux-gnu/libblas.so.3 /usr/lib/aarch64-linux-gnu/libblas.so
sudo ln -s /usr/lib/aarch64-linux-gnu/liblapack.so.3 /usr/lib/aarch64-linux-gnu/liblapack.so
wget http://icl.utk.edu/projectsfiles/magma/downloads/magma-2.5.3.tar.gz
tar -xf magma-2.5.3.tar.gz
cd magma-2.5.3
# Magma needs a make.inc file to tell it which Nvidia architectures to compile for and where to find the blas libraries
# This file is based on the openblas example, but includes lapack as well as the default blas and lapack libraries in jetpack are separate
wget https://raw.githubusercontent.com/streicherlouw/fastai2_jetson_nano/master/make.inc -O make.inc
export OPENBLASDIR=/usr/lib/aarch64-linux-gnu
export CUDADIR=/usr/local/cuda
export PATH=$PATH:/usr/local/cuda-10.2/bin
export PATH=$PATH:/usr/lib/aarch64-linux-gnu/
make
sudo --preserve-env make install prefix=/usr/local/magma
cd..

now=`date`
echo "Start installation of various library dependencies at: $now"

# Install dependencies for fastai
sudo apt install graphviz

# Install dependencies for pillow
sudo apt-get -y install libjpeg8-dev libpng-dev

# Install dependencies for torchvision
sudo apt-get -y install openmpi-bin

# Install dependencies for matplotlib
sudo apt-get -y install libfreetype6-dev

# Install dependencies for Azure
sudo apt install -y python-cffi
sudo apt install -y libffi-dev
sudo apt install -y libssl-dev

# Install dependencies for scipy and scikit-learn, torch, torchvision, jupyter notebook and fastai
pip3 install cython
pip3 install kiwisolver
pip3 install freetype-py
pip3 install pypng
pip3 install dataclasses bottleneck
pip3 install jupyter jupyterlab
pip3 install pynvx
pip3 install pandas
pip3 install fire
pip3 install fastcore
pip3 install fastprogress
pip3 install graphviz
pip3 install ipykernel
pip3 install azure-cognitiveservices-search-imagesearch
pip3 install pillow
pip3 install numpy
pip3 install scikit-learn
pip3 install pyyaml
BLIS_ARCH="generic" pip3 install spacy
pip3 install matplotlib
pip3 install scipy

# Install dependencies for py torch build
sudo apt-get install cmake
pip3 install -U setuptools
pip3 install scikit-build
pip3 install ninja

# Build torch from source
now=`date`
echo "Start installation of pytorch at: $now"
git clone --recursive https://github.com/pytorch/pytorch
cd pytorch
wget https://gist.githubusercontent.com/dusty-nv/ce51796085178e1f38e3c6a1663a93a1/raw/44dc4b13095e6eb165f268e3c163f46a4a11110d/pytorch-diff-jetpack-4.4.patch -O pytorch-diff-jetpack-4.4.patch
patch -p1 < pytorch-diff-jetpack-4.4.patch
pip3 install -r requirements.txt
export USE_NCCL=0
export USE_DISTRIBUTED=0                # skip setting this if you want to enable OpenMPI backend
export USE_QNNPACK=0
export USE_PYTORCH_QNNPACK=0
export TORCH_CUDA_ARCH_LIST="5.3"
export PYTORCH_BUILD_VERSION=1.5.0
export PYTORCH_BUILD_NUMBER=1
python3 setup.py bdist_wheel
pip3 install dist/torch-1.5.0-cp36-cp36m-linux_aarch64.whl
cd..

# Build torchvision from source
now=`date`
echo "Starting installation of torchvision at: $now"
git clone --branch v0.6.0 https://github.com/pytorch/vision torchvision
cd torchvision
python3 setup.py install
cd ..

# Clone editable installs of fastcore and fastai2 as well as fastai2 course material
now=`date`
echo "Starting installation of fastai at:" $now

git clone https://github.com/fastai/fastcore # install fastcore
cd fastcore
pip install -e ".[dev]"
cd ..

git clone https://github.com/fastai/fastai2 # install fastai and patch augment.py
cd fastai2/
wget https://raw.githubusercontent.com/streicherlouw/fastai2_jetson_nano/master/augment.py -O ~/fastai2/fastai2/vision/augment.py
pip install -e ".[dev]"
cd ..

git clone https://github.com/fastai/course-v4 # clone course notebooks
git clone https://github.com/fastai/fastbook # clone course book

# Install tmux: This section is optional, comment out if you do not want to use tmux
# tmux allows you to log out and leave jupyter notebook running
# jetston-stas provides a very attractive way to monitor memory usage
# to use tmux, press command-b followed by 0,2 or 3 to switch between jtop, a terminal and jupyter's output
now=`date`
echo "Starting installation of tmux at: $now"
sudo apt install tmux
sudo -H pip3 install -U jetson-stats
wget https://raw.githubusercontent.com/streicherlouw/fastai2_jetson_nano/master/start_fastai_tmux.sh - O start_fastai_tmux.sh
chmod a+x start_fastai_tmux.sh
echo $'set -g terminal-overrides \'xterm*:smcup@:rmcup@\'' >> .tmux.conf

#Set max runlevel to 3 to prevent graphical environment from starting to conserve memory
sudo systemctl enable multi-user.target
sudo systemctl set-default multi-user.target

now=`date`
echo "Starting installation of jupyter notebook at: $now"
#Install Jypiter Notebook
wget https://nodejs.org/dist/v12.16.2/node-v12.16.2-linux-arm64.tar.xz
tar -xJf node-v12.16.2-linux-arm64.tar.xz
cp -R node-v12.16.2-linux-arm64/* ~/python-envs/fastai/bin
rm -rf node-v12.16.2-linux-arm64*
pip3 install nbdev
jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install @jupyterlab/statusbar
jupyter lab --generate-config
# Download a small script that sets the virtual environment, divines the IP address, and starts jupyter notebook with the right IP
wget https://raw.githubusercontent.com/streicherlouw/fastai2_jetson_nano/master/start_fastai_jupyter.sh -O start_fastai_jupyter.sh
# Starting jpyter using this script will mean your jupyter instance is killed when you log out or your ssh connection drops
# If you want jupyter to worh persistently, use the tmux script above
chmod a+x start_fastai_jupyter.sh
echo "As the last step, please choose a jupyter notebook password"
jupyter notebook password

echo "Now restart the jetson nano and run either start_fastai_tmux.sh or start_fastai_jupyter.sh and connect with your browser to http://(your IP):8888/"
