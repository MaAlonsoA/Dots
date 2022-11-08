#!/bin/bash
 
target_ip=$(cat ~/.config/polybar/scripts/target | awk '{print $1}')
target_name=$(cat ~/.config/polybar/scripts/target| awk '{print $2}')
 
if [ $target_ip ] && [ $target_name ]; then
    echo "%{F#BF616A} %{F#ffffff}$target_ip%{u-} - $target_name"
else
    echo "%{F#A3BE8C}%{F#ffffff} No target"
fi
