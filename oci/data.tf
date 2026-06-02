data "oci_identity_compartments" "compartments" {
  #Required
  compartment_id = var.root_compartment_id

  #Optional
  name                      = var.target_compartment_name
  compartment_id_in_subtree = true
}

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.root_compartment_id
}

data "oci_core_subnets" "subnets" {
  #Required
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  #Optional
  display_name = var.subnet_display_name.name
  state        = "AVAILABLE"

  depends_on = [
    data.oci_identity_compartments.compartments
  ]
}

data "oci_core_vcns" "vcns" {
  #Required
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  #Optional
  display_name = var.vcn_display_name
  state        = "AVAILABLE"

  depends_on = [
    data.oci_identity_compartments.compartments
  ]
}