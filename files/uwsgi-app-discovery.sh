#!/bin/bash

UWSGI_PATH='/etc/uwsgi/apps-enabled/'
FIRST_ELEMENT=1

function json_head {
    printf "{";
    printf "\"data\":[";    
}

function json_end {
    printf "]";
    printf "}";
}

function check_first_element {
    if [[ $FIRST_ELEMENT -ne 1 ]]; then
        printf ","
    fi
    FIRST_ELEMENT=0
}

function databse_detect {
    json_head
    for app in `ls $UWSGI_PATH`
    do
        grep -q stats $UWSGI_PATH/$app
        if [[ $? -eq 0 ]]; then
            local stat=$(cat $UWSGI_PATH/$app | grep stats | cut -d'=' -f2 | sed -e 's/\s//g')
            check_first_element
            printf "{"
            printf "\"{#APPNAME}\":\"$app\""
            printf "}"
        fi
    done
    json_end
}
databse_detect
