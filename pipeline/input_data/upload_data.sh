#!/bin/bash

# upload file to adls 
az storage fs file upload \
    -s ./records_1.csv \
    -p /records_1.csv  \
    -f codingassignmentfilesystem/arriving_data \
    --account-name codingassignmentstorage 

