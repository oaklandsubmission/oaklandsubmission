#!/bin/bash
# This is just a template to be used for writing new bash scripts

###
# Based on Google Style Guide: https://google.github.io/styleguide/shell.xml
# General remarks
# * Executables should have no extension (strongly preferred) or a .sh extension.
# * Libraries must have a .sh extension and should not be executable
# * SUID and SGID are forbidden on shell scripts.
# * All error messages should go to STDERR.
# * Write todos like this: # TODO(renzok): Handle the unlikely edge cases (bug ####)
# * Indent 2 spaces. No tabs. 80 chars max per line
# * Put ; do and ; then on the same line as the while, for or if.
# * Quoting: https://google.github.io/styleguide/shell.xml#Quoting
# * Function Names: Lower-case, with underscores to separate words.
# ** Separate libraries with ::. Parentheses are required after the function name.
# * prefer shell builtin over separate process
##


##
# Coding tips and tricks:
# http://stackoverflow.com/questions/1167746/how-to-assign-a-heredoc-value-to-a-variable-in-bash
#

# Exit immediately if a command exits with a non-zero status.
#
# This might cause problems e.g. using read to read a heredoc cause
# read to always return non-zero set -o errexit Treat unset variables
# as an error when substituting.
# set -o xtrace
set -o nounset
set -o errexit
set -o pipefail

# First step, update apt
apt update

# Second
apt install -yq \
apt-transport-https \
ca-certificates \
curl \
vim \
git \
tmux \
software-properties-common

# Third
apt install -y inotify-tools
apt install -y sendmail
apt install -y redis-tools
apt install -yq python3-pip
pip3 install --upgrade pip
pip3 install redis

apt install -yq jq
timedatectl set-timezone America/Chicago # timezone needs to be modified depending actual region user is in
