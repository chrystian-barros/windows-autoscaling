### Network Security Groups
resource "oci_core_network_security_group" "instances_nsg" {
  #Required
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  vcn_id         = data.oci_core_vcns.vcns.virtual_networks[0].id
  display_name   = "${var.project.environment}-${var.project.prefix}-app_server-nsg"
  defined_tags   = var.identity.defined_tags != null ? var.identity.defined_tags : null

  depends_on = [
    data.oci_identity_compartments.compartments,
    data.oci_core_vcns.vcns
  ]
}

### Rules for Instances NSG
resource "oci_core_network_security_group_security_rule" "instances_tcp_nsg_rule" {
  #Required
  network_security_group_id = oci_core_network_security_group.instances_nsg.id
  direction                 = "EGRESS"
  protocol                  = 6 # ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")

  #Optional
  description      = "NSG to allow egress traffic from instances to File System"
  destination      = oci_core_network_security_group.filesystem-nsg.id
  destination_type = "NETWORK_SECURITY_GROUP"

  tcp_options {
    destination_port_range {
      min = 111
      max = 111
    }
  }

  depends_on = [
    oci_core_network_security_group.filesystem-nsg,
    oci_core_network_security_group.instances_nsg
  ]
}

resource "oci_core_network_security_group_security_rule" "instances_tcp_nsg_rule_range" {
  #Required
  network_security_group_id = oci_core_network_security_group.instances_nsg.id
  direction                 = "EGRESS"
  protocol                  = 6 # ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")

  #Optional
  description      = "NSG to allow egress traffic from instances to File System"
  destination      = oci_core_network_security_group.filesystem-nsg.id
  destination_type = "NETWORK_SECURITY_GROUP"

  tcp_options {
    destination_port_range {
      min = 2048
      max = 2050
    }
  }

  depends_on = [
    oci_core_network_security_group.filesystem-nsg,
    oci_core_network_security_group.instances_nsg
  ]
}

resource "oci_core_network_security_group_security_rule" "instances_udp_nsg_rule" {
  #Required
  network_security_group_id = oci_core_network_security_group.instances_nsg.id
  direction                 = "EGRESS"
  protocol                  = 17 # ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")

  #Optional
  description      = "NSG to allow egress traffic from instances to File System"
  destination      = oci_core_network_security_group.filesystem-nsg.id
  destination_type = "NETWORK_SECURITY_GROUP"

  udp_options {
    destination_port_range {
      min = 111
      max = 111
    }
  }

  depends_on = [
    oci_core_network_security_group.filesystem-nsg,
    oci_core_network_security_group.instances_nsg
  ]
}

resource "oci_core_network_security_group_security_rule" "instances_udp_nsg_rule_range" {
  #Required
  network_security_group_id = oci_core_network_security_group.instances_nsg.id
  direction                 = "EGRESS"
  protocol                  = 17 # ICMP ("1"), TCP ("6"), UDP ("17"), and ICMPv6 ("58")

  #Optional
  description      = "NSG to allow egress traffic from instances to File System"
  destination      = oci_core_network_security_group.filesystem-nsg.id
  destination_type = "NETWORK_SECURITY_GROUP"

  udp_options {
    destination_port_range {
      min = 2048
      max = 2048
    }
  }

  depends_on = [
    oci_core_network_security_group.filesystem-nsg,
    oci_core_network_security_group.instances_nsg
  ]
}