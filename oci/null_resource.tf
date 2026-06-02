resource "null_resource" "push_image" {
  provisioner "local-exec" {
    command     = <<EOT
docker build --network=host --no-cache -t ${var.region_prefix}/${data.oci_objectstorage_namespace.namespace.namespace}/${oci_functions_application.application.display_name}/${var.setup_windows_server_fn_name}:${local.function_version} ./functions/setup_windows_server;
docker login ${var.region_prefix} -u "${data.oci_objectstorage_namespace.namespace.namespace}/$USER_EMAIL" -p $OCIR_USER_AUTH_TOKEN;
docker push ${var.region_prefix}/${data.oci_objectstorage_namespace.namespace.namespace}/${oci_functions_application.application.display_name}/${var.setup_windows_server_fn_name}:${local.function_version};
EOT
    working_dir = path.module
  }

  depends_on = [
    data.oci_objectstorage_namespace.namespace
  ]
}