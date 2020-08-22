#!/bin/bash
echo "These prompts will only ask for each password once, please take care when typing"
echo "Please enter the sudo password:"
read -sp 'Password: ' PW
echo
echo "Please enter your desired jupyter notebook password:"
read -sp 'Password: ' JPW
echo
cd ~/
nohup ./fastai2_jetson_nano/step3_install_fastai2_no_virtualenv.sh $PW $JPW &
sleep 2
tail -f ~/nohup.out
