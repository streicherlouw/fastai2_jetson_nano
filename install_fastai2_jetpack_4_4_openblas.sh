#!/bin/bash
# Install Fastai2 on Nvidia Jetson Nano running Jetpack 4.4
# Authored by Streicher Louw, April 2020, based on previous work by
# Bharat Kunwar https://github.com/brtknr
# and Jeffrey Antony https://github.com/jeffreyantony

# With a fast SD card, this process takes around 12-16 hours.

# Step 1: Flash Jetpack 4.4
# Flash an SD card with Jetpack 4.4 as described on
# https://developer.nvidia.com/embedded/jetpack
# and complete the intitial setup of username and password using a screen and
# keyboard connected directly to the jetson. My jetson did not work reliably
# with a 4K screen. Use an HD screen or TV if you can.

# Step 2: Download the scripts that you will need
# Open a terminal and download the files you will need for this process from github
# with the command "git clone https://github.com/streicherlouw/fastai2_jetson_nano"

# Step 3: Setup swap space and disable the GUI
# Compiling pytorch uses more memory than the jetson nano has. To bridge the gap
# we can add some swap space that will use the SD card as additional memory.
# Swapping to disk is very slow though, so to free to as much memory as we can
# we also need to switch off the Graphical User Interface by tellign the nano to
# stop booting when it reaches runlevel 3, where it presents a text terminal.
# Both of these functions are performed by the script setup_swap_and_headless.sh. To
# run this script, we first needs to mark it as executable, and then run it and
# reboot as follows:
# "chmod +x setup_swap_and_headless.sh"
# "sudo ./setup_swap_and_headless.sh"
# "sudo reboot now"
# The nano should then reboot and present you with a text terminal to log into.

# Step 4: Install dependencies and compile Pytorch and FastAI
# For the next part, you will either need to log into the nano by ssh or the
# the local console terminal. If using ssh, make sure the connection remains open
# for the entire time the script is running. If your terminal quits (for example
# because the computer you are connecting from goes to sleep) the terminal session
# will end and the installation will stop midway.
# To start the installation, we again make the script executable and then run it as
# follows:
# "chmod +x install_fastai2_jetpack_4_4.sh"
# "sudo ./install_fastai2_jetpack_4_4.sh"

# As this script will take many hours to execute, your sudo priveledges will
# time out before the later steps that require sudo priviledges. This first
# bit of code will cache your sudo password to reuse later

echo "Please enter the sudo password"
read -sp 'Password: ' PW

now=`date`
echo "Start Installation of fastai2 on jetson nano at: $now"

# Update the nano's software
echo $PW | sudo -k --stdin apt-get -y update
echo $PW | sudo -k --stdin apt-get -y upgrade

# Create a virtual environment and activate it
echo $PW | sudo -k --stdin apt install -y python3-venv
echo $PW | sudo -k --stdin apt install -y python3-pip
python3 -m venv ~/python-envs/fastai
source ~/python-envs/fastai/bin/activate
pip3 install wheel

# Install MAGMA from source
# Since fastai requires pytorch to be compiled MAGMA, this needs to be intalled first
# The authors of MAGMA does not offer binary builds, so it needs to be compiled from source
now=`date`
echo "Start installation of MAGMA at: $now"
# The default jetpack 4.4 installation does not link libblas.so.3 and liblapack.so.3 to libblas.so and liblapack.so
# to make sure everything links to the same blas libraries, this section makes those links
echo $PW | sudo -k --stdin apt remove -y libblas3
echo $PW | sudo -k --stdin apt remove -y liblapack3
echo $PW | sudo -k --stdin sudo apt install -y libopenblas-dev
echo $PW | sudo -k --stdin sudo apt install -y gfortran
wget http://icl.utk.edu/projectsfiles/magma/downloads/magma-2.5.3.tar.gz
tar -xf magma-2.5.3.tar.gz
# Magma needs a make.inc file to tell it which Nvidia architectures to compile for and where to find the blas libraries
# This file is based on the openblas example in MAGMA, with mior tweaks for the jetson nano architecture (Maxwell) and openblas library location
cp fastai2_jetson_nano/make.inc.jetson.openblas ~/magma-2.5.3/make.inc
cd magma-2.5.3
export OPENBLASDIR=/usr/lib/aarch64-linux-gnu
export CUDADIR=/usr/local/cuda
export PATH=$PATH:/usr/local/cuda-10.2/bin
make
echo $PW | sudo -k --stdin --preserve-env make install prefix=/usr/local/magma
cd ~/

now=`date`
echo "Start installation of various library dependencies at: $now"

# Install dependencies for fastai
echo $PW | sudo -k --stdin apt install -y graphviz

# Install dependencies for pillow
echo $PW | sudo -k --stdin apt-get -y install libjpeg8-dev libpng-dev

# Install dependencies for torchvision
echo $PW | sudo -k --stdin apt-get -y install openmpi-bin

# Install dependencies for matplotlib
echo $PW | sudo -k --stdin apt-get -y install libfreetype6-dev

# Install dependencies for Azure
echo $PW | sudo -k --stdin apt install -y python-cffi
echo $PW | sudo -k --stdin apt install -y libffi-dev
echo $PW | sudo -k --stdin apt install -y libssl-dev

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
echo $PW | sudo -k apt -y install cmake
pip3 install setuptools
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
cd ~/

# Build torchvision from source
now=`date`
echo "Starting installation of torchvision at: $now"
git clone --branch v0.6.0 https://github.com/pytorch/vision torchvision
cd torchvision
python3 setup.py install
cd ~/

# Clone editable installs of fastcore and fastai2 as well as fastai2 course material
now=`date`
echo "Starting installation of fastai at:" $now

git clone https://github.com/fastai/fastcore # install fastcore
cd fastcore
pip3 install -e ".[dev]"
cd ~/

git clone https://github.com/fastai/fastai2 # install fastai and patch augment.py
cd fastai2/
patch -p1 < ~/fastai2_jetson_nano/fastai2_torch_1_5_0.patch
pip3 install -e ".[dev]"
cd ~/

git clone https://github.com/fastai/course-v4 # clone course notebooks
git clone https://github.com/fastai/fastbook # clone course book

# Install tmux: This section is optional, comment out if you do not want to use tmux
# tmux allows you to log out and leave jupyter notebook running
# jetston-stas provides a very attractive way to monitor memory usage
# to use tmux, press command-b followed by 0,2 or 3 to switch between jtop, a terminal and jupyter's output
now=`date`
echo "Starting installation of tmux at: $now"
echo $PW | sudo -k --stdin apt install tmux
echo $PW | sudo -k --stdin -H pip3 install -U jetson-stats
cp ~/fastai2_jetson_nano/start_fastai_tmux.sh start_fastai_tmux.sh
chmod a+x start_fastai_tmux.sh
echo $'set -g terminal-overrides \'xterm*:smcup@:rmcup@\'' >> .tmux.conf

now=`date`
echo "Starting installation of jupyter notebook at: $now"
#Install Jypiter Notebook
wget https://nodejs.org/dist/v12.16.2/node-v12.16.2-linux-arm64.tar.xz
tar -xJf node-v12.16.2-linux-arm64.tar.xz
echo $PW | sudo -k --stdin cp -R node-v12.16.2-linux-arm64/* /usr/local
rm -rf node-v12.16.2-linux-arm64*
pip3 install nbdev
jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install @jupyterlab/statusbar
jupyter lab --generate-config
# Download a small script that sets the virtual environment, divines the IP address, and starts jupyter notebook with the right IP
cp ~/fastai2_jetson_nano/start_fastai_jupyter.sh start_fastai_jupyter.sh
# Starting jpyter using this script will mean your jupyter instance is killed when you log out or your ssh connection drops
# If you want jupyter to work persistently, use the tmux script above
chmod a+x start_fastai_jupyter.sh
echo "As the last step, please choose a jupyter notebook password"
jupyter notebook password

echo "Now restart the jetson nano and run either start_fastai_tmux.sh or start_fastai_jupyter.sh and connect with your browser to http://(your IP):8888/"
