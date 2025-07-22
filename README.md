Introduction
This project sets up a tiered management group structure in Azure using Terraform. It provides a clear hierarchy for managing resources and policies across different environments and departments within an organization.

Folder Structure
Langingzonetf/
├── .github/
│   └── workflows/
│       └── workflowpipeline.yml      # GitHub Actions CI/CD pipeline
├── modules/
│   └── managementgroups/
│       ├── main.tf                  # Terraform resources for management groups
│       ├── variables.tf             # Input variables for the module
│       └── bootstrap.sh             # Script to create secure storage for state file
├── README.md                        # Project documentation
Getting Started
Installation Process

Ensure you have Terraform installed on your machine. Download it from the Terraform website.
Clone this repository to your local machine.
Software Dependencies

Terraform (version 1.0 or higher)
Azure CLI (for authentication)
Bash (for running bootstrap.sh)
Authentication

Authenticate to Azure using the Azure CLI:
az login
Configuration

Update the modules/managementgroups/variables.tf file with your specific configuration values, such as management group names and display names.
Bootstrap State Storage

Run the bootstrap script to create a secure storage account and blob container for the Terraform state file:
cd modules/managementgroups
chmod +x bootstrap.sh
./bootstrap.sh
Build and Test
To build and apply the Terraform configuration, run the following commands in the root directory of the project:

Initialize the Terraform configuration:

terraform init
Validate the configuration:

terraform validate
Plan the deployment:

terraform plan
Apply the configuration:

terraform apply
CI/CD
The workflow in .github/workflows/workflowpipeline.yml automates linting, security scanning, and deployment using GitHub Actions.
Contribute
Contributions are welcome! If you would like to contribute to this project, please fork the repository and submit a pull request. Ensure that your code adheres to the project's coding standards and includes appropriate tests.

For any questions or issues, feel free to open an issue in the repository.
