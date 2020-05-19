#!/bin/bash
# Install Fastai2 on Nvidia Jetson Nano running Jetpack 4.4
# Authored by Streicher Louw, April 2020, based on previous work by
# Bharat Kunwar https://github.com/brtknr (installation of fastai) 
# and Jeffrey Antony https://github.com/jeffreyantony (use of TMUX)

# With a fast SD card, this process takes around 12-16 hours.

# As this script will take many hours to execute, the script first needs to
# cache your sudo credentials if they are not supplied on the command line

if [ "$1" != "" ]; then
  PW=$1
else
  echo "Please enter the sudo password"
  read -sp 'Password: ' PW
fi

now=`date`
echo "Start Installation of fastai2 on jetson nano at: $now"

# Update the nano's software
echo $PW | sudo -k --stdin apt -y update
echo $PW | sudo -k --stdin apt -y upgrade
echo $PW | sudo -k --stdin apt -y autoremove

echo $PW | sudo -k --stdin apt install -y python3-pip

# Create a virtual environment and activate it
echo $PW | sudo -k --stdin apt install -y python3-venv 
cd ~/
python3 -m venv ~/python-envs/fastai
source ~/python-envs/fastai/bin/activate

pip3 install wheel
pip3 install setuptools

# Install MAGMA from source
# Since fastai requires pytorch to be compiled MAGMA, MAGMA needs to be installed first
# The authors of MAGMA does not offer binary builds, so it needs to be compiled from source
now=`date`
echo "Start installation of MAGMA at: $now"
echo $PW | sudo -k --stdin apt install -y libopenblas-dev
echo $PW | sudo -k --stdin apt install -y gfortran
echo $PW | sudo -k --stdin apt install -y cmake
wget http://icl.utk.edu/projectsfiles/magma/downloads/magma-2.5.3.tar.gz
tar -xf magma-2.5.3.tar.gz
# Magma needs a make.inc file to tell it which Nvidia architectures to compile for and where to find the blas libraries
cp ~/fastai2_jetson_nano/make.inc.openblas ~/magma-2.5.3/make.inc 
cd ~/magma-2.5.3
export GPU_TARGET=Maxwell # Jetson Nano Has a Maxwell GPU
export OPENBLASDIR=/usr/lib/aarch64-linux-gnu/openblas
export CUDADIR=/usr/local/cuda
export PATH=$PATH:/usr/local/cuda-10.2/bin
make
echo $PW | sudo -k --stdin --preserve-env make install prefix=/usr/local/magma

# For some reason, MAGMA needs a first run to configure itself or openblas correctly.
# The first run takes a long time to get started, but after it has run through once,
# it executes without delay on subsequent occasions.
now=`date`
echo "Start first run of MAGMA at: $now"
cd ~/magma-2.5.3/testing
python2 run_tests.py --precision s --small --ngpu 1
cd ~/

now=`date`
echo "Start installation of various library dependencies with apt at: $now"

# Install dependencies for kiwisolver
echo $PW | sudo -k --stdin apt install -y python3-dev

# Install dependencies for fastai
echo $PW | sudo -k --stdin apt install -y graphviz

# Install dependencies for pillow
echo $PW | sudo -k --stdin apt-get -y install libjpeg8-dev libpng-dev

# Install dependencies for torch & torchvision
echo $PW | sudo -k --stdin apt-get -y install openmpi-bin libjpeg-dev zlib1g-dev

# Install dependencies for matplotlib
echo $PW | sudo -k --stdin apt-get -y install libfreetype6-dev

# Install dependencies for Azure
echo $PW | sudo -k --stdin apt install -y python-cffi
echo $PW | sudo -k --stdin apt install -y libffi-dev
echo $PW | sudo -k --stdin apt install -y libssl-dev

now=`date`
echo "Start installation of various library dependencies with pip at: $now"

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
pip3 install graphviz
pip3 install ipykernel
pip3 install azure-cognitiveservices-search-imagesearch
pip3 install pillow
pip3 install numpy
pip3 install scipy
pip3 install scikit-learn
pip3 install pyyaml
pip3 install future
BLIS_ARCH="generic" pip3 install spacy --no-binary blis
pip3 install matplotlib

# Install dependencies for py torch build
pip3 install scikit-build
pip3 install ninja

# Build torch from source
now=`date`
echo "Start installation of pytorch at: $now"
git clone --recursive https://github.com/pytorch/pytorch
cd ~/pytorch
wget https://gist.githubusercontent.com/dusty-nv/ce51796085178e1f38e3c6a1663a93a1/raw/44dc4b13095e6eb165f268e3c163f46a4a11110d/pytorch-diff-jetpack-4.4.patch -O pytorch-diff-jetpack-4.4.patch
patch -p1 < pytorch-diff-jetpack-4.4.patch
pip3 install -r requirements.txt
export USE_NCCL=0
export USE_DISTRIBUTED=0
export USE_QNNPACK=0
export USE_PYTORCH_QNNPACK=0
export TORCH_CUDA_ARCH_LIST="5.3"
export PYTORCH_BUILD_VERSION=1.5.0
export PYTORCH_BUILD_NUMBER=1
export BLAS=OpenBLAS
python3 setup.py bdist_wheel
cd ~/pytorch/dist
pip3 install torch-1.5.0-cp36-cp36m-linux_aarch64.whl
cd ~/

# Build torchvision from source
now=`date`
echo "Starting installation of torchvision at: $now"
git clone --branch v0.6.0 https://github.com/pytorch/vision torchvision
cd ~/torchvision
python3 setup.py install
cd ~/

# Clone editable installs of fastcore and fastai2 as well as fastai2 course material
now=`date`
echo "Starting installation of fastai at:" $now

git clone https://github.com/fastai/fastcore # install fastcore
cd ~/fastcore
pip3 install -e ".[dev]"
cd ~/

pip3 install fastprogress

git clone https://github.com/fastai/fastai2 # install fastai and patch augment.py
cd ~/fastai2
patch -p1 < ~/fastai2_jetson_nano/fastai2_torch_1_5_0.patch
pip3 install -e ".[dev]"
cd ~/

git clone https://github.com/fastai/course-v4 # clone course notebooks
git clone https://github.com/fastai/fastbook # clone course book

#Install Jypiter Notebook
now=`date`
echo "Starting installation of jupyter notebook at: $now"
wget https://nodejs.org/dist/v12.16.2/node-v12.16.2-linux-arm64.tar.xz
tar -xJf node-v12.16.2-linux-arm64.tar.xz
echo $PW | sudo -k --stdin cp -R node-v12.16.2-linux-arm64/* /usr/local
rm -rf node-v12.16.2-linux-arm64*
pip3 install nbdev
jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install @jupyterlab/statusbar
jupyter lab --generate-config

# Download a small script that divines the IP address, and starts jupyter notebook with the right IP
cp ~/fastai2_jetson_nano/start_fastai_jupyter.sh start_fastai_jupyter.sh
chmod a+x start_fastai_jupyter.sh

# Starting jpyter using the script above will mean your jupyter instance is killed when you log out or your ssh connection drops
# If you want jupyter to work persistently, use the tmux script below

# Install tmux: This section is optional, comment out if you do not want to use tmux
# tmux allows you to log out and leave jupyter notebook running and jetston-stas provides a very attractive way to monitor memory usage
# to use tmux, press command-b followed by 0,2 or 3 to switch between jtop, a terminal and jupyter's output
now=`date`
echo "Starting installation of tmux at: $now"
echo $PW | sudo -k --stdin apt install tmux
echo $PW | sudo -k --stdin -H pip3 install -U jetson-stats
cp ~/fastai2_jetson_nano/start_fastai_tmux.sh start_fastai_tmux.sh
chmod a+x start_fastai_tmux.sh
echo $'set -g terminal-overrides \'xterm*:smcup@:rmcup@\'' >> .tmux.conf # sets up same mouse scolling in tmux

echo "As the last step, please choose a jupyter notebook password"
jupyter notebook password

echo "Now restart the jetson nano, run either ./start_fastai_tmux.sh or ./start_fastai_jupyter.sh and connect with your browser to http://(your IP):8888/"
