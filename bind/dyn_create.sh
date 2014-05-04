#!/bin/bash

## Create an Antiblau dyn domain.
#
# Author: Stefan Haun <tux@netz39.de>
#
# Usage: dyn_create domain
#
#	domain	is the domain to be created (which must not already be 
#		registered as a dyn domain)
#
# Requires: ddns-confgen (in package bind9)


# Local config
ZONEDIR=/etc/bind/dynamic
TEMPLATEDIR=/usr/share/dyn
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
  echo "$ERR"
  exit 1
fi


# Render the zone file path
ZONEFILE=$ZONEDIR/$DOMAIN.zone
# abort if zone already exists
if [ -f "$ZONEFILE" ]; then
  echo "[E zone exists] Zone file $ZONEFILE is in the way and will not be overwritten!"
  exit 1
fi

# Render the key file path
KEYFILE=$ZONEDIR/$DOMAIN.key
# abort if the key already exists
if [ -f "$KEYFILE" ]; then
  echo "[E key exists] Key file $KEYFILE is in the way and will not be overwritten!"
  exit 1
fi


# Create the zone
echo "[I] Creating zone in $ZONEFILE"
cat $TEMPLATEDIR/zone.template | sed -e "s/%DOMAIN%/$DOMAIN/" > $ZONEFILE
if [ "$?" != "0" ]; then
  echo "[E zone nocreate] Error creating zone file!"
  exit 1
fi

# Create the zone key
echo "[I] Creating key in $KEYFILE"
$DDNS_CONFGEN -z $DOMAIN -q > $KEYFILE
if [ "$?" != "0" ]; then
  echo "[E key nocreate] Error creating key file!"
  exit 1
fi

# Finished
echo "[I] Dynamic zone for $DOMAIN created successfully."
# named config in zone.conf.dynamic is created by a different script
echo "[I] Make sure that the named zone.conf.dynamic is updated, too!"

exit 0

# End
