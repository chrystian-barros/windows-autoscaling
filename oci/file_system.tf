resource "oci_file_storage_filesystem_snapshot_policy" "filesystem_snapshot_policy" {
  #Required
  availability_domain = var.identity.availability_domain
  compartment_id      = data.oci_identity_compartments.compartments.compartments[0].id

  #Optional
  defined_tags  = var.identity.defined_tags != null ? var.identity.defined_tags : null
  display_name  = "${var.project.environment}-${var.project.prefix}-app_fs_snapshot_policy"
  policy_prefix = "${var.project.environment}-${var.project.prefix}-app"

  schedules {
    #Required
    period    = "DAILY"
    time_zone = "UTC"

    #Optional
    hour_of_day = 0
  }

  depends_on = [
    data.oci_identity_compartments.compartments
  ]
}

resource "oci_file_storage_file_system" "file_system" {
  #Required
  availability_domain = var.identity.availability_domain
  compartment_id      = data.oci_identity_compartments.compartments.compartments[0].id

  #Optional
  defined_tags                  = var.identity.defined_tags != null ? var.identity.defined_tags : null
  display_name                  = "${var.project.environment}-${var.project.prefix}-app-filesystem"
  filesystem_snapshot_policy_id = oci_file_storage_filesystem_snapshot_policy.filesystem_snapshot_policy.id

  depends_on = [
    data.oci_identity_compartments.compartments,
    oci_file_storage_filesystem_snapshot_policy.filesystem_snapshot_policy
  ]
}

resource "oci_file_storage_mount_target" "mount_target" {
  #Required
  availability_domain = var.identity.availability_domain
  compartment_id      = data.oci_identity_compartments.compartments.compartments[0].id
  subnet_id           = data.oci_core_subnets.subnets.subnets[0].id

  #Optional
  defined_tags = var.identity.defined_tags != null ? var.identity.defined_tags : null
  display_name = "${var.project.environment}-${var.project.prefix}-app-mount_target"

  nsg_ids = [
    oci_core_network_security_group.filesystem-nsg.id
  ]

  depends_on = [
    data.oci_identity_compartments.compartments,
    data.oci_core_subnets.subnets,
    oci_core_network_security_group.filesystem-nsg
  ]
}

resource "oci_file_storage_export_set" "export_set" {
  #Required
  mount_target_id = oci_file_storage_mount_target.mount_target.id

  #Optional
  display_name = "${var.project.environment}-${var.project.prefix}-app-export_set"

  depends_on = [
    oci_file_storage_mount_target.mount_target
  ]
}

resource "oci_file_storage_export" "export" {
  #Required
  export_set_id  = oci_file_storage_export_set.export_set.id
  file_system_id = oci_file_storage_file_system.file_system.id
  path           = "/mounted_filesystem"

  depends_on = [
    oci_file_storage_export_set.export_set,
    oci_file_storage_file_system.file_system,
    data.oci_core_subnets.subnets
  ]

  #Optional
  export_options {
    #Required
    source = data.oci_core_subnets.subnets.subnets[0].cidr_block

    #Optional
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}

resource "oci_file_storage_export" "powershell_modules_export" {
  #Required
  export_set_id  = oci_file_storage_export_set.export_set.id
  file_system_id = oci_file_storage_file_system.file_system.id
  path           = "/powershell_modules"

  depends_on = [
    oci_file_storage_export_set.export_set,
    oci_file_storage_file_system.file_system,
    data.oci_core_subnets.subnets
  ]

  #Optional
  export_options {
    #Required
    source = data.oci_core_subnets.subnets.subnets[0].cidr_block

    #Optional
    access                         = "READ_WRITE"
    identity_squash                = "NONE"
    require_privileged_source_port = false
  }
}