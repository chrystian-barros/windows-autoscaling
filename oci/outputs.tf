output "mount_target_ip_address" {
  value       = oci_file_storage_mount_target.mount_target.ip_address
  description = "IPv4 addres of the mount target. Used to mount the file system."
}

output "file_system_path" {
  value       = oci_file_storage_export.export.path
  description = "File system path to be mounted in external systems."
}

output "powershell_file_system_path" {
  value       = oci_file_storage_export.powershell_modules_export.path
  description = "File system path for PowerShell modules and scripts."
}