# Install Fastai V2 on an Nvidia Jetson Nano running Jetpack 4.4

The Nvidia jetson nano is a small single board computer pairing a quad-core ARMv8 processor with a 128 core Nvidia Maxwell GPU. Fastai V2 is the latest development version of the fastai deep learning library, that adds function call-backs and GPU accelerated image transforms to fastai V1.

Fastai V2 presents some installation challenges for users of the Nvidia Jetson Nano. The GPU acceleration used by fastai V2 require pytorch to have been compiled with MAGMA support, and the default pytorch wheels provided by Nvidia are not built with MAGMA, as MAGMA itself is not available as a binary, and Nvidia did not want to force everyone wanting to use pytorch on the nano to have to build MAGMA from source before being able to install pytorch. This means that to use fastai V2 on the jetson nano, both MAGMA and pytorch needs to be rebuilt from source on the nano.

With a reasonably fast SD card, following the process below should take about 12-14 hours. It has been desinged to be fully automated, so it can be run overnight. I suggest running the script from an SSH terminal to capture output

# Step 1: Flash Jetpack 4.4
Flash an SD card with Jetpack 4.4 as described on https://developer.nvidia.com/embedded/jetpack and complete the initial setup of username and password using a screen and keyboard connected directly to the jetson. My jetson did not work reliably with a 4K screen. Use an HD screen or TV if you have similar problems.

# Step 2: Download the installation scripts, setup swap space and disable the GUI
Compiling pytorch uses more memory than the 4GB jetson nano has available. To bridge the gap we can add some swap space that will use the SD card as additional memory. Swapping to disk is very slow though, so to free to as much memory as we can we also need to switch off the Graphical User Interface by telling the nano to stop booting when it reaches multi-user text mode. You can enable the GUI again later is you wish, but as you will likely access fastai through jupyter notebook, the memory is better spent on space for you deep learning data. 

Start by opening a text terminal and download this the files you will need for the installation process from this github with the command:
```
git clone https://github.com/streicherlouw/fastai2_jetson_nano
```
Next, execute the script to enable swap space and disable the GUI.
```
sudo sh fastai2_jetson_nano/step2_swap_and_textmode.sh
```
The nano should then reboot and present you with a text terminal to log into.

# Step 3: Install dependencies and compile Pytorch and Fastai
For the next part, you will either need to log into the nano by ssh or the local console terminal. If using ssh, make sure the connection remains open for the entire time the script is running. If your terminal disconnects (for example because the computer you are connecting from goes to sleep) the  session will end and the installation will stop midway.

Once logged in from a reliable connection, start the installation by typing: 
```
./fastai2_jetson_nano/step3_install_fastai2.sh
```
If you are familiar with nohup, I this repository also includes an alternate install script that starts the build in the background so that an interrupted terminal session would not stop the build. Using this method has the added benifit of preserving the build log in a file so that it may be checked later for errors. To start the build in the backround instead, use the command
```
./fastai2_jetson_nano/step3_start_backround.sh
```

