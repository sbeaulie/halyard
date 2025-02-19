#!/bin/sh

echo '#!/usr/bin/env bash' | sudo tee /usr/local/bin/hal > /dev/null
echo '/opt/halyard/bin/hal "$@"' | sudo tee -a /usr/local/bin/hal > /dev/null

chmod +x /usr/local/bin/hal

if [ -f "/opt/spinnaker/config/halyard-user" ];
then
  HAL_USER=$(cat /opt/spinnaker/config/halyard-user)
else
  HAL_USER=spinnaker
  # Temporarily prevent commands that return non-zero exit codes
  # from causing the post installation to fail.
  set +e
  getent passwd spinnaker > /dev/null
  GETENT_RESULT=$?
  # Reenable checking for non-zero exit codes.
  set -e
  if [ $GETENT_RESULT -ne 0 ]; then
    useradd -s /bin/bash $HAL_USER
  fi
  if [ ! -f "/opt/spinnaker/config/halyard-user" ];
  then
    mkdir -p /opt/spinnaker/config
    chown -R spinnaker:spinnaker /opt/spinnaker
    echo ${HAL_USER} > /opt/spinnaker/config/halyard-user
  fi
fi

install --mode=755 --owner=$HAL_USER --group=$HAL_USER --directory /var/log/spinnaker/halyard

service halyard restart
