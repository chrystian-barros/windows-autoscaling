# windows-autoscaling

Terraform module that provisions the full application layer for the Puerto Rico infrastructure on Oracle Cloud Infrastructure (OCI). It solves the problem of manually orchestrating a fleet of auto-scaled Windows compute instances that require shared NFS storage, a MySQL database connection, secrets management, event-driven configuration, and layer-4 load balancing — wiring all of these concerns together in a single, repeatable module.

Key capabilities:
- **Instance Pool + Autoscaling** — CPU-threshold-based horizontal scaling (scale-out >70%, scale-in <30%) backed by an OCI Instance Configuration.
- **Event-driven NFS mount** — An OCI Events rule triggers a serverless function (`setup_windows_server`) on every `launchinstance.end` event, mounting the shared file system on each new instance automatically — including autoscaled ones Terraform never directly manages.
- **Network Load Balancer** — Internal IPv4 NLB with a configurable TCP/UDP backend set and listener; instances are registered automatically by the Instance Pool.
- **Secrets management** — Server password stored in an OCI Vault (HSM-protected AES-256 key), injected into the function at runtime.
- **IAM** — Dynamic group and least-privilege policies scoped to the target compartment.
- **NSGs** — Separate Network Security Groups for compute instances and the file system mount target, with NFS-specific TCP/UDP rules (ports 111, 2048–2050).

---

## Dependencies

![Dependency Graph](graph.png)

> The graph above visualises the directed relationships between every resource and data source in this module. Arrows indicate dependency order — a resource at the tail of an arrow must be fully provisioned before the resource at the head can be created.

---

## Usage

```hcl
module "windows-autoscaling" {
  source = "git::git@bitbucket.org:directvla/terraform-infrastructure-puertorico.git//modules/windows-autoscaling?ref=v1.1.0"

  # Identity & targeting
  root_compartment_id     = "<root_compartment_ocid>"
  target_compartment_name = "<target_compartment_name>"
  environment             = "dev"
  project_prefix          = "pr"
  region_prefix           = "gru.ocir.io"

  # Networking
  vcn_display_name = "<vcn_display_name>"
  subnet_display_name = {
    name = "<subnet_display_name>"
  }

  # Load balancer
  load_balancer_ip_version        = "IPV4"
  load_balancer_listener_protocol = "TCP"
  load_balancer_listener_port     = 80
  health_checker_protocol         = "TCP"
  health_checker_port             = 80
  backend_port                    = 80

  # Compute
  server_count            = 1
  custom_image_id         = "<custom_image_ocid>"
  app_server_display_name = "<app_server_display_name>"
  ocpus                   = 2
  memory_in_gbs           = 16
  boot_volume_size_in_gbs = 256
  boot_volume_vpus_per_gb = 10

  # Secrets — supply via TF_VAR_server_password or a secrets manager; never hardcode
  server_password = var.server_password

  # Database
  database_hostname = "<database_hostname>"
  database_port     = 3306

  # Tagging
  defined_tags = {
    "OverCloudGovernance.Studio"  = "CloudGods"
    "OverCloudGovernance.Product" = "terraform-infrastructure-puertorico"
    "OverCloudGovernance.Name"    = "puertorico_windows-autoscaling"
  }
}
```

> **Prerequisites:** The `null_resource.push_image` provisioner requires Docker, OCI CLI, and the environment variables `USER_EMAIL` and `OCIR_USER_AUTH_TOKEN` to be set in the shell running `terraform apply`.

---

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.14.6 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | 8.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_oci"></a> [oci](#provider\_oci) | 8.5.0 |

## Resources

| Name | Type |
|------|------|
| [null_resource.push_image](https://registry.terraform.io/providers/hashicorp/null/3.2.4/docs/resources/resource) | resource |
| [oci_autoscaling_auto_scaling_configuration.instance_pool_autoscaling](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/autoscaling_auto_scaling_configuration) | resource |
| [oci_core_instance_configuration.instance_configuration](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_instance_configuration) | resource |
| [oci_core_instance_pool.instance_pool](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_instance_pool) | resource |
| [oci_core_network_security_group.filesystem-nsg](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group.instances_nsg](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group_security_rule.filesystem_tcp_nsg_rule](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.filesystem_tcp_nsg_rule_range](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.filesystem_udp_nsg_rule](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.filesystem_udp_nsg_rule_range](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.instances_tcp_nsg_rule](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.instances_tcp_nsg_rule_range](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.instances_udp_nsg_rule](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_core_network_security_group_security_rule.instances_udp_nsg_rule_range](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/core_network_security_group_security_rule) | resource |
| [oci_events_rule.event_rule](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/events_rule) | resource |
| [oci_file_storage_export.export](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/file_storage_export) | resource |
| [oci_file_storage_export_set.export_set](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/file_storage_export_set) | resource |
| [oci_file_storage_file_system.file_system](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/file_storage_file_system) | resource |
| [oci_file_storage_filesystem_snapshot_policy.filesystem_snapshot_policy](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/file_storage_filesystem_snapshot_policy) | resource |
| [oci_file_storage_mount_target.mount_target](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/file_storage_mount_target) | resource |
| [oci_functions_application.application](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/functions_application) | resource |
| [oci_functions_function.setup_windows_server](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/functions_function) | resource |
| [oci_identity_dynamic_group.dynamic_group](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/identity_dynamic_group) | resource |
| [oci_identity_policy.allow_get_secrets](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/identity_policy) | resource |
| [oci_kms_key.key](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/kms_key) | resource |
| [oci_kms_vault.vault](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/kms_vault) | resource |
| [oci_network_load_balancer_backend_set.http_backend_set](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/network_load_balancer_backend_set) | resource |
| [oci_network_load_balancer_listener.nlb_listener](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/network_load_balancer_listener) | resource |
| [oci_network_load_balancer_network_load_balancer.nlb](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/network_load_balancer_network_load_balancer) | resource |
| [oci_vault_secret.secret](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/vault_secret) | resource |
| [oci_core_subnets.subnets](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/data-sources/core_subnets) | data source |
| [oci_core_vcns.vcns](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/data-sources/core_vcns) | data source |
| [oci_identity_compartments.compartments](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/data-sources/identity_compartments) | data source |
| [oci_objectstorage_namespace.namespace](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/data-sources/objectstorage_namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_server_display_name"></a> [app\_server\_display\_name](#input\_app\_server\_display\_name) | n/a | `string` | n/a | yes |
| <a name="input_setup_windows_server_fn_name"></a> [attach\_file\_system\_fn\_name](#input\_attach\_file\_system\_fn\_name) | n/a | `string` | `"pr_function_setup_windows_server"` | no |
| <a name="input_backend_port"></a> [backend\_port](#input\_backend\_port) | n/a | `number` | n/a | yes |
| <a name="input_boot_volume_size_in_gbs"></a> [boot\_volume\_size\_in\_gbs](#input\_boot\_volume\_size\_in\_gbs) | n/a | `number` | n/a | yes |
| <a name="input_boot_volume_vpus_per_gb"></a> [boot\_volume\_vpus\_per\_gb](#input\_boot\_volume\_vpus\_per\_gb) | n/a | `number` | n/a | yes |
| <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id) | n/a | `string` | n/a | yes |
| <a name="input_database_hostname"></a> [database\_hostname](#input\_database\_hostname) | n/a | `string` | n/a | yes |
| <a name="input_database_port"></a> [database\_port](#input\_database\_port) | n/a | `number` | n/a | yes |
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | n/a | `any` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_health_checker_port"></a> [health\_checker\_port](#input\_health\_checker\_port) | n/a | `number` | n/a | yes |
| <a name="input_health_checker_protocol"></a> [health\_checker\_protocol](#input\_health\_checker\_protocol) | n/a | `string` | n/a | yes |
| <a name="input_load_balancer_ip_version"></a> [load\_balancer\_ip\_version](#input\_load\_balancer\_ip\_version) | n/a | `string` | `"ipv4"` | no |
| <a name="input_load_balancer_listener_port"></a> [load\_balancer\_listener\_port](#input\_load\_balancer\_listener\_port) | n/a | `number` | n/a | yes |
| <a name="input_load_balancer_listener_protocol"></a> [load\_balancer\_listener\_protocol](#input\_load\_balancer\_listener\_protocol) | n/a | `string` | n/a | yes |
| <a name="input_memory_in_gbs"></a> [memory\_in\_gbs](#input\_memory\_in\_gbs) | n/a | `number` | n/a | yes |
| <a name="input_ocpus"></a> [ocpus](#input\_ocpus) | n/a | `number` | n/a | yes |
| <a name="input_project_prefix"></a> [project\_prefix](#input\_project\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_region_prefix"></a> [region\_prefix](#input\_region\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_root_compartment_id"></a> [root\_compartment\_id](#input\_root\_compartment\_id) | n/a | `string` | n/a | yes |
| <a name="input_server_count"></a> [server\_count](#input\_server\_count) | n/a | `number` | n/a | yes |
| <a name="input_server_password"></a> [server\_password](#input\_server\_password) | The plaintext value of the secret | `string` | n/a | yes |
| <a name="input_subnet_display_name"></a> [subnet\_display\_name](#input\_subnet\_display\_name) | n/a | <pre>object({<br/>    name           = string<br/>    compartment_id = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_target_compartment_name"></a> [target\_compartment\_name](#input\_target\_compartment\_name) | n/a | `string` | n/a | yes |
| <a name="input_vcn_display_name"></a> [vcn\_display\_name](#input\_vcn\_display\_name) | n/a | `string` | n/a | yes |

> **Note:** Most variables above show `n/a` in the Description column because they lack `description` fields in `variables.tf`. Consider adding descriptions to all variables — it significantly improves discoverability and makes `terraform-docs` output self-documenting without needing to read the source.

## Outputs

No outputs.
