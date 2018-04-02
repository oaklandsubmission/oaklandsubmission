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

# Second step, install osquery
export OSQUERY_KEY=1484120AC4E9F8A1A577AEEE97A80C63C9D8B80B
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $OSQUERY_KEY
add-apt-repository 'deb [arch=amd64] https://pkg.osquery.io/deb deb main'
apt-get update
apt-get install -y osquery

# Third step, manual replacement of osquery files from conf folder: see README.md
cp conf/osquery/file-accesses.conf /usr/share/osquery/packs/file-accesses.conf
cp conf/osquery/osquery.conf /etc/osquery/osquery.conf

# Fourth step, start osquery daemon
systemctl enable osqueryd
systemctl restart osqueryd

# Status checking of osquery
#journalctl -fu osqueryd
#tail -f /var/log/osquery/osqueryd.results.log

