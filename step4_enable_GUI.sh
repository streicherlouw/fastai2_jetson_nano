#!/bin/bash
sudo systemctl enable graphical.target
sudo systemctl set-default graphical.target
echo "The graphical user interface has been re-enabled, the system will restart now."
read -t 5 a
sudo reboot now
