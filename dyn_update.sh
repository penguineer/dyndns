#!/bin/bash

## Update or remove a dynamic IP from an Antiblau dyn domain via nsupdate.
#
# Author: Stefan Haun <tux@netz39.de>
#
# Usage: dyn_update domain [ip]
#
#	domain	is the domain to be updated (which must be created and 
#		registered as a dyn domain
#	ip	is the new IP. If this parameter is omitted, the A record
#		will be removed.
#
# Requires: nsupdate


# Local config
SERVER=ns.antiblau.de
NSUPDATE=/usr/bin/nsupdate
#KEYDIR=/etc/bind/dynamic # TODO change for production use
KEYDIR=$(pwd)



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

# Check if keyfile for the domain exists
KEYFILE=$KEYDIR/$DOMAIN.key
if [ ! -f "$KEYFILE" ]; then
  echo "Cannot find key file $KEYFILE!"
  exit 1
fi
echo "Using key $KEYFILE."


# Get the IP
IP=$2
# Check the IP if provided
if [ -n "$IP" ]; then

  ERR=$(check_ip "$IP")
  if [ "$?" != "0" ]; then
    echo "IP parameter error: $ERR"
    exit 1
  fi
  
  echo "Setting IP $IP for domain $DOMAIN."

else
  echo "Removing IP entry for domain $DOMAIN."
fi


# Build nsupdate call string
BATCH="server $SERVER"
BATCH="$BATCH\nzone $DOMAIN"
BATCH="$BATCH\nprereq yxdomain $DOMAIN"
BATCH="$BATCH\nupdate delete $DOMAIN A"
# Only add A record if IP has been provided.
if [ -n "$IP" ]; then
  BATCH="$BATCH\nupdate add $DOMAIN 60 A $IP"
fi
BATCH="$BATCH\nsend\n"


# Call nsupdate
echo -e "$BATCH" | nsupdate -k $KEYFILE


# Evaluate result
RET=$?

if [ "$RET" != 0 ];  then
  echo "Call to nsupdate failed with exit code $RET!"
  exit 2
fi

# Finished
echo "Update call finished successful."
exit 0



# End
