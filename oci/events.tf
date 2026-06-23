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
      function_id = oci_functions_function.initialize_instance.id
    }
  }
  compartment_id = data.oci_identity_compartments.compartments.compartments[0].id
  condition = jsonencode(
    {
      eventType = ["com.oraclecloud.computeapi.launchinstance.end"]
      data = {
        additionalDetails = {
          imageId = "${var.autoscaling_group.compute.image_id}"
        }
      }
    }
  )
  display_name = "${var.project.environment}-${var.project.prefix}-event_rule"
  is_enabled   = true
  defined_tags = var.identity.defined_tags != null ? var.identity.defined_tags : null
}