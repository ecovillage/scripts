#!/bin/bash

# Copyright Felix Wolfsteller 2017

# Licensed under the GPLv3+

# Configures apt to use a apt-cacher-ng instance.

# Exit on errors
set -euo pipefail

#Acquire::http { Proxy "http://192.168.0.105:3142"; };
#Acquire::https { Proxy "https://"; };
PROXY_SETTINGS=<<END
END
PROXY_SETTINGS=$(cat <<'END_HEREDOC'
Acquire::http { Proxy \\"http://192.168.0.105:3142\\"; };
Acquire::https { Proxy \\"https://\\"; };
END_HEREDOC
)
echo "$PROXY_SETTINGS"

is_proxy_set() {
  grep "192.168.0.105" /etc/apt/apt.conf.d/01proxy
}

maybe_set_proxy() {
  zenity --question --text "Ubuntu Sieben Linden Beschleunigung aktivieren?"
  [ "$?" -eq 0 ] && gksudo "bash -c 'echo \\\"$PROXY_SETTINGS\\\" >> /etc/apt/apt.conf.d/01proxy'"
}

maybe_unset_proxy() {
  zenity --question --text "Ubuntu Sieben Linden Beschleunigung deaktivieren?"
  [ "$?" -eq 0 ] && gksudo "bash -c 'echo \"\" > /etc/apt/apt.conf.d/01proxy'"
}

if is_proxy_set
  then
    #zenity --info --text "Already set"
    maybe_unset_proxy
  else
    #zenity --info --text "Not yet set"
    maybe_set_proxy
fi

exit 0
