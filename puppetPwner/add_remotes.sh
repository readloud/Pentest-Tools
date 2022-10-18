#!/bin/zsh

if [ -z "$SUDO_COMMAND" ]
  then
    echo -e "Only root can run this script.\nRelaunching script with sudo.\n"
    sudo -E $0 $*
    exit 0
fi

# Get the current git repo plus .git (eg. drupal-project.git)
repository=$(basename $(git remote get-url origin))
# Declaring associative array of known repos
declare -A gitrepos=( [noel]=nchiasson-dgi [morgan]=morgandawe [chris]=chrismacdonaldw [jordan]=jordandukart [alex]=alexander-cairns [jojo]=jojoves [adam]=adam-vessey )

# Set contributor if passed, otherwise default to me.
if [[ -z ${1} ]]
  then
    contributor="noel"
  else
    contributor="${1}"
fi

# Check if contributor key exists
if [[ ${gitrepos[${contributor}]+_} ]]
  then
    # Check that the remote is not currently set
    if [[ $(git remote | grep ${contributor}) ]]
      then
        echo "Remote for '${contributor}' already configured"
      else
        git remote add ${contributor} git@github.com:${gitrepos[${contributor}]}/${repository}
        echo "Remote '${contributor}' set"
    fi
  else
    echo "Configured repo for '${contributor}' not found."
fi
