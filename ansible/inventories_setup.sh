#!/bin/sh -e

# playbook/inventories/templates/_*_hosts.yml を編集してこのスクリプトを実行すると、
# playbook/inventories/tempaltes/__*.yml と合成して、
# playbook/inventories/*_hosts.yml を生成する

CURDIR=$(cd $(dirname $0);pwd)
source $CURDIR/_env.rc

cd $INVENTORIES_TEMPLATES_DIR
for FILE in _*_hosts.yml
do
    if [ "${FILE:0:1}" = "_" -a "${FILE:1:1}" != "_" ]; then
        INVENTORY_FILE=${FILE:1}
        INVENTORY_FILE_NAME=${INVENTORY_FILE%.*}
        echo create: $INVENTORIES/$INVENTORY_FILE
        INVENTORY_PATH=$INVENTORIES_DIR/$INVENTORY_FILE
        LINES=$(sed -n '$=' $FILE)
        HOSTS_BEGIN_HIT_LINE=$(sed -n -e "/HOSTS:BEGIN/=" $FILE)
        HOSTS_END_HIT_LINE=$(sed -n -e "/HOSTS:END/=" $FILE)
        VARS_BEGIN_HIT_LINE=$(sed -n -e "/VARS:BEGIN/=" $FILE)
        VARS_END_HIT_LINE=$(sed -n -e "/VARS:END/=" $FILE)
        HOSTS_BEGIN_LINE=$(($HOSTS_BEGIN_HIT_LINE + 1))
        HOSTS_END_LINE=$(($HOSTS_END_HIT_LINE - 1))
        VARS_BEGIN_LINE=$(($VARS_BEGIN_HIT_LINE + 1))
        VARS_END_LINE=$(($VARS_END_HIT_LINE - 1))
        if [ "$VARS_END_HIT_LINE" = "" ]; then
            VARS_END_LINE=$LINES
        fi
        if [ "$VARS_BEGIN_HIT_LINE" = "" ]; then
            unset VARS_BEGIN_LINE
            unset VARS_END_LINE
        fi
        if [ "$HOSTS_END_HIT_LINE" = "" ]; then
            HOSTS_END_LINE=$LINES
            unset VARS_BEGIN_LINE
            unset VARS_END_LINE
        fi
        sed -e 's/\$FILE/'$INVENTORY_FILE'/g' \
            -e 's/\$NAME/'$INVENTORY_FILE_NAME'/g' \
            $INVENTORIES_COMMON_TEMPLATES_DIR/__header.yml > $INVENTORY_PATH
        sed -n "${HOSTS_BEGIN_LINE},${HOSTS_END_LINE}p" $FILE >> $INVENTORY_PATH
        cat $INVENTORIES_COMMON_TEMPLATES_DIR/__groups.yml >> $INVENTORY_PATH
        cat $INVENTORIES_COMMON_TEMPLATES_DIR/__vars.yml >> $INVENTORY_PATH
        if [ "$VARS_BEGIN_LINE" != "" ]; then
            sed -n "${VARS_BEGIN_LINE},${VARS_END_LINE}p" $FILE >> $INVENTORY_PATH
        fi
        cat $INVENTORIES_COMMON_TEMPLATES_DIR/__footer.yml >> $INVENTORY_PATH
    fi
done
