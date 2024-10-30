<<<<<<< HEAD
# Getting Started With Azure Terraform Deployments

<!-- BEGIN_TF_DOCS -->

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_vm"></a> [vm](#module\_vm) | ./modules/vm | n/a |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password for the VM | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Admin username for the VM | `string` | `"azureuser"` | no |
| <a name="input_disable_password_auth"></a> [disable\_password\_auth](#input\_disable\_password\_auth) | Disable password authentication | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment Environment - Sandbox, QA, or Prod | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure Region | `string` | `"East US 2"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the Project | `string` | `"spacelift-se-sandbox"` | no |
| <a name="input_subnet_address_prefixes"></a> [subnet\_address\_prefixes](#input\_subnet\_address\_prefixes) | Address prefixes for the Subnet | `list(string)` | <pre>[<br/>  "10.0.1.0/24"<br/>]</pre> | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Subscription ID is required to run a plan or apply | `string` | n/a | yes |
| <a name="input_vm_number"></a> [vm\_number](#input\_vm\_number) | Instance number of the virtual machine | `number` | `1` | no |
| <a name="input_vm_role"></a> [vm\_role](#input\_vm\_role) | Role of the virtual machine (e.g., web, db) | `string` | `"web"` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Size of the Virtual Machine | `string` | `"Standard_A1_v2"` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | Address space for the Virtual Network | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the Resource Group |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | ID of the Subnet |
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | ID of the Virtual Machine |
| <a name="output_vm_private_ip"></a> [vm\_private\_ip](#output\_vm\_private\_ip) | Public IP of the Virtual Machine |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | ID of the Virtual Network |
<!-- END_TF_DOCS -->

## Azure Directory Structure

```
 ┣ modules
 ┃ ┣ network
 ┃ ┃ ┣ README.md
 ┃ ┃ ┣ main.tf
 ┃ ┃ ┣ outputs.tf
 ┃ ┃ ┗ variables.tf
 ┃ ┗ vm
 ┃ ┃ ┣ README.md
 ┃ ┃ ┣ main.tf
 ┃ ┃ ┣ outputs.tf
 ┃ ┃ ┗ variables.tf
 ┣ static
 ┃ ┣ Azure_CLI.png
 ┃ ┣ Azure_Login.png
 ┃ ┗ Azure_signup.png
 ┣ .gitignore
 ┣ README.md
 ┣ main.tf
 ┣ outputs.tf
 ┗ variables.tf
```

## Resource Naming Conventions

`project_name` - Name of the project associated with resource
`environment` - Environment that the resource is associated with
`vm_role` - Role of the resource type
`vm_number` - Count of the the resource in use

**Example**
Network Interface Ex: `customerportal_qa_web1_nic`
Virtual Machine Ex: `customerportal-qa-web1-vm`
Subnet Ex: `customerportal-qa-web1-subnet`
Resource Group Ex: `customerportal-qa-web1-rg`
Virtual Network Ex: `customerportal-qa-web1-vnet`
=======
test ac
>>>>>>> 9ce5d4222fa6bfe766c3910e54559f07a7c3ca80
