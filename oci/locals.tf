locals {
  function_version = "${var.autoscaling_group.scaling_configuration.initialize_instance_function.main_version}.${var.autoscaling_group.scaling_configuration.initialize_instance_function.minor_version}.${var.autoscaling_group.scaling_configuration.initialize_instance_function.patch_version}"
}