# capitec-terraform-training

Terraform training project (EKS cluster + S3 state backend) for the
Capitec Terraform training exercise.

## Layout
- `project/` — EKS cluster with `subnet`, `eks` and `s3` modules; per-env
  values under `values/<env>/`.
- `project-backend/` — S3 state-backend bootstrap.

## CI
Pull requests into `main`/`dev`/`int`/`qa`/`prod` run `terraform plan`;
applying to AWS then waits for approval via the `aws-apply` environment.
