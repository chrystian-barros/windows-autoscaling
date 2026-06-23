# OCI Windows Autoscaling Module

This Terraform module provisions a fully automated **Windows Server autoscaling infrastructure** on Oracle Cloud Infrastructure (OCI). It deploys an Instance Pool backed by a Network Load Balancer, CPU-based autoscaling policies, an NFS file system for shared storage, a serverless function triggered by OCI Events to initialize new instances, and a KMS Vault for secrets management (Windows admin password).

The module solves the challenge of running stateful Windows workloads at scale on OCI by combining instance pool autoscaling with event-driven post-boot configuration via OCI Functions — eliminating the need for manual setup of newly launched servers.

## Usage

```hcl
module "windows_autoscaling" {
  source = "git::git@github.com:chrystian-barros/windows-autoscaling.git//oci?ref=v1.0.0"

  identity = {
    tenancy_ocid        = "ocid1.tenancy.oc1..example"
    compartment_name    = "my-compartment"
    availability_domain = var.identity.availability_domain
    region_prefix       = "gru.ocir.io"
    tags = {
      project    = "windows-autoscaling"
      owner      = "platform-team"
      repository = "windows-autoscaling"
    }
  }

  project = {
    environment = "production"
    prefix      = "myapp"
  }

  network = {
    vcn_name         = "production-vcn"
    subnet_name      = "private-subnet"
    is_public_subnet = false
  }

  autoscaling_group = {
    minimum_instance_count = 1
    maximum_instance_count = 5

    compute = {
      display_name            = "windows-server"
      image_id                = "ocid1.image.oc1..example"
      ocpus                   = 2
      memory_in_gbs           = 16
      boot_volume_size_in_gbs = 256
      boot_volume_vpus_per_gb = 20
    }

    load_balancer = {
      ip_version              = "IPV4"
      listener_protocol       = "TCP"
      listener_port           = 443
      health_checker_protocol = "TCP"
      health_checker_port     = 443
      backend_port            = 443
    }

    scaling_configuration = {
      initialize_instance_function = {
        display_name       = "setup-windows-server"
        memory_in_gbs      = 256
        timeout_in_seconds = 300
        main_version       = 1
        minor_version      = 0
        patch_version      = 0
      }

      scale_out = {
        change_count_by = 1
        metric_type     = "CPU_UTILIZATION"
        operator        = "GT"
        value           = 70
      }

      scale_in = {
        change_count_by = -1
        metric_type     = "CPU_UTILIZATION"
        operator        = "LT"
        value           = 30
      }
    }
  }

  secret = {
    windows_server_password = var.windows_password
  }
}
```

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

## Modules

No modules.

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
| [oci_file_storage_export.powershell_modules_export](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/file_storage_export) | resource |
| [oci_file_storage_export_set.export_set](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/file_storage_export_set) | resource |
| [oci_file_storage_file_system.file_system](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/file_storage_file_system) | resource |
| [oci_file_storage_filesystem_snapshot_policy.filesystem_snapshot_policy](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/file_storage_filesystem_snapshot_policy) | resource |
| [oci_file_storage_mount_target.mount_target](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/file_storage_mount_target) | resource |
| [oci_functions_application.application](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/functions_application) | resource |
| [oci_functions_function.initialize_instance](https://registry.terraform.io/providers/oracle/oci/8.5.0/docs/resources/functions_function) | resource |
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
| <a name="input_autoscaling_group"></a> [autoscaling\_group](#input\_autoscaling\_group) | n/a | <pre>object({<br/>  minimum_instance_count = optional(number, 1)<br/>  maximum_instance_count = number<br/>  compute = object({<br/>    display_name            = string<br/>    image_id                = string<br/>    ocpus                   = number<br/>    memory_in_gbs           = number<br/>    boot_volume_size_in_gbs = number<br/>    boot_volume_vpus_per_gb = number<br/>  })<br/>  load_balancer = object({<br/>    ip_version              = optional(string, "IPV4")<br/>    listener_protocol       = optional(string, "TCP")<br/>    listener_port           = number<br/>    health_checker_protocol = optional(string, "TCP")<br/>    health_checker_port     = number<br/>    backend_port            = number<br/>  })<br/>  scaling_configuration = object({<br/>    initialize_instance_function = object({<br/>      display_name       = string<br/>      memory_in_gbs      = number<br/>      timeout_in_seconds = optional(number, 300)<br/>      main_version       = number<br/>      minor_version      = number<br/>      patch_version      = number<br/>    })<br/>    scale_out = object({<br/>      change_count_by = optional(number, 1)<br/>      metric_type     = optional(string, "CPU_UTILIZATION")<br/>      operator        = optional(string, "GT")<br/>      value           = number<br/>    })<br/>    scale_in = object({<br/>      change_count_by = optional(number, -1)<br/>      metric_type     = optional(string, "CPU_UTILIZATION")<br/>      operator        = optional(string, "LT")<br/>      value           = number<br/>    })<br/>  })<br/>})</pre> | n/a | yes |
| <a name="input_identity"></a> [identity](#input\_identity) | OCI identity variables | <pre>object({<br/>  tenancy_ocid        = string<br/>  compartment_name    = string<br/>  availability_domain = string<br/>  region_prefix       = string<br/>  tags = object({<br/>    project    = string<br/>    owner      = string<br/>    repository = string<br/>    managedBy  = optional(string, "terraform")<br/>  })<br/>  defined_tags = optional(object({}), null)<br/>})</pre> | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | OCI networking variables | <pre>object({<br/>  vcn_name         = string<br/>  subnet_name      = string<br/>  is_public_subnet = bool<br/>})</pre> | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project variables | <pre>object({<br/>  environment = string<br/>  prefix      = string<br/>})</pre> | n/a | yes |
| <a name="input_secret"></a> [secret](#input\_secret) | n/a | <pre>object({<br/>  windows_server_password = string<br/>})</pre> | n/a | yes |

> **Note:** The `autoscaling_group` and `secret` variables are missing descriptions in the source code. Consider adding `description` attributes to improve documentation clarity.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mount_target_ip"></a> [mount\_target\_ip](#output\_mount\_target\_ip) | n/a |
