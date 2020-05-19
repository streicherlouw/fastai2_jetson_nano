#!/bin/bash
echo "Please enter the sudo password"
read -sp 'Password: ' PW
cd ~/
nohup ./fastai2_jetson_nano/step3_install_fastai2.sh $PW &
sleep 1
tail -f ~/nohup.out
