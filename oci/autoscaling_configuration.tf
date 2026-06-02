resource "oci_autoscaling_auto_scaling_configuration" "instance_pool_autoscaling" {

  # REQUIRED
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  display_name   = "${var.environment}-${var.app_server_display_name}-autoscaling"

  cool_down_in_seconds = 300
  is_enabled           = true

  # TARGET: Instance Pool
  auto_scaling_resources {
    id   = oci_core_instance_pool.instance_pool.id
    type = "instancePool"
  }

  # POLICIES
  policies {

    display_name = "cpu-autoscaling-policy"
    policy_type  = "threshold"

    capacity {
      initial = var.server_count
      min     = var.server_count
      max     = var.environment == "dev" ? (var.server_count * 2) : (var.server_count * 5)
    }

    # SCALE OUT: CPU > 70%
    rules {
      display_name = "scale-out-on-high-cpu"
      action {
        type  = "CHANGE_COUNT_BY"
        value = 1
      }

      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "GT"
          value    = 70
        }
      }
    }

    # SCALE IN: CPU < 30%
    rules {
      display_name = "scale-in-on-low-cpu"
      action {
        type  = "CHANGE_COUNT_BY"
        value = -1
      }

      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "LT"
          value    = 30
        }
      }
    }
  }
}