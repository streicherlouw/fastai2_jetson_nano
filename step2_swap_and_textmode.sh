#!/bin/bash
# FasiAI2 on Jetpack 4.4

#!/bin/bash
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile swap swap defaults 0 0" | sudo tee --append /etc/fstab > /dev/null

sudo systemctl enable multi-user.target
sudo systemctl set-default multi-user.target

chmod +x ~/fastai2_jetson_nano/step3_install_fastai2.sh
chmod +x ~/fastai2_jetson_nano/step3_install_fastai2_background.sh

echo "The system will restart now. When finished, log in and run ./fastai2_jetson_nano/step3_install_fastai2.sh"
read -t 5 a
sudo reboot now
