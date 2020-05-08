# Install Fastai V2 on an Nvidia Jetson Nano running Jetpack 4.4

The Nvidia jetson nano is a small single board computer pairing a quad-core ARMv8 processor with a 128 core Nvidia Maxwell GPU. Fastai V2 is the latest development version of the fastai deep learning library, that adds function call-backs and GPU accelerated image transforms to fastai V1.

Fastai V2 presents some unique installation challenges for users of the Nvidia Jetson Nano. The GPU acceleration used by fastai V2 require pytorch to have been compiled with MAGMA support, and the default pytorch wheels provided by Nvidia are not built with MAGMA. Dusty_nv from Nvidia explains the reasoning behind this choice [here](https://forums.developer.nvidia.com/t/pytorch-for-jetson-nano-version-1-5-0-now-available/72048/201). This means that to use fastai V2 on the jetson nano, both MAGMA and pytorch needs to be rebuilt from source on the nano.

With a reasonably fast SD card, following the process should take about 12-14 hours. The build process is fully scripted, so it can be run unattended overnight. This work builds on the installation instructions for fastai V1 for the jetson nano written by [Bharat Kunwar](https://github.com/brtknr/fastai-jetson-nano).

# Step 1: Flash Jetpack 4.4
Flash an SD card with Jetpack 4.4 as described on https://developer.nvidia.com/embedded/jetpack and complete the initial setup of username and password using a screen and keyboard connected directly to the jetson. My jetson did not work reliably with a 4K screen. Use an HD screen or TV if you have similar problems.

# Step 2: Setup swap space and disable the GUI
Compiling pytorch uses more memory than the 4GB jetson nano has available. To bridge the gap we can add some swap space that will use the SD card as additional memory. Swapping to disk is very slow though, so to free to as much memory as we can we also need to switch off the Graphical User Interface by telling the nano to stop booting when it reaches multi-user text mode. You can enable the GUI again later is you wish, but as you will likely access fastai through jupyter notebook, the memory is better spent on space for you deep learning data. 

Start by opening a text terminal and download this the files you will need for the installation process from this github with the command:
```
git clone https://github.com/streicherlouw/fastai2_jetson_nano
```
Next, execute the script to enable swap space and disable the GUI.
```
chmod +x fastai2_jetson_nano/step2_swap_and_textmode.sh
./fastai2_jetson_nano/step2_swap_and_textmode.sh
```
The nano should then reboot and present you with a text terminal to log into.

# Step 3: Install dependencies and compile
For the next part, you will either need to log into the nano by ssh or the local console terminal. If using ssh, make sure the connection remains open for the entire time the script is running. If your terminal disconnects (for example because the computer you are connecting from goes to sleep) the session will end and the installation will stop midway.

Once logged in from a reliable connection, start the installation by typing: 
```
./fastai2_jetson_nano/step3_install_fastai2.sh
```
If you are familiar with nohup, this repository also includes an alternate install script that starts the build in the background so that an interrupted terminal session would not stop the build. Using this method has the added benifit of preserving the build log in a file so that it may be checked later for errors. To start the build in the backround instead, use the command:
```
./fastai2_jetson_nano/step3_start_background_build.sh
```
# Step 4: Batch responsibly
The jetson nano has only 4GB of RAM shared between the operating system and the GPU. When training on large datasets, for example the pets dataset in [05_pet_breeds.ipynb](https://github.com/fastai/course-v4/blob/master/nbs/05_pet_breeds.ipynb), make sure to set the batch size to 16 or 32 when you call the dataloader as follows:
```
dls = pets.dataloaders(path/"images",bs=32)
```
