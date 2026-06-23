resource "oci_identity_dynamic_group" "dynamic_group" {
  compartment_id = var.identity.tenancy_ocid
  name           = "${var.project.environment}-${var.project.prefix}-dynamic_group"
  description    = "Group for the serverless functions"
  matching_rule  = "ALL {resource.type = 'fnfunc', resource.compartment.id = '${data.oci_identity_compartments.compartments.compartments[0].id}'}"

  depends_on = [
    data.oci_identity_compartments.compartments
  ]
}

resource "oci_identity_policy" "allow_get_secrets" {
  compartment_id = var.identity.tenancy_ocid
  name           = "${var.project.environment}-${var.project.prefix}-secret_policy"
  description    = "Policy allowing dynamic group ${oci_identity_dynamic_group.dynamic_group.name} to retrieve secret content"
  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.dynamic_group.name} to use keys in compartment id ${data.oci_identity_compartments.compartments.compartments[0].id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.dynamic_group.name} to read secret-bundles in compartment id ${data.oci_identity_compartments.compartments.compartments[0].id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.dynamic_group.name} to inspect vnic-attachments in compartment id ${data.oci_identity_compartments.compartments.compartments[0].id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.dynamic_group.name} to inspect instance-family in compartment id ${data.oci_identity_compartments.compartments.compartments[0].id}",
    "Allow dynamic-group ${oci_identity_dynamic_group.dynamic_group.name} to read virtual-network-family in compartment id ${data.oci_identity_compartments.compartments.compartments[0].id}"
  ]

  depends_on = [
    oci_identity_dynamic_group.dynamic_group,
    data.oci_identity_compartments.compartments
  ]
}