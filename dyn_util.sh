#!/bin/bash

## Antiblau dyn utility functions
#
# Author: Stefan Haun <tux@netz39.de>


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
export -f check_domain


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
export -f check_ip
