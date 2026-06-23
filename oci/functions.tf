resource "oci_functions_application" "application" {
  #Required
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  display_name = "${var.project.environment}-${var.project.prefix}-application"
  defined_tags = var.identity.defined_tags != null ? var.identity.defined_tags : null
  subnet_ids = [
    data.oci_core_subnets.subnets.subnets[0].id
  ]
  network_security_group_ids = [
    oci_core_network_security_group.instances_nsg.id
  ]
  config = {
    "MOUNT_TARGET_IP" : "${oci_file_storage_mount_target.mount_target.ip_address}"
    "EXPORT_PATH" : "${oci_file_storage_export.export.path}"
    "SECRET_OCID" : "${oci_vault_secret.secret.id}"
    "POWERSHELL_MODULE_PATH" : "${oci_file_storage_export.powershell_modules_export.path}"
  }

  depends_on = [
    data.oci_identity_compartments.compartments,
    data.oci_core_subnets.subnets,
    oci_file_storage_mount_target.mount_target,
    oci_file_storage_export.export
  ]
}

resource "oci_functions_function" "initialize_instance" {
  # Required
  application_id = oci_functions_application.application.id
  display_name   = var.autoscaling_group.scaling_configuration.initialize_instance_function.display_name
  memory_in_mbs  = var.autoscaling_group.scaling_configuration.initialize_instance_function.memory_in_gbs

  # Optional
  timeout_in_seconds = var.autoscaling_group.scaling_configuration.initialize_instance_function.timeout_in_seconds
  image              = "${var.identity.region_prefix}/${data.oci_objectstorage_namespace.namespace.namespace}/${oci_functions_application.application.display_name}/${var.autoscaling_group.scaling_configuration.initialize_instance_function.display_name}:${local.function_version}"

  defined_tags = var.identity.defined_tags != null ? var.identity.defined_tags : null
  depends_on = [
    oci_functions_application.application,
    data.oci_objectstorage_namespace.namespace
  ]
}