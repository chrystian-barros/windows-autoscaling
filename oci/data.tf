data "oci_identity_compartments" "compartments" {
  #Required
  compartment_id = var.identity.tenancy_ocid

  #Optional
  name                      = var.identity.compartment_name
  compartment_id_in_subtree = true
}

data "oci_objectstorage_namespace" "namespace" {
  compartment_id = var.identity.tenancy_ocid
}

data "oci_core_subnets" "subnets" {
  #Required
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  #Optional
  display_name = var.network.subnet_name
  state        = "AVAILABLE"

  depends_on = [
    data.oci_identity_compartments.compartments
  ]
}

data "oci_core_vcns" "vcns" {
  #Required
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  #Optional
  display_name = var.network.vcn_name
  state        = "AVAILABLE"

  depends_on = [
    data.oci_identity_compartments.compartments
  ]
}