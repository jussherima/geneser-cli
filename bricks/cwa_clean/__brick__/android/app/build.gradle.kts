// flavors dev/prod — bundleId {{#bundle_id}}{{bundle_id}}{{/bundle_id}}{{^bundle_id}}{{organization}}.{{project_name}}{{/bundle_id}}
android {
  namespace = "{{#bundle_id}}{{bundle_id}}{{/bundle_id}}{{^bundle_id}}{{organization}}.{{project_name}}{{/bundle_id}}"
  flavorDimensions += "env"
  productFlavors {
    create("dev") { dimension = "env"; applicationIdSuffix = ".dev" }
    create("prod") { dimension = "env" }
  }
}
