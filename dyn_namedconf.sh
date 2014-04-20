#!/bin/bash

## Create the named config text for all dynamic domains
#
# Author: Stefan Haun <tux@netz39.de>
#
# Usage: dyn_namedconf
#
# Outputs the text for named.conf.dynamic to be included in named.conf.local


# Local config
#ZONEDIR=/etc/bind/dynamic # TODO change for production use
ZONEDIR=$(pwd)
#TEMPLATEDIR=/usr/share/dyndns # TODO change for production use
TEMPLATEDIR=$(pwd)


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
  echo "Fatal: Error on header template instantiation!"
  exit 1
fi


# For each zone file (aka domain)
# TODO sorting by file name may look nicer in the result, 
#      however not human is expected to read it anyway …
for ZFILE in $ZONEDIR/*.zone; do
  # extract the domain name
  DOMAIN=$(echo "$ZFILE" | sed -e 's|^'$ZONEDIR/'||' -e 's/.zone$//')
  # print the instantiated template
  template_instance $TEMPLATE_ZONE $DOMAIN
  if [ "$?" != "0" ]; then
    echo "Fatal: Error on zone template instantiation!"
    exit 1
  fi
done


# Print the footer
template_instance $TEMPLATE_FOOTER ""
if [ "$?" != "0" ]; then
  echo "Fatal: Error on footer template instantiation!"
  exit 1
fi


# Finished
exit 0

# End
