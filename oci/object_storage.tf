resource "oci_objectstorage_bucket" "powershell_bucket" {
  # Conditional check: Validate if there is a custom function to be used or not
  count = var.autoscaling_group.scaling_configuration.initialize_instance_function.image_id == null ? 1 : 0

  #Required
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  name           = "${var.project.environment}-${var.project.prefix}-powershell_bucket"
  namespace      = data.oci_objectstorage_namespace.namespace.namespace
}

resource "oci_objectstorage_object" "powershell_template_file" {
  # Conditional check: Validate if there is a custom function to be used or not
  count = var.autoscaling_group.scaling_configuration.initialize_instance_function.image_id == null ? 1 : 0

  #Required
  bucket    = oci_objectstorage_bucket.powershell_bucket[0].name
  content   = var.autoscaling_group.scaling_configuration.initialize_instance_function.powershell_template_file
  namespace = data.oci_objectstorage_namespace.namespace.namespace
  object    = "powershell_template_file"
}