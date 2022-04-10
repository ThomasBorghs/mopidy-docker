#!/bin/bash

USER_ID=${LOCAL_UID:-9001}
GROUP_ID=${LOCAL_GID:-9001}

echo "Starting with UID: $USER_ID, GID: $GROUP_ID"
useradd -u $USER_ID -o -m user
groupmod -g $GROUP_ID user
export HOME=/home/user

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

set -- /usr/sbin/gosu user "$@"
exec mopidy --config /home/mopidy/.config/mopidy/mopidy.conf "$@"