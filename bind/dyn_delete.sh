#!/bin/bash

## Delete an Antiblau dyn domain.
#
# Author: Stefan Haun <tux@netz39.de>
#
# Usage: dyn_delete domain
#
#	domain	is the domain to be deleted


# Local config
#ZONEDIR=/etc/bind/dynamic # TODO change for production use
ZONEDIR=$(pwd)


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
# delete if exists
if [ -f "$ZONEFILE" ]; then
  rm -f "$ZONEFILE"
  local RES=$?
  if [ "$?" != "0" ]; then
    echo "[E zone nodelete] Error deleting zone file: $RES"
    exit 1
  fi
else
  echo "[W no zone] Warn: Zone file for the domain does not exist!"
fi

# Render the update file path
JNLFILE=$ZONEDIR/$DOMAIN.jnl
# delete if exists
if [ -f "$JNLFILE" ]; then
  rm -f "$JNLFILE"
  local RES=$?
  if [ "$?" != "0" ]; then
    echo "[E jnl nodelete] Error deleting update file: $RES"
    exit 1
  fi
fi

# Render the key file path
KEYFILE=$ZONEDIR/$DOMAIN.key
# abort if the key already exists
if [ -f "$KEYFILE" ]; then
  rm -f "$KEYFILE"
  local RES=$?
  if [ "$?" != "0" ]; then
    echo "[E key nodelete] Error deleting key file: $RES"
    exit 1
  fi
else
  echo "[W no key] Warn: Key file for the domain does not exist!"
fi


# Finished
echo "[I] Dynamic zone for $DOMAIN deleted."
# named config in zone.conf.dynamic is created by a different script
echo "[I] Make sure that the named zone.conf.dynamic is updated, too!"

exit 0

# End
