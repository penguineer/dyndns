#!/bin/bash

## Create the named config text for all dynamic domains
#
# Author: Stefan Haun <tux@netz39.de>
#
# Usage: dyn_namedconf
#
# Outputs the text for named.conf.dynamic to be included in named.conf.local


# Local config
ZONEDIR=/etc/bind/dynamic
TEMPLATEDIR=/usr/share/dyndns


# Includes (see http://stackoverflow.com/a/12694189)
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/dyn_util.sh"


# the template paths
TEMPLATE_HEADER=$TEMPLATEDIR/conf.header.template
TEMPLATE_ZONE=$TEMPLATEDIR/conf.zone.template
TEMPLATE_FOOTER=$TEMPLATEDIR/conf.footer.template


# Print the header
template_instance $TEMPLATE_HEADER ""
if [ "$?" != "0" ]; then
  echo "[E header] Fatal: Error on header template instantiation!"
  exit 1
fi

# Check if there are zone files 
# (otherwise the for loop returns unintended results)
if [ -f $ZONEDIR/*.zone ]; then
  # For each zone file (aka domain)
  # TODO sorting by file name may look nicer in the result, 
  #      however not human is expected to read it anyway …
  for ZFILE in $ZONEDIR/*.zone; do
    # extract the domain name
    DOMAIN=$(echo "$ZFILE" | sed -e 's|^'$ZONEDIR/'||' -e 's/.zone$//')
    # print the instantiated template
    template_instance $TEMPLATE_ZONE $DOMAIN
    if [ "$?" != "0" ]; then
      echo "[E zone] Fatal: Error on zone template instantiation!"
      exit 1
    fi
  done
fi

# Print the footer
template_instance $TEMPLATE_FOOTER ""
if [ "$?" != "0" ]; then
  echo "[E footer] Fatal: Error on footer template instantiation!"
  exit 1
fi


# Finished
exit 0

# End
