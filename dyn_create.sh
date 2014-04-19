#!/bin/bash

## Create an Antiblau dyn domain.
#
# Author: Stefan Haun <tux@netz39.de>
#
# Usage: dyn_create domain
#
#	domain	is the domain to be created (which must not be registered as a dyn domain
#
# Requires: ddns-confgen


# Local config
#ZONEDIR=/etc/bind/dynamic # TODO change for production use
ZONEDIR=$(pwd)
DDNS_CONFGEN=/usr/sbin/ddns-confgen

# Includes (see http://stackoverflow.com/a/12694189)
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/dyn_util.sh"



# Get the domain name
DOMAIN=$1
# Check
ERR=$(check_domain "$DOMAIN")
if [ "$?" != "0" ]; then
  echo "Domain parameter error: $ERR"
  exit 1
fi


# Create the zone file
ZONEFILE=$ZONEDIR/$DOMAIN.zone
# TODO abort if already exists
echo "Creating zone in $ZONEFILE"
cat zone.template | sed -e "s/%DOMAIN%/$DOMAIN/" > $ZONEFILE
if [ "$?" != "0" ]; then
  echo "Error creating zone file!"
  exit 1
fi

KEYFILE=$ZONEDIR/$DOMAIN.key
# TODO abort if already exists
echo "Creating key in $KEYFILE"
# Create the zone key
$DDNS_CONFGEN -z $DOMAIN -q > $KEYFILE

# Create the named config
# TODO

# Append to named.conf.dynamic
# TODO


# Finished


# End
