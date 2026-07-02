resource "oci_autoscaling_auto_scaling_configuration" "instance_pool_autoscaling" {

  # REQUIRED
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  display_name   = "${var.project.environment}-${var.autoscaling_group.compute.display_name}-autoscaling"
  defined_tags   = var.identity.defined_tags != null ? var.identity.defined_tags : null

  cool_down_in_seconds = 300
  is_enabled           = true

  # TARGET: Instance Pool
  auto_scaling_resources {
    id   = oci_core_instance_pool.instance_pool.id
    type = "instancePool"
  }

  # POLICIES
  policies {
    display_name = "${var.project.environment}-${var.autoscaling_group.compute.display_name}-cpu-autoscaling-policy"
    policy_type  = "threshold"

    capacity {
      initial = var.autoscaling_group.minimum_instance_count
      min     = var.autoscaling_group.minimum_instance_count
      max     = var.autoscaling_group.maximum_instance_count
    }

    # SCALE OUT: CPU > 70%
    rules {
      display_name = "scale-out-on-high-cpu"
      action {
        type  = "CHANGE_COUNT_BY"
        value = var.autoscaling_group.scaling_configuration.scale_out.change_count_by
      }

      metric {
        metric_type = var.autoscaling_group.scaling_configuration.scale_out.metric_type
        threshold {
          operator = var.autoscaling_group.scaling_configuration.scale_out.operator
          value    = var.autoscaling_group.scaling_configuration.scale_out.value
        }
      }
    }

    # SCALE IN: CPU < 30%
    rules {
      display_name = "scale-in-on-low-cpu"
      action {
        type  = "CHANGE_COUNT_BY"
        value = var.autoscaling_group.scaling_configuration.scale_in.change_count_by
      }

      metric {
        metric_type = var.autoscaling_group.scaling_configuration.scale_in.metric_type
        threshold {
          operator = var.autoscaling_group.scaling_configuration.scale_in.operator
          value    = var.autoscaling_group.scaling_configuration.scale_in.value
        }
      }
    }
  }
}