#!/bin/bash 

# deploy notebook 
az synapse notebook create \
    --workspace-name codingassignmentsynapse \
    --name load_customer_statement_records \
    --file @"../python/load_customer_statement_records.ipynb" 

# deploy pipeline
az synapse pipeline create \
    --workspace-name codingassignmentsynapse \
    --name "load_customer_statement_records" \
    --file @"synapse_files/pipeline.json" 

