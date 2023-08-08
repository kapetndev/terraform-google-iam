module "terraform_admin_project" {
  source = "git::https://github.com/kapetndev/terraform-google-project.git?ref=v0.1.0"
  name   = "terraform-admin"

  services = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ]
}

module "github_workload_identity_pool" {
  source       = "git::https://github.com/kapetndev/terraform-google-iam.git//modules/workload_identity_pool?ref=v0.1.0"
  description  = "Identity pool for GitHub"
  display_name = "GitHub"
  name         = "github-pool"
  project_id   = module.terraform_admin_project.project_id

  identity_providers = {
    github-actions = {
      attribute_condition = "assertion.repository_owner = ${var.github_organization}"
      attribute_mapping = {
        "google.subject"             = "assertion.sub",
        "attribute.actor"            = "assertion.actor",
        "attribute.repository_owner" = "assertion.repository_owner",
      }
      description  = "GitHub identity provider"
      display_name = "GitHub"
      oidc = {
        issuer_uri = "https://token.actions.githubusercontent.com"
      }
    }
  }
}

module "production_project" {
  source = "git::https://github.com/kapetndev/terraform-google-project.git?ref=v0.1.0"
  name   = "production"

  services = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sqladmin.googleapis.com",
  ]

  iam = {
    "roles/cloudsql.client" = [
      "serviceAccount:${module.cloudsql_service_account.email}",
    ]
  }
}

module "cloudsql_service_account" {
  source       = "git::https://github.com/kapetndev/terraform-google-iam.git//modules/service_account?ref=v0.1.0"
  display_name = "CloudSQL"
  name         = "cloudsql-sa"
  project_id   = module.production_project.project_id

  iam = {
    "roles/iam.workloadIdentityUser" = [
      "principalSet://iam.googleapis.com/projects/${module.terraform_admin_project.number}/locations/global/workloadIdentityPools/${module.github_workload_identity_pool.workload_identity_pool_id}/*"
    ]
  }
}
