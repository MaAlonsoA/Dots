#!/bin/bash

PATH=/home/$1/.config

cp -r ./bspwm ./kitty ./lsd ./picom ./polybar ./rofi ./sxhkd $PATH
cp ./zshrc /home/$1/.zshrc
cp ./p10k.zsh /home/$1/.p10k.zsh
cp ./p10k.zsh.root /root/.p10k.zsh
cp ./fonts/fonts /usr/local/share/fonts
