#!/bin/sh -e

# playbook/inventories/*_hosts.yml の内容に問題がないか検証する

CURDIR=$(cd $(dirname $0);pwd)
source $CURDIR/_env.rc

for OPT in "$@"
do
    case $OPT in
    "-h" | "--help" )
        echo "usage: $(basename $0) [--help|-h] [--list|--yaml|--graph] [-v|-vv|-vvv|-vvvv]"
        ;;
    "--list" )
        LIST_OPT="--list"
        SHOW_OPT=y
        ;;
    "--graph" )
        LIST_OPT="--graph"
        SHOW_OPT=y
        ;;
    "--yaml" )
        LIST_OPT="--list --yaml"
        SHOW_OPT=y
        ;;
    -v* )
        VERBOSE_OPT=$OPT
        SHOW_OPT=y
        ;;
    * )
        echo "Unknown option:" $OPT
        ;;
    esac
    shift
done

if [ "$SHOW_OPT" != "y" ]; then
    LIST_OPT="--list"
fi

cd $INVENTORIES_DIR
for FILE in *_hosts.yml
do
    if [ "${FILE:0:1}" != "_" ]; then
        cd $PLAYBOOK_DIR
        INVENTORY_FILE=$INVENTORIES/$FILE
        echo check: $INVENTORY_FILE
        CMD="ansible-inventory -i $INVENTORY_FILE $LIST_OPT $VERBOSE_OPT"
        #echo "$ $CMD"
        if [ "$SHOW_OPT" = "y" ]; then
            $CMD
        else
            $CMD > /dev/null
        fi
    fi
done
