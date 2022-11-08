#!/bin/bash

target_ip=$(cat ~/.config/polybar/scripts/target) 
if [ $target_ip ]; then
    echo "%{F#BF616A} %{F#ffffff}$target_ip%{u-}"
else
    echo "%{F#A3BE8C}%{F#ffffff} No target"
fi
