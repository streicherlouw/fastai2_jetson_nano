
#!/bin/bash
# Install FastAI2 on Jetpack 4.4. 
# Step 4: Optional script to re-enable GUI

sudo systemctl enable graphical.target
sudo systemctl set-default graphical.target
echo "The graphical user interface has been re-enabled, the system will restart now."
read -t 5 a
sudo reboot now
