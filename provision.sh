#!/bin/bash

set -e

PROFILE=/home/docker/.bash_profile
PROMPT='\[\e[1;36m\]\h \w \$ \[\e[0m\]'
BIN=/opt/bin

#
# Shell Prompt
#
if [[ ! -f $PROFILE ]]; then
  touch $PROFILE
  chown docker:docker $PROFILE
fi

if grep -q '^export PS1=.*$' $PROFILE; then
  sed -i '/^export PS1=.*$/d' $PROFILE
fi

echo "export PS1=\"${PROMPT}\"" >> $PROFILE

#
# Install Wocker CLI
#
if [[ ! -d $BIN ]]; then
  mkdir $BIN
fi
wget -q -O ${BIN}/wocker https://raw.githubusercontent.com/2012summerain/wocker-cli/master/wocker
chmod +x ${BIN}/wocker

#
# Pull the Wocker image & create the first container
#
docker pull wocker/wocker:latest
ID=$(docker ps -q -a -f name=wocker)
if [ -z "$ID" ]; then
  su -c 'wocker run --name wocker "-v /usr/bin/dumb-init:/dumb-init:ro --entrypoint=/dumb-init 2012summerain/wocker sh -c /usr/bin/supervisord"' docker
else
  su -c 'wocker start wocker' docker
fi
