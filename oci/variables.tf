variable "identity" {
  type = object({
    tenancy_ocid        = string
    compartment_name    = string
    availability_domain = string
    region_prefix       = string
    tags = object({
      project    = string
      owner      = string
      repository = string
      managedBy  = optional(string, "terraform")
    })
    defined_tags = optional(object({}), null)
  })
  description = "OCI identity variables"
}

variable "project" {
  type = object({
    environment = string
    prefix      = string
  })
  description = "Project variables"
  sensitive   = false
}

variable "network" {
  type = object({
    vcn_name         = string
    subnet_name      = string
    is_public_subnet = bool
  })
  description = "OCI networking variables"
  sensitive   = false
}

variable "autoscaling_group" {
  type = object({
    minimum_instance_count = optional(number, 1)
    maximum_instance_count = number
    compute = object({
      display_name            = string
      image_id                = string
      ocpus                   = number
      memory_in_gbs           = number
      boot_volume_size_in_gbs = number
      boot_volume_vpus_per_gb = number
    })
    load_balancer = object({
      ip_version              = optional(string, "IPV4")
      listener_protocol       = optional(string, "TCP")
      listener_port           = number
      health_checker_protocol = optional(string, "TCP")
      health_checker_port     = number
      backend_port            = number
    })
    scaling_configuration = object({
      initialize_instance_function = object({
        image_id                 = optional(string, null)
        display_name             = string
        memory_in_gbs            = optional(number, 3072)
        timeout_in_seconds       = optional(number, 300)
        main_version             = optional(number, null)
        minor_version            = optional(number, null)
        patch_version            = optional(number, null)
        powershell_template_file = optional(string, null)
      })
      scale_out = object({
        change_count_by = optional(number, 1)
        metric_type     = optional(string, "CPU_UTILIZATION")
        operator        = optional(string, "GT")
        value           = number
      })
      scale_in = object({
        change_count_by = optional(number, -1)
        metric_type     = optional(string, "CPU_UTILIZATION")
        operator        = optional(string, "LT")
        value           = number
      })
    })
  })
  description = "Launch details for the autoscaling group components"

  # If image_id is null, other values must not be null
  validation {
    condition = (
      var.autoscaling_group.scaling_configuration.initialize_instance_function.image_id != null
      || (
        var.autoscaling_group.scaling_configuration.initialize_instance_function.main_version != null
        && var.autoscaling_group.scaling_configuration.initialize_instance_function.minor_version != null
        && var.autoscaling_group.scaling_configuration.initialize_instance_function.patch_version != null
        && var.autoscaling_group.scaling_configuration.initialize_instance_function.powershell_template_file != null
      )
    )
    error_message = <<EOT
The following values must be not null when image_id is null:
  main_version
  minor_version
  patch_version
  powershell_template_file
EOT
  }

  # If image_id is not null, other values must be null (they'll be ignored)
  validation {
    condition = (
      var.autoscaling_group.scaling_configuration.initialize_instance_function.image_id == null
      || (
        var.autoscaling_group.scaling_configuration.initialize_instance_function.main_version == null
        && var.autoscaling_group.scaling_configuration.initialize_instance_function.minor_version == null
        && var.autoscaling_group.scaling_configuration.initialize_instance_function.patch_version == null
        && var.autoscaling_group.scaling_configuration.initialize_instance_function.powershell_template_file == null
      )
    )
    error_message = <<EOT
The following values must be null when image_id is not null:
  main_version
  minor_version
  patch_version
  powershell_template_file
EOT
  }
}

variable "secret" {
  type = object({
    windows_server_password = string
  })
  sensitive   = true
  description = "Secrets used in this module"
}