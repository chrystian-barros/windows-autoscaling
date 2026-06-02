resource "oci_core_instance_configuration" "instance_configuration" {
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  defined_tags = var.defined_tags
  display_name = "${var.environment}-${var.app_server_display_name}-instance_config"

  instance_details {
    instance_type = "compute"

    # ✅ MUST be directly here (not under options)
    launch_details {
      compartment_id      = data.oci_identity_compartments.compartments.compartments[0].id
      display_name        = "${var.environment}-${var.app_server_display_name}-instance"
      availability_domain = "zEtg:SA-SAOPAULO-1-AD-1"
      shape               = "VM.Standard.E5.Flex"

      defined_tags = var.defined_tags

      shape_config {
        memory_in_gbs = var.memory_in_gbs
        ocpus         = var.ocpus
      }

      create_vnic_details {
        subnet_id        = data.oci_core_subnets.subnets.subnets[0].id
        assign_public_ip = false
        defined_tags     = var.defined_tags
        nsg_ids = [
          oci_core_network_security_group.instances_nsg.id
        ]
      }

      source_details {
        source_type = "image"
        image_id    = var.custom_image_id

        boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
        boot_volume_vpus_per_gb = var.boot_volume_vpus_per_gb
      }
    }
  }

  depends_on = [
    data.oci_identity_compartments.compartments,
    oci_core_network_security_group.instances_nsg
  ]
}