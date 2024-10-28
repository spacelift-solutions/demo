<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Azure Virtual Machine Admin Password | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Azure Virtual Machine Admin Username | `string` | `"cloudopsuser1"` | no |
| <a name="input_disable_password_auth"></a> [disable\_password\_auth](#input\_disable\_password\_auth) | Disable password authentication | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the Environment - Sandbox, QA, or Prod | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | `"East US 2"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the Project | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the Resource Group | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of the Subnet | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | The Subscription ID is required to run a plan or apply | `string` | n/a | yes |
| <a name="input_vm_number"></a> [vm\_number](#input\_vm\_number) | Number of the VM Resource | `string` | n/a | yes |
| <a name="input_vm_role"></a> [vm\_role](#input\_vm\_role) | Role of the VM Resource | `string` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Size of the VM Resource | `string` | `"Standard_A1_v2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vm_id"></a> [vm\_id](#output\_vm\_id) | The ID of the Virtual Machine |
| <a name="output_vm_private_ip"></a> [vm\_private\_ip](#output\_vm\_private\_ip) | The public IP of the Virtual Machine |
<!-- END_TF_DOCS -->