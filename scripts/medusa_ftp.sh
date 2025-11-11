#!/bin/bash
TARGET=192.168.56.101
USERFILE=../wordlists/common-usernames.txt
PASSFILE=../wordlists/small-words.txt
OUT=../report_ftp_$(date +%F_%T).log

medusa -h $TARGET -U $USERFILE -P $PASSFILE -M ftp -t 8 | tee $OUT