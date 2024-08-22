#!/bin/bash

# delete pipeline
az synapse pipeline delete \
    --workspace-name codingassignmentsynapse \
    --name load_customer_statement_records \
    --yes

sleep 10 

# delete notebook 
az synapse notebook delete \
    --workspace-name codingassignmentsynapse \
    --name load_customer_statement_records \
    --yes

# make sure adls fs if empty
az storage fs directory delete \
    --file-system codingassignmentfilesystem \
    --name reports \
    --account-name codingassignmentstorage \
    --yes

az storage fs directory delete \
    --file-system codingassignmentfilesystem \
    --name arriving_data \
    --account-name codingassignmentstorage \
    --yes

az storage fs directory delete \
    --file-system codingassignmentfilesystem \
    --name synapse \
    --account-name codingassignmentstorage \
    --yes