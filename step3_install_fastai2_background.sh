#!/bin/bash
echo "These prompts will only ask once, please take care to type the passwords correctly"
echo "Please enter the sudo password:"
read -sp 'Password: ' PW
echo
echo "Please enter your desired jupyter notebook password:"
read -sp 'Password: ' JPW

cd ~/
nohup ./fastai2_jetson_nano/step3_install_fastai2.sh $PW $JPW &
sleep 2
tail -f ~/nohup.out
