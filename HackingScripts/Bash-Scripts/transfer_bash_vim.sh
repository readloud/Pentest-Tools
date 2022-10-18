#!/bin/bash

transfer_bash_vim () {
  scp ~/.bash_aliases "${1}:/home/ubuntu"
  scp ~/.vimrc "${1}:/home/ubuntu"
  echo ".bash_aliases and .vimrc transferred to ${1}"
}

transfer_bash_vim $1
