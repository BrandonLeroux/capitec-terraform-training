# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Versioning & consuming a pinned module

Modules are versioned at the **repository level** via Git tags `vMAJOR.MINOR.PATCH`.
Consumers pin a module to a tag with the `?ref=` source argument:

```hcl
module "eks" {
  source = "git::https://github.com/BrandonLeroux/capitec-terraform-training.git//project/modules/eks?ref=v1.0.0"
  # ...inputs...
}
```

- **MAJOR** — backwards-incompatible module interface changes (renamed/removed variables or outputs).
- **MINOR** — backwards-compatible functionality (new optional variables, new outputs).
- **PATCH** — backwards-compatible bug fixes.

Cutting a release: tag `main` after the changes merge, e.g. `git tag -a v1.1.0 -m "v1.1.0" && git push origin v1.1.0`.

## [Unreleased]

### Changed — BREAKING (next release is a MAJOR bump → v2.0.0)
- `eks` module: replaced the `participant` input with `cidr_blocks`; the trainee
  subnet-allocation table moved to the root. Consumers must now pass CIDR blocks.

### Added
- Standard module layout: `main.tf` / `variables.tf` / `outputs.tf` / `versions.tf`
  and a `README.md` per module.
- `versions.tf` in every module (`required_version` + `required_providers`).
- `eks` module outputs (cluster name, endpoint, CA data, security group, role
  ARNs, node group name, subnet ids); root cluster outputs.
- `region` root variable (was hardcoded); descriptions on all variables.
- Visual repository `README.md`.
- CI: plan-on-PR with PR comment, apply-on-merge, manual dispatch, and a gated
  manual `terraform destroy` workflow.

## [1.0.0] - 2026-07-31

Initial release.

### Added
- `eks`, `subnet`, and `s3` Terraform modules.
- S3 remote-state backend with per-environment configs (dev / int / prod).
- Provider `default_tags`; generated per-trainee subnet allocation.
- Branch-protection ruleset across `main` and the environment branches.
