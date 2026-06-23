resource "oci_network_load_balancer_network_load_balancer" "nlb" {
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  display_name   = "${var.project.environment}-${var.project.prefix}-nlb"
  subnet_id      = data.oci_core_subnets.subnets.subnets[0].id
  defined_tags   = var.identity.defined_tags != null ? var.identity.defined_tags : null

  nlb_ip_version                 = var.autoscaling_group.load_balancer.ip_version
  is_preserve_source_destination = false
  is_private                     = true

  depends_on = [
    data.oci_identity_compartments.compartments,
    data.oci_core_subnets.subnets
  ]
}

resource "oci_network_load_balancer_backend_set" "http_backend_set" {
  #Required
  health_checker {
    #Required
    protocol = var.autoscaling_group.load_balancer.health_checker_protocol

    #Optional
    port    = var.autoscaling_group.load_balancer.health_checker_port
    retries = 2
  }
  name                     = "${var.project.environment}-${var.project.prefix}-nlb_backend_set"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  policy                   = "FIVE_TUPLE"

  #Optional
  ip_version                  = var.autoscaling_group.load_balancer.ip_version
  is_fail_open                = false
  is_instant_failover_enabled = false
  is_preserve_source          = false

  depends_on = [
    oci_network_load_balancer_network_load_balancer.nlb
  ]
}

resource "oci_network_load_balancer_listener" "nlb_listener" {
  #Required
  default_backend_set_name = oci_network_load_balancer_backend_set.http_backend_set.name
  name                     = "${var.project.environment}-${var.project.prefix}-nlb_listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = var.autoscaling_group.load_balancer.listener_port
  protocol                 = var.autoscaling_group.load_balancer.listener_protocol

  #Optional
  ip_version = var.autoscaling_group.load_balancer.ip_version
}