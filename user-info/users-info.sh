#!/usr/bin/env bash
#===============================================================================
#
#          FILE: lsuser.sh
#
#         USAGE: ./lsuser.sh
#
#   DESCRIPTION: Get information about user
#
#       OPTIONS: ---
#  REQUIREMENTS: dialog, bash
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Piotr Rogoża (), piotr dot r dot public at gmail dot com
#  ORGANIZATION:
#       CREATED: 26.11.2014 19:27
#      REVISION:  ---
#===============================================================================
. ./setup-vars
. ./setup-tempfile
user=root
list_users (){ #{{{
    getent passwd | awk -F: '{ print $1, $5;  }'
} # end of function list_users #}}}

# convert to array of elements: login comment
while read key value; do
    tablica+=($key "$value")
done < <(list_users)

retval=0
while [ $retval -eq 0 ]; do
$DIALOG \
    --backtitle "User info" \
    --title "Get information about user" \
    --ok-label "Info" \
    --default-item "$user" \
    --menu "Select user from following list to get information about him\n\n" \
    40 100 30 \
    "${tablica[@]}" \
    2>$tempfile
retval=$?
    case $retval in
        $DIALOG_OK)
            user=`cat $tempfile`
            id=`getent passwd $user | cut -d: -f3`
            gid=`getent passwd $user | cut -d: -f4`
            comment=`getent passwd $user | cut -d: -f5`
            home=`getent passwd $user | cut -d: -f6`
            shell=`getent passwd $user | cut -d: -f7`
            $DIALOG \
                --backtitle "User info" \
                --title "User info" \
                --msgbox "Information for user $user\n\n\
id:             $id\n\
gid:            $gid\n\
comment:        $comment\n\
home directory: $home\n\
shell:          $shell\n\n\
groups:         `groups $user`" 20 60
            ;;
        $DIALOG_CANCEL|$DIALOG_ESC)
            exit
            ;;
    esac
done
