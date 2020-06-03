#!/bin/bash
# Install FastAI2 on Jetpack 4.4. 
# Step 2: Prepare swap file and switch off GUI to maximise available RAM 

sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | sudo tee --append /etc/fstab > /dev/null

sudo systemctl enable multi-user.target
sudo systemctl set-default multi-user.target

chmod +x ~/fastai2_jetson_nano/step3_install_fastai2.sh
chmod +x ~/fastai2_jetson_nano/step3_install_fastai2_background.sh
chmod +x ~/fastai2_jetson_nano/step4_enable_GUI.sh

# Add directories where pip will store local binaries so that .profile will add them to PATH after reboot
mkdir ~/.local
mkdir ~/.local/bin

echo "The system will restart now. When finished, log in and run ./fastai2_jetson_nano/step3_install_fastai2.sh"
read -t 5 a
sudo reboot now
