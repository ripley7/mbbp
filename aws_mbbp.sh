#!/bin/bash

# USAGE: this script downloads all Mediabase Big Picture files within the AWS
# s3://bc-sftp-processed/ bucket into the Mediabase Big Picture home folder
# on angus.bclocal. If the action is successful, the AWS files are moved to
# a timestamped prefix as '/archive/mediabase/[TIMESTAMP]/'.

# Variables
prefix='s3://bc-sftp-processed/mediabase/incoming/'
archive="s3://bc-sftp-processed/archive/mediabase/"
incoming=($(aws s3 ls s3://bc-sftp-processed/mediabase/incoming/ | grep Mediabase_Big_Picture | sed 's/.* //'))
mbbp='/home/ibex/mediabase_bigpicture/' 

# Log entry variable.
# Formats out to the abbreviated month (eg. "Nov"), day of the month, and time
# (eg. "Nov 13 12:00:00"), followed by server name and PID.
logstamp="$(date +%b) $(date +%d) $(date +%H:%M:%S) angus aws_mbbp[$$]"

# Operation
if [[ ${#incoming[@]} == 0 ]]; then
    echo "$logstamp: No files found in $prefix"
else
    if [[ ${#incoming[@]} -gt 1 ]]; then
        echo "$logstamp: Found ${#incoming[@]} files. Copying files to $mbbp"
    else
        echo "$logstamp: Found 1 file. Copying file to $mbbp"
    fi
    for i in ${incoming[@]}; do
        if aws s3 cp ${prefix}${i} ${mbbp}; then
            echo "$logstamp: Moving file to archive..."
            aws s3 mv ${prefix}${i} ${archive}$(date +%Y%m%d.%H%M%S.%2N)/
        else
            echo "$logstamp: Error. Could not transfer file." >&2
            break
        fi
    done
fi
