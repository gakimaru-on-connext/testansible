#!/bin/sh -e

# Please install ansible-lint by brew

CURDIR=$(cd $(dirname $0);pwd)
cd $CURDIR/playbook

RESULT_FILE=$CURDIR/ansible_lint_result.txt

ansible-lint > $RESULT_FILE 2>&1
cat $RESULT_FILE | less -R
