#!/bin/sh -e

CURDIR=$(cd $(dirname $0);pwd)

TARGET_INVENTORY=vagrant
TARGET_SITE=all_setup

source $CURDIR/_provision.rc

# Vagrant 専用処理
# 注）~/.ssh/known_hosts を強制的に書き換えるので注意
#force_update_known_hosts 192.168.56.11 testansible
#force_update_known_hosts 192.168.56.11 testansible01
#force_update_known_hosts 192.168.56.12 testansible02
#force_update_known_hosts 192.168.56.13 testansible03
#force_update_known_hosts 192.168.56.14 testansible04
#force_update_known_hosts 192.168.56.15 testansible05
#force_update_known_hosts 192.168.56.16 testansible06
#force_update_known_hosts 192.168.56.17 testansible07
#force_update_known_hosts 192.168.56.18 testansible08

ansible-playbook -i $INVENTORY_FILE $SITE_FILE --extra-vars "$EXTRA_VARS" $ANSIBLE_OPT
