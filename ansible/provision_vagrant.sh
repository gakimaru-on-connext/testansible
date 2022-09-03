#!/bin/sh -e

CURDIR=$(cd $(dirname $0);pwd)

TARGET_INVENTORY=vagrant
TARGET_SITE=all_setup

source $CURDIR/_provision.rc

ansible-playbook -i $INVENTORY_FILE $SITE_FILE --extra-vars "$EXTRA_VARS" $ANSIBLE_OPT
