#!/bin/sh

echo "%{F#5E81AC} %{F#ffffff}$(/usr/sbin/ifconfig eth0 | grep "inet " | awk '{print $2}')%{u-}"

