resource "oci_kms_vault" "vault" {
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  display_name   = "${var.project.environment}-${var.project.prefix}-vault"
  vault_type     = "DEFAULT"

  defined_tags = var.identity.defined_tags != null ? var.identity.defined_tags : null

  depends_on = [
    data.oci_identity_compartments.compartments
  ]
}

resource "oci_kms_key" "key" {
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  display_name   = "${var.project.environment}-${var.project.prefix}-key"

  key_shape {
    algorithm = "AES"
    length    = 32
  }

  protection_mode     = "HSM"
  management_endpoint = oci_kms_vault.vault.management_endpoint
  defined_tags   = var.identity.defined_tags != null ? var.identity.defined_tags : null

  depends_on = [
    data.oci_identity_compartments.compartments,
    oci_kms_vault.vault
  ]
}

resource "oci_vault_secret" "secret" {
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  # O Secret é armazenado no Vault e criptografado pela Key
  vault_id = oci_kms_vault.vault.id
  key_id   = oci_kms_key.key.id

  secret_name = "${var.project.environment}-${var.project.prefix}-secret-${formatdate("YYYY-MM-DD", timestamp())}"
  description = "${var.project.prefix} - Password for windows servers administration"

  # Conteúdo do secret (em Bundle) — use BASE64 quando enviar conteúdo bruto
  secret_content {
    content_type = "BASE64"
    content      = base64encode(var.secret.windows_server_password)
    name         = "1"       # nome da versão/conteúdo; opcional
    stage        = "CURRENT" # estágio; opcional
  }

  defined_tags = var.identity.defined_tags != null ? var.identity.defined_tags : null

  depends_on = [
    data.oci_identity_compartments.compartments,
    oci_kms_key.key,
    oci_kms_vault.vault
  ]

  lifecycle {
    ignore_changes = all
  }
}
