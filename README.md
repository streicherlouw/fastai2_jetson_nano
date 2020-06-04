# Install Fastai V2 on an Nvidia Jetson Nano running Jetpack 4.4

The Nvidia jetson nano is a small single board computer pairing a quad-core ARMv8 processor with a 128 core Nvidia Maxwell GPU. Fastai V2 is the latest development version of the fastai deep learning library, that adds function call-backs and GPU accelerated image transforms to fastai V1.

<img src="https://devblogs.nvidia.com/wp-content/uploads/2019/03/Jetson-Nano_3QTR-Front_Left-1920px-1024x776.png" width="400">

Fastai V2 presents some unique installation challenges for users of the Nvidia Jetson Nano. The GPU acceleration used by fastai V2 require pytorch to have been compiled with MAGMA support, and the default pytorch wheels provided by Nvidia are not built with MAGMA. Dusty_nv from Nvidia explains the reasoning behind this choice [here](https://forums.developer.nvidia.com/t/pytorch-for-jetson-nano-version-1-5-0-now-available/72048/201). This means that to use fastai V2 on the jetson nano, both MAGMA and pytorch needs to be rebuilt from source on the nano.

With a reasonably fast SD card, following the process below should take about 12-14 hours. The build process is fully scripted, so it can be run unattended overnight. As compiling pytorch will utilise the nano's ARM cores to their limit, the nano will generate a significant amount of heat during the installation process. If you have a fan for your nano, you may want to fit it before starting the installation process, even though this is not technically necessary according to the [testing performed by cnx-software](https://www.cnx-software.com/2019/12/09/testing-nvidia-jetson-nano-developer-kit-with-and-without-fan/).  This work builds on the installation instructions for fastai V1 for the jetson nano written by [Bharat Kunwar](https://github.com/brtknr/fastai-jetson-nano). 

# Step 1: Flash Jetpack 4.4
Flash an SD card with Jetpack 4.4 as described on https://developer.nvidia.com/embedded/jetpack and complete the initial setup of username and password using a screen and keyboard connected directly to the jetson. For initial configuration, an HD screen is known to work better than a 4K screen.

# Step 2: Setup swap space and disable the GUI
Compiling pytorch uses more memory than the 4GB jetson nano has available. To make compilation possible, we need to add some swap space that will use a large file on the SD card as a form of temporary RAM. Swapping to disk is very slow though, so to free as much memory as we can we also need to switch off the Graphical User Interface by telling the nano to stop booting when it reaches multi-user text mode during start-up. You can re-enable the GUI again later if you wish (using the script step4_enable_GUI.sh), but as you will likely access fastai through jupyter notebook from another computer, it may be advantageous to simply leave the GUI switched off, making the additional RAM available for your deep learning data instead. 

To setup the swap file and temporarily disable the GUI, start by opening a text terminal and download the files you will need for the installation process from this github with the command:
```
git clone https://github.com/streicherlouw/fastai2_jetson_nano
```
Alternatively, there is an experimental build that does not use a virtual environement available. This build is under active development, and may not build successfully at all times. The experiemntal build can be cloned with:
```
git clone --branch no_virtual_environment https://github.com/streicherlouw/fastai2_jetson_nano
```
Next, execute the script to enable swap space and disable the GUI.
```
chmod +x fastai2_jetson_nano/step2_swap_and_textmode.sh
./fastai2_jetson_nano/step2_swap_and_textmode.sh
```
The nano should now reboot and present you with a text terminal to log into.

# Step 3: Install dependencies and compile
For the next part, you will either need to login to the nano by using ssh or the local console terminal. If using ssh, make sure the connection remains open for the entire time (12 to 16 hours) that the script is running. If your terminal disconnects (for example because the computer you are connecting from goes to sleep) the session will end and the installation will stop midway.

Once logged in from a reliable connection, start the installation by typing: 
```
./fastai2_jetson_nano/step3_install_fastai2.sh
```
If you are familiar with nohup, this repository also includes an alternate install script that starts the installation process in the background so that an interrupted terminal session would not stop the build. Using this method also has the added benefit of preserving the build log in a file so that it may be reviewed later. To start the installation process in the background, use the following command instead of the one above:
```
./fastai2_jetson_nano/step3_install_fastai2_background.sh
```
# Step 4: Start jupyter notebook
This installation script creates a virtual environment called "fastai" using the python's venv function. This means that you will need to activate the virtual environment before using fastai in either jupyter notebook or python. 

For convenience, the installation process places two start-up scripts in the user's home directory that automatically activates the virtual environment before starting jupyter notebook with the jetson nano's IP address.

To start the jypyter notebook server in the terminal that you are logged into type the command below. This script will run jupyter notebook for as long as the terminal session remains open, but exit when the terminal session closes:
```
./start_fastai_jupyter.sh
```
If you would like jupyter notebook to continue running after you log out, you can use tmux to host a virtual terminal session. The setup of tmux included in this package (based on [Jeffrey Antony's](https://github.com/jeffreyantony) [tmux repository](https://github.com/jeffreyantony/tmux-fastai/blob/master/tmux-fastai.sh)) creates three terminal sessions: Session 0 waiting for the sudo password to start [jtop (an attractive resource manager for the jetson nano, seen below)](https://github.com/rbonghi/jetson_stats), Session 2 containing a Linux terminal with the "fastai" virtual environment activated, and Session 3 running jupyter notebook. To switch between sessions in tmux, press Control-b followed by 0,2 or 3. Control-b followed by x closes a session.

<img src="https://raw.githubusercontent.com/wiki/rbonghi/jetson_stats/images/jtop.gif" width="400">

Start jupyter notebook in tmux with the command:

```
./start_fastai_jupyter_tmux.sh
```
If you are not using the start-up scripts above, for example if you want to run a fastai python script from the command line, you can manually activate the "fastai" virtual environment with the following command:
```
source ~/python-envs/fastai/bin/activate
```
If you do not intend to work with large datasets in fastai, you may also also re-enable the graphical user interface with the command:
```
./fastai2_jetson_nano/step4_enable_GUI.sh
```
# Step 5: Batch responsibly
The jetson nano has only 4GB of RAM shared between the operating system and the GPU. When training on large datasets, for example the pets dataset in [05_pet_breeds.ipynb](https://github.com/fastai/course-v4/blob/master/nbs/05_pet_breeds.ipynb), make sure to set the batch size to 16 or 32 when you call the dataloader as follows:
```
dls = pets.dataloaders(path/"images",bs=16)
```
