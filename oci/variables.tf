variable "root_compartment_id" {
  type = string
}

variable "target_compartment_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_prefix" {
  type = string
}

variable "region_prefix" {
  type = string
}

variable "defined_tags" {
}

variable "app_server_display_name" {
  type = string
}

variable "custom_image_id" {
  type = string
}

variable "server_count" {
  type = number
}

variable "setup_windows_server_fn_name" {
  type    = string
  default = "pr_function_setup_windows_server"
}

variable "server_password" {
  description = "The plaintext value of the secret"
  type        = string
  sensitive   = true
}

variable "subnet_display_name" {
  type = object({
    name           = string
    compartment_id = optional(string)
  })
}

variable "vcn_display_name" {
  type = string
}

variable "ocpus" {
  type = number
}

variable "memory_in_gbs" {
  type = number
}

variable "boot_volume_size_in_gbs" {
  type = number
}

variable "boot_volume_vpus_per_gb" {
  type = number
}

variable "load_balancer_ip_version" {
  type    = string
  default = "ipv4"
  validation {
    condition     = contains(["IPV4", "IPV6"], var.load_balancer_ip_version)
    error_message = "Invalid values, valid are: \"IPV4\", \"IPV6\"."
  }
}

variable "load_balancer_listener_port" {
  type = number
}

variable "load_balancer_listener_protocol" {
  type = string
}

variable "health_checker_protocol" {
  type = string
  validation {
    condition     = contains(["TCP", "UDP"], var.health_checker_protocol)
    error_message = "Invalid values, valid are: \"TCP\", \"UDP\"."
  }
}

variable "health_checker_port" {
  type = number
}

variable "backend_port" {
  type = number
}

variable "database_hostname" {
  type = string
}

variable "database_port" {
  type = number
}

variable "main_version" {
  type = number
}

variable "patch_version" {
  type = number
}

variable "datadog_api_key" {
  type = string
  sensitive = true
}

variable "jenkins_url" {
  type = string
}

variable "jenkins_username" {
  type = string
}

variable "jenkins_api_key" {
  type = string
  sensitive = true
}