#!/bin/sh
 
IFACE=$(/usr/sbin/ifconfig | grep tun0 | awk '{print $1}' | tr -d ':')
 
if [ "$IFACE" = "tun0" ]; then
   echo "%{F#A3BE8C} %{F#ffffff}$(/usr/sbin/ifconfig tun0 | grep "inet " | awk '{print $2}')${u-}"
else
   echo "%{F#5E81AC} %{F#ffffff}%{F#E5E9F0}Disconnected%{F#ffffff}"
fi
