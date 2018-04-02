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
set -o xtrace
set -o nounset
set -o errexit
set -o pipefail

# First step, update apt
apt update

# Second
wget -nv http://download.opensuse.org/repositories/network:bro/xUbuntu_16.04/Release.key -O /tmp/Release.key
apt-key add < /tmp/Release.key
apt-get update

sh -c "echo 'deb http://download.opensuse.org/repositories/network:/bro/xUbuntu_16.04/ /' > /etc/apt/sources.list.d/bro.list"
apt update
apt install -y bro

# bro pkg
apt install -y python-pip
pip install bro-pkg
export PATH=$PATH:/opt/bro/bin
bro-pkg autoconfig
# use open source bro notices 
bro-pkg install --force bro/initconf/CVE-2017-5638_struts
bro-pkg install --force bro/hhzzk/dns-tunnels

# Manual replacement of bro files from conf folder. See README.md
cp conf/bro/networks.cfg /opt/bro/etc/ 
cp conf/bro/node.cfg /opt/bro/etc/
cp conf/bro/local.bro /opt/bro/share/bro/site/
mkdir -p /opt/bro/share/bro/site/scripts/
cp conf/bro/dns-bad_behavior.bro /opt/bro/share/bro/site/scripts/
cp conf/bro/json-logs.bro /opt/bro/share/bro/site/scripts/
# Start bro
/opt/bro/bin/broctl deploy
# cd /opt/bro/bin
# broctl
# > deploy
# > restart
# > status
