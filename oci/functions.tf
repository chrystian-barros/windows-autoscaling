resource "oci_functions_application" "application" {
  #Required
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  display_name = "${var.environment}-${var.project_prefix}-application"
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
    "DATABASE_HOSTNAME" : "${var.database_hostname}"
    "DATABASE_PORT" : "${var.database_port}"
    "DATADOG_API_KEY" : "${oci_vault_secret.datadog_api_key.id}"
    "JENKINS_API_KEY": "${oci_vault_secret.jenkins_api_key.id}"
    "JENKINS_URL": "${var.jenkins_url}"
    "JENKINS_USERNAME": "${var.jenkins_username}"
    "POWERSHELL_MODULE_PATH": "${oci_file_storage_export.powershell_modules_export.path}"
  }

  defined_tags = var.defined_tags

  depends_on = [
    data.oci_identity_compartments.compartments,
    data.oci_core_subnets.subnets,
    oci_file_storage_mount_target.mount_target,
    oci_file_storage_export.export
  ]
}

resource "oci_functions_function" "setup_windows_server" {
  # Required
  application_id = oci_functions_application.application.id
  display_name   = var.setup_windows_server_fn_name
  memory_in_mbs  = 3072

  # Optional
  defined_tags       = var.defined_tags
  timeout_in_seconds = 300
  image              = "${var.region_prefix}/${data.oci_objectstorage_namespace.namespace.namespace}/${oci_functions_application.application.display_name}/${var.setup_windows_server_fn_name}:${local.function_version}"

  depends_on = [
    oci_functions_application.application,
    data.oci_objectstorage_namespace.namespace,
    null_resource.push_image
  ]
}