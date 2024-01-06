#!/bin/bash /bin/zsh
# Keep Alive Root
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &
