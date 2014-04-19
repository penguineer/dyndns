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
# Requires: grep, awk, nsupdate


# Local config
SERVER=ns.antiblau.de
NSUPDATE=/usr/bin/nsupdate
#KEYDIR=/etc/bind/dynamic
KEYDIR=/home/tux

# Domain syntax check
# see http://stackoverflow.com/questions/15268987/bash-based-regex-domain-name-validation
function check_domain() {
  local DOMAIN=$1
  
  # Check if domain parameter exists
  if [ -z "$DOMAIN" ]; then
    echo "Domain parameter must be provided!"
    return 1
  fi
  if ! echo "$DOMAIN" | grep -qP '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+\.(?:[a-z]{2,})$)'; then
    echo "The domain name did not pass the syntax validation!"
    return 1
  fi
}


# Check if the provided IP address is valid
# Returns nothing if the address is okay, otherwise an error message.
function check_ip() {
  local IP="$1"
  
    # Mostly "inspired" by http://stackoverflow.com/questions/13015206/variables-validation-name-and-ip-address-in-bash
  if echo "$IP" | grep -qE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
  then
      # Then the format looks right - check that each octect is less
      # than or equal to 255:
      VALID_IP_ADDRESS="$(echo $IP | awk -F'.' '$1 <=255 && $2 <= 255 && $3 <= 255 && $4 <= 255')"
      if [ -z "$VALID_IP_ADDRESS" ]
      then
	 echo "The IP address wasn't valid; octets must be less than 256"
	 return 1
      fi
  else
      echo "The IP address was malformed"
      return 1
  fi
  
  return 0
}



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
