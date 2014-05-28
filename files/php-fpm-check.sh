#!/bin/bash
##################################
# Zabbix monitoring script
#
# php-fpm:
#  - anything available via FPM status page
#
##################################
# Contact:
#  vincent.viallet@gmail.com
##################################
# ChangeLog:
#  20100922	VV	initial creation
##################################

# Zabbix requested parameter
ZBX_REQ_DATA="$1"
ZBX_REQ_DATA_URL="$2"

# Nginx defaults
NGINX_STATUS_DEFAULT_URL="http://localhost:10061/php-fpm_status"
WGET_BIN="/usr/bin/wget"

#
# Error handling:
#  - need to be displayable in Zabbix (avoid NOT_SUPPORTED)
#  - items need to be of type "float" (allow negative + float)
#
ERROR_NO_ACCESS_FILE="-0.9900"
ERROR_NO_ACCESS="-0.9901"
ERROR_WRONG_PARAM="-0.9902"
ERROR_DATA="-0.9903" # either can not connect /	bad host / bad port

# Handle host and port if non-default
if [ ! -z "$ZBX_REQ_DATA_URL" ]; then
  URL="$ZBX_REQ_DATA_URL"
else
  URL="$NGINX_STATUS_DEFAULT_URL"
fi

# save the nginx stats in a variable for future parsing
NGINX_STATS=$($WGET_BIN -q $URL -O - 2> /dev/null)

# error during retrieve
if [ $? -ne 0 -o -z "$NGINX_STATS" ]; then
  echo $ERROR_DATA
  exit 1
fi

# 
# Extract data from nginx stats
#
case $ZBX_REQ_DATA in
  'accepted conn')        echo "$NGINX_STATS" | grep '^accepted conn:' | cut -f2 -d ':' | sed 's/\s//g';;
  'active processes')     echo "$NGINX_STATS" | grep '^active processes:' | cut -f2 -d ':' | sed 's/\s//g';;
  'idle processes')       echo "$NGINX_STATS" | grep '^idle processes:' | cut -f2 -d ':' | sed 's/\s//g';;
  'listen queue len')     echo "$NGINX_STATS" | grep '^listen queue len:' | cut -f2 -d ':' | sed 's/\s//g';;
  'listen queue')         echo "$NGINX_STATS" | grep '^listen queue:' | cut -f2 -d ':' | sed 's/\s//g';;
  'max active processes') echo "$NGINX_STATS" | grep '^max active processes:' | cut -f2 -d ':' | sed 's/\s//g';;
  'max children reached') echo "$NGINX_STATS" | grep '^max children reached:' | cut -f2 -d ':' | sed 's/\s//g';;
  'max listen queue')     echo "$NGINX_STATS" | grep '^max listen queue:' | cut -f2 -d ':' | sed 's/\s//g';;
  'total processes')      echo "$NGINX_STATS" | grep '^active processes:' | cut -f2 -d ':' | sed 's/\s//g';;
  *) echo $ERROR_WRONG_PARAM; exit 1;;
esac

exit 0
