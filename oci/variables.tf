variable "identity" {
  type = object({
    tenancy_ocid        = string
    compartment_name    = string
    availability_domain = string
    region_prefix = string
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
        display_name       = string
        memory_in_gbs      = number
        timeout_in_seconds = optional(number, 300)
        main_version = number
        minor_version = number
        patch_version = number
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
}

variable "secret" {
  type = object({
    windows_server_password = string
  })
  sensitive = true
}