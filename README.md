## Deploy infrastructure 

### Required software
- azure-cli https://learn.microsoft.com/en-us/cli/azure/install-azure-cli
- terraform https://developer.hashicorp.com/terraform/install
- azure-function-core-toolshttps://github.com/Azure/azure-functions-core-tools
- Visual Studio Code https://code.visualstudio.com/
- Python extension https://marketplace.visualstudio.com/items?itemName=ms-python.python
- Azure Functions extension https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions 
- Azure Resources extension https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azureresourcegroups 

### Clone repo 
```
git clone git@github.com:wjongeneel/coding_assignment.git
```

### Authentication
Authenticate to Azure uzing the following command
```
az login
```
Authenticate using the browser window that comes up

### Set variables in terraform.tfvars 
copy terraform.tfvars.example to terraform.tfvars
```
cd coding_assignment/infrastructure/terraform
cp terraform.tfvars.example terraform.tfvars 
```
Set variables tenant_id, subscription_id, resource_group, and client_ip in terraform.tfvars
```
tenant_id       = "<insert your tenant id here>"
subscription_id = "<insert your subscription id here>"
resource_group  = "<insert your resource_group here>"
client_ip       = "<insert your client_ip here>"
```

### Set SQL credentials in environment variables
copy env_vars.sh.example to env_vars.sh
```
cp env_vars.sh.example env_vars.sh
```
Edit env_vars.sh to include the TF_VAR_sql_administrator_login and TF_VAR_sql_administrator_login_password variables
```
#!/bin/bash

export TF_VAR_sql_administrator_login=<set username for sql_administrator> 
export TF_VAR_sql_administrator_login_password=<set password for sql_administrator>
```

### Set the environment variables in the current shell 
Run the env_vars.sh script to apply the environment variables in the current shell, make sure to include the . before ./env_vars.sh to apply it to the current shell.
```
. ./env_vars.sh
```

Check if the environment variables were set correctly: 
```
echo $TF_VAR_sql_administrator_login
echo $TF_VAR_sql_administrator_login_password
```

### Run terraform init 
Initialize terraform 
```
terraform init 
```

### Run terraform apply 
Apply the terraform configuration
```
terraform apply 
```
The following resources will be created: 
- Storage account with adls filesystem and some directories
- SQL Server / Database 
- Synapse workspace
- Apache spark pool in the synapse workspace 
- Storage account for the function app 
- App service plan 
- Linux Function app to deploy our api onto

### Outputs
The Terraform Outputs will contain a connection_string, jdbc_username, and jdbc_password. Copy this part, we will use it in deploying the pipeline.
Note: This is not something that I would do in a production usecase, I included this part for the purpose of making recreating the assignment easier.  

---
## Deploy pipeline
### Change to the pipeline directory 
```
cd coding_assignment/pipeline 
```

### Edit load_customer_statement_records.ipynb 
Edit python/load_customer_statement_records.ipynb to contain the output block
```
# SECRETS
connection_string = "**********"
jdbc_username = "**********"
jdbc_password = "**********"
```

Note: I recognize that there are more secure ways to do this. We can in example store these in the pyspark configuration, or use other mechanisms. In order to allow for easy recreation of the environment, I chose this way. 

### Change to the synapse_resource_deployment directory
```
cd synapse_resource_deployment directory
```

### Deploy the notebook and pipeline 
```
./deploy_synapse_resources.sh
```
---
## Upload sample data to adls 
```
# change to the input_data directory 
cd coding_assignment/input_data 

# run the upload_data.sh script 
./upload_data.sh
```

---
## Run the pipeline 
### Trigger the pipeline
Steps:
- Go to Synapse Studio -> Integrate 
- Select the available pipeline 
- Click 'Add Trigger' -> 'Trigger Now' 

Notes:
- The pipeline will read from the arriving_data directory in the ADLS filesystem created by terrafrom
- Validation on the records will be done
- Records that fail validation will be written to a report, you can find the report in the ADLS filesystem under the reports directory. NOTE: I had another fun way to create a pdf report. Unfortunately I had some issues with getting the external packages working in the pipeline (adding a requirement.txt file to the spark pool did not solve the issue). For this solution please check the ```pdf_report.py``` file to get an impression.
- Successfull records will be written to the ```transactions``` table in the database created by terraform 
- Records that failed validation will be written to the ```failed_transactions``` table in the database created by terraform 
- IMPORTANT: For some reason sometimes errors like the one below prevent the pipeline from running successfully. A workaround for this is to manually recreate the pipeline with a different name and the same settings as the one that was deployed. 
```
Operation on target load_customer_statement_records failed: Exception: Failed to create Livy session for executing notebook. 
```
- To validate the result, please connect to the database using Azure Data Studio and run 
```
SELECT * FROM transactions; 
SELECT * FROM failed_transactions; 
```

## Deploy the API 
This part is a little tricky, because we will need to use VS Code and some VS Code extensions to deploy the Azure Function. Make sure that you are logged into Azure from VSCode in the Azure Extension Tab before starting.

- In api/function_app.py.example, make sure to include the ```username``` and ```password``` variables. The values should be the same as you found in the Terraform Output for: ```jdbc_username``` and ```jdbc_password```.

- Open the command palette, and run: 
```
Azure Functions: Create New Project...
```
Use the following options:
- Select the folder that will contain you function project --> coding_assignment/api
- Select a language --> Python
- Select a Python programming model --> Model V2 
- Select a Python interpreter to create a virtual environment --> Python 3.11 
- Select a template for your project's first function --> HTTP trigger 
- Name of the function you want to create: get_records 
- Authorization level controls whether the function requires an API key ... --> ANONYMOUS 

This should create some additional files in the coding_assignment/api folder. Next, do this: 
- Delete function_app.py 
- Delete requirements.txt 
- Rename function_app.py.example to function_app.py
- Rename requirements.txt.example to requirements.txt 

Next deploy the function using VS Code 
- Open the command palette, and run: 
```
Azure Functions: Deploy to Function App 
```
Use the following options: 
- Select a subscription --> Use your subscription 
- Select a function app --> coding-assignment-linux-func-app

Validate the function by going to: 
https://coding-assignment-linux-func-app.azurewebsites.net/api/get_records

Note: I would've preferred to also create some CLI script for this. The CLI tool ```func``` is available for this, but unfortunately is not supported for ARM chips that my Macbook uses. https://github.com/Azure/azure-functions-core-tools/issues/3648



## Cleanup 
### Delete stuff that is not managed from Terraform 
First go to synapse studio and delete the pipeline. Due to the $RANDOM part in the name of the creation script this should be done manually. The rest will be cleaned up scripted: 

From the infrastructure directory, run the cleanup_resources.sh
```
./cleanup_resources.sh
```
This will delete the notebook from synapse and the folders on adls. This will allow for an easy terraform destroy 

### Terraform destroy 
From the terraform directory, run: 
```
terraform destroy 
```
Note: If you have recreated the pipeline manually, you might have to delete this from synapse manually before running terraform destroy. 

## Improvements that could be implemented
- Use Managed Identities/Linked Service to connect from Synapse notebook to SQL Database
- Use Managed Identities to connect from Azure function app to SQL Database 
- Create a better deployment method for Azure function app code 
- Implement logging / monitoring 
- Implement source control in Synapse / automate deployments
- Implement unit testing for notebook 