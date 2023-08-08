# terraform-google-iam ![policy](https://github.com/kapetndev/terraform-google-iam/workflows/policy/badge.svg?event=push)

Terraform module to create and manage Google Cloud Platform IAM resources.

## Examples

- [workload-identity](examples/workload-identity) - Create a service account
  for a federated workload identity pool.

## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/) | >= 1.0 |

## Modules

- [service\_account](modules/service_account) - Create and manage a service
  account.
- [workload\_identity\_pool](modules/workload_identity_pool) - Create and
  manage federated workload identity pools and providers.
