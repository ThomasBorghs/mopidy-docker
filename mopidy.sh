#!/bin/bash

USER_ID=${PUID:-9001}
GROUP_ID=${PGID:-9001}

echo "Starting with UID: $USER_ID, GID: $GROUP_ID"
useradd -u $USER_ID -o -m mopidy
groupmod -g $GROUP_ID mopidy
export HOME=/home/mopidy

# Copy config if it does not already exist
if [ ! -f /home/mopidy/.config/mopidy/mopidy.conf ]; then
    cp /mopidy_default.conf /home/mopidy/.config/mopidy/mopidy.conf
fi

if [ ${APT_PACKAGES:+x} ]; then
    echo "-- INSTALLING APT PACKAGES $APT_PACKAGES --"
    sudo apt-get update
    sudo apt-get install -y $APT_PACKAGES
fi
if  [ ${PIP_PACKAGES:+x} ]; then
    echo "-- INSTALLING PIP PACKAGES $PIP_PACKAGES --"
    pip3 install $PIP_PACKAGES
fi
if [ ${UPDATE:+x} ]; then
    echo "-- UPDATING ALL PACKAGES --"
    sudo apt-get update
    sudo apt-get upgrade -y
    pip3 freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 pip3 install -U # Upgrade all pip packages
fi

exec gosu mopidy mopidy --config /home/mopidy/.config/mopidy/mopidy.conf "$@"