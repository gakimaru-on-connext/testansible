#!/bin/sh -e

# playbook/inventories/*_hosts.yml の内容に問題がないか検証する

CURDIR=$(cd $(dirname $0);pwd)
source $CURDIR/_env.rc

cd $INVENTORIES_DIR
for FILE in *_hosts.yml
do
    if [ "${FILE:0:1}" != "_" ]; then
        cd $PLAYBOOK_DIR
        INVENTORY_FILE=$INVENTORIES/$FILE
        echo check: $INVENTORY_FILE
        ansible-inventory -i $INVENTORY_FILE --list
        #ansible-inventory -i $INVENTORY_FILE --list -vvvv
        #ansible-inventory -i $INVENTORY_FILE --list --yaml
        #ansible-inventory -i $INVENTORY_FILE --graph
    fi
done
