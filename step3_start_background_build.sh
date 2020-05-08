#!/bin/bash
echo "Please enter the sudo password"
read -sp 'Password: ' PW
cd ~/
nohup ./fastai2_jetson_nano/step3_install_fastai2.sh $PW & 
tail -f nohup.out
