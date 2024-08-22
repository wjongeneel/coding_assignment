#!/bin/bash 

# deploy notebook 
az synapse notebook create \
    --workspace-name codingassignmentsynapse \
    --name load_customer_statement_records \
    --file @"../python/load_customer_statement_records.ipynb" 

# deploy pipeline, ${RANDOM} is used, because if you break down the infrastructure
# and redeploy with the same name, the pipeline will fail 
az synapse pipeline create \
    --workspace-name codingassignmentsynapse \
    --name "load_customer_statement_records_${RANDOM}" \
    --file @"synapse_files/pipeline.json" 

