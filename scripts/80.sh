#!/bin/sh
set -e

# this file adds a port forwarding rule to osx firewall. needs to run as root.
#
# before running this script on any mac, first check if there are any pf rules already
# active by running "sudo pfctl -s nat". if any rule other than the ones mentioned
# below are present, reconsider running this script, or may be add those rules in this
# and append the 80 -> 3000 line below.
#
# we are doing runtime changes to firewall rules, so worst case, restarting the
# machine will undo any damages done.

echo "
nat-anchor \"com.apple/*\" all
rdr-anchor \"com.apple/*\" all
rdr pass inet proto tcp from any to any port 80 -> 127.0.0.1 port 3000
" | sudo /sbin/pfctl -ef -
