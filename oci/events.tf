resource "oci_events_rule" "event_rule" {
  #Required
  actions {
    #Required
    actions {
      #Required
      action_type = "FAAS"
      is_enabled  = true

      #Optional
      description = "Rule to trigger serverless function to setup instances"
      function_id = oci_functions_function.setup_windows_server.id
    }
  }
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  condition = jsonencode(
    {
      eventType = ["com.oraclecloud.computeapi.launchinstance.end"]
      data = {
        additionalDetails = {
          imageId = "${var.custom_image_id}"
        }
      }
    }
  )
  display_name = "${var.environment}-${var.project_prefix}-event_rule"
  is_enabled   = true

  #Optional
  defined_tags = var.defined_tags
}