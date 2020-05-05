#!/bin/bash
source ~/python-envs/fastai/bin/activate
#get the ip address for using with jupyter notebook login
ipa=$(hostname -I|cut -f1 -d ' ')
jupyter notebook --ip=$ipa

