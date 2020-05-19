#!/bin/bash

SESSIONNAME="fastai"

TAB3="jupyter"
TAB2="shell"
TAB1="overview"

DEFAULTTAB=$TAB3

#get the ip address for using with jupyter notebook login
ipa=$(hostname -I|cut -f1 -d ' ')

tmux has-session -t $SESSIONNAME &> /dev/null

#if not existing, lets create one
if [ $? != 0 ] 
 then
    #create a new session and name the window(tab) in it using -n
    #detaching is needed as in the last line will attach to it
    tmux new-session -s $SESSIONNAME -n $TAB1 -d

    tmux send-keys -t 0 "sudo jtop" C-m

    #open a second window(tab)
    tmux new-window -t $SESSIONNAME:2 -n $TAB2

    tmux send-keys -t 0 "source ~/python-envs/fastai/bin/activate" C-m

    tmux new-window -t $SESSIONNAME:3 -n $TAB3
    tmux send-keys -t 0 "source ~/python-envs/fastai/bin/activate;cd course-v4/nbs; jupyter notebook --ip=$ipa" C-m
    #tmux send-keys -t 0 "cd course-v4/nbs; jupyter notebook --ip=$ipa" C-m

    #default window you want to see when entering the session
    tmux select-window -t $SESSIONNAME:$DEFAULTTAB
fi

tmux attach -t $SESSIONNAME
