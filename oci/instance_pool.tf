resource "oci_core_instance_pool" "instance_pool" {
  #Required
  compartment_id            = data.oci_identity_compartments.compartments.compartments[0].id
  instance_configuration_id = oci_core_instance_configuration.instance_configuration.id
  placement_configurations {
    #Required
    availability_domain = "zEtg:SA-SAOPAULO-1-AD-1"

    #Optional
    primary_vnic_subnets {
      #Required
      subnet_id = data.oci_core_subnets.subnets.subnets[0].id

      #Optional
      is_assign_ipv6ip = false
    }
  }
  size = var.server_count

  #Optional
  defined_tags                    = var.defined_tags
  display_name                    = "${var.environment}-${var.app_server_display_name}-instance_pool"
  instance_display_name_formatter = "${var.environment}-${var.app_server_display_name}-$${launchCount}"
  load_balancers {
    #Required
    backend_set_name = oci_network_load_balancer_backend_set.http_backend_set.name
    load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
    port             = var.backend_port
    vnic_selection   = "PrimaryVnic"
  }

  depends_on = [
    oci_events_rule.event_rule,
    oci_core_instance_configuration.instance_configuration
  ]
}