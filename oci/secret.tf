resource "oci_kms_vault" "vault" {
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  display_name   = "${var.environment}-${var.project_prefix}-app_vault"
  vault_type     = "DEFAULT"

  # tags de exemplo
  defined_tags = var.defined_tags

  depends_on = [
    data.oci_identity_compartments.compartments
  ]
}

resource "oci_kms_key" "key" {
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  display_name   = "${var.environment}-${var.project_prefix}-app_key"

  key_shape {
    algorithm = "AES"
    length    = 32
  }

  protection_mode     = "HSM"
  management_endpoint = oci_kms_vault.vault.management_endpoint
  defined_tags        = var.defined_tags

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

  secret_name = "${var.environment}-${var.project_prefix}-app_secret-${formatdate("YYYY-MM-DD-HH-mm", timestamp())}"
  description = "Password for app servers administration"

  # Conteúdo do secret (em Bundle) — use BASE64 quando enviar conteúdo bruto
  secret_content {
    content_type = "BASE64"
    content      = base64encode(var.server_password)
    name         = "1"       # nome da versão/conteúdo; opcional
    stage        = "CURRENT" # estágio; opcional
  }

  defined_tags = var.defined_tags

  depends_on = [
    data.oci_identity_compartments.compartments,
    oci_kms_key.key,
    oci_kms_vault.vault
  ]

  lifecycle {
    ignore_changes = all
  }
}

resource "oci_vault_secret" "datadog_api_key" {
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  # O Secret é armazenado no Vault e criptografado pela Key
  vault_id = oci_kms_vault.vault.id
  key_id   = oci_kms_key.key.id

  secret_name = "${var.environment}-${var.project_prefix}-datadog_api_key-${formatdate("YYYY-MM-DD-HH-mm", timestamp())}"
  description = "API Key for Datadog agent authentication and sync"

  # Conteúdo do secret (em Bundle) — use BASE64 quando enviar conteúdo bruto
  secret_content {
    content_type = "BASE64"
    content      = base64encode(var.datadog_api_key)
    name         = "1"       # nome da versão/conteúdo; opcional
    stage        = "CURRENT" # estágio; opcional
  }

  defined_tags = var.defined_tags

  depends_on = [
    data.oci_identity_compartments.compartments,
    oci_kms_key.key,
    oci_kms_vault.vault
  ]

  lifecycle {
    ignore_changes = all
  }
}

resource "oci_vault_secret" "jenkins_api_key" {
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id

  # O Secret é armazenado no Vault e criptografado pela Key
  vault_id = oci_kms_vault.vault.id
  key_id   = oci_kms_key.key.id

  secret_name = "${var.environment}-${var.project_prefix}-jenkins_api_key-${formatdate("YYYY-MM-DD-HH-mm", timestamp())}"
  description = "API Key for Jenkins service account authentication"

  # Conteúdo do secret (em Bundle) — use BASE64 quando enviar conteúdo bruto
  secret_content {
    content_type = "BASE64"
    content      = base64encode(var.jenkins_api_key)
    name         = "1"       # nome da versão/conteúdo; opcional
    stage        = "CURRENT" # estágio; opcional
  }

  defined_tags = var.defined_tags

  depends_on = [
    data.oci_identity_compartments.compartments,
    oci_kms_key.key,
    oci_kms_vault.vault
  ]

  lifecycle {
    ignore_changes = all
  }
}