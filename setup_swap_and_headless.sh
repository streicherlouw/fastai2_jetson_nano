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
