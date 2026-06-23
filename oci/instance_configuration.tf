resource "oci_core_instance_configuration" "instance_configuration" {
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  defined_tags = var.identity.defined_tags != null ? var.identity.defined_tags : null
  display_name = "${var.project.environment}-${var.autoscaling_group.compute.display_name}"

  instance_details {
    instance_type = "compute"

    launch_details {
      compartment_id      = data.oci_identity_compartments.compartments.compartments[0].id
      display_name        = "${var.project.environment}-${var.autoscaling_group.compute.display_name}-instance"
      availability_domain = var.identity.availability_domain
      shape               = "VM.Standard.E5.Flex"

      defined_tags = var.identity.defined_tags != null ? var.identity.defined_tags : null

      shape_config {
        memory_in_gbs = var.autoscaling_group.compute.memory_in_gbs
        ocpus         = var.autoscaling_group.compute.ocpus
      }

      create_vnic_details {
        subnet_id        = data.oci_core_subnets.subnets.subnets[0].id
        assign_public_ip = false
        defined_tags     = var.identity.defined_tags
        nsg_ids = [
          oci_core_network_security_group.instances_nsg.id
        ]
      }

      source_details {
        source_type = "image"
        image_id    = var.autoscaling_group.compute.image_id

        boot_volume_size_in_gbs = var.autoscaling_group.compute.boot_volume_size_in_gbs
        boot_volume_vpus_per_gb = var.autoscaling_group.compute.boot_volume_vpus_per_gb
      }
    }
  }

  depends_on = [
    data.oci_identity_compartments.compartments,
    oci_core_network_security_group.instances_nsg
  ]
}