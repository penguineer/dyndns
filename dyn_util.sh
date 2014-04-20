#!/bin/bash

## Antiblau dyn utility functions
#
# Author: Stefan Haun <tux@netz39.de>


# Domain syntax check
# see http://stackoverflow.com/questions/15268987/bash-based-regex-domain-name-validation
# Returns 0 if everything worked out, 1 if there is an error. The error message has been sent to stdout
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
# Returns 0 if everything worked out, 1 if there is an error. The error message has been sent to stdout
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


# Create and print a template instance
# Parameter 1: The template path
# Parameter 2: the actual domain to be replaced
# Each occurence of %DOMAIN% in the template is replaced by the domain parameter
# Returns the return value of the sed call
function template_instance() {
  local TEMPLATE=$1
  local DOMAIN=$2

  if [ ! -f "$TEMPLATE" ]; then
    echo "Cannot find template $TEMPLATE!"
    return 1
  fi
  
  cat "$TEMPLATE" | sed -e "s/%DOMAIN%/$DOMAIN/" 
  return $?
}

# End

