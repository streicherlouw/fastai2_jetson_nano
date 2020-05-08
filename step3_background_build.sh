#!/bin/bash
echo "Please enter the sudo password"
read -sp 'Password: ' PW
nohup sh ~/fastai2_jetson_nano/step3_install_fastai2.sh $PW & 
tail -f nohup.out
