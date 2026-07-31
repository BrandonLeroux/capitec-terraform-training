# capitec-terraform-training

Terraform training project that stands up an **Amazon EKS** cluster (plus its
network and IAM) in `af-south-1`, with remote state in S3 and a gated
GitHub Actions pipeline.

- **`project/`** — the deployable root module (EKS + subnet + s3 modules).
- **`project-backend/`** — one-off bootstrap of the S3 state bucket.

---

## Architecture

```mermaid
flowchart TB
  subgraph AWS["AWS account 982215135100 · af-south-1"]
    direction TB
    S3["S3 remote state<br/>lerouxbap-s3-backend<br/>versioned · dev/int/qa/prod keys"]

    subgraph VPC["VPC vpc-04afeafc…"]
      direction TB
      RT["Route table rtb-023fc…"]
      SNa["subnet az-a"]
      SNb["subnet az-b"]
      SNc["subnet az-c"]
      RT --- SNa & SNb & SNc
    end

    subgraph EKSG["EKS"]
      direction TB
      CL["Cluster · k8s 1.35<br/>authentication_mode = API"]
      NG["Managed node group<br/>t3.micro · SPOT · min1/desired2/max3"]
      SG["SG rule · NodePort 30007 ingress"]
    end

    IAMc["IAM role: cluster<br/>AmazonEKSClusterPolicy"]
    IAMn["IAM role: node<br/>WorkerNode + CNI + ECR-ro"]
    AE["Access entry (caller)<br/>→ ClusterAdmin policy"]
  end

  CL --> SNa & SNb & SNc
  NG --> CL
  NG --> IAMn
  CL --> IAMc
  AE --> CL
  SG --> CL
```

### Subnets per environment

All environments deploy into the **same VPC**, so each gets its own non-overlapping
`/24` trio (`brandon_le_roux`'s allocation, extended per environment in the root
`env_subnets` map in `participants.tf`). The `eks` module just receives `cidr_blocks`.

| Environment | Subnets (one per AZ) |
|-------------|----------------------|
| `dev` | `10.0.6.0/24`, `10.0.7.0/24`, `10.0.8.0/24` *(brandon's original block)* |
| `int` | `10.0.105.0/24`, `10.0.106.0/24`, `10.0.107.0/24` |
| `qa` | `10.0.108.0/24`, `10.0.109.0/24`, `10.0.110.0/24` |
| `prod` | `10.0.111.0/24`, `10.0.112.0/24`, `10.0.113.0/24` |

The `participants` table in `participants.tf` (34 trainees, 3 consecutive `/24`s
each, generated from a base octet) remains as the class reference allocation;
`dev` reuses `brandon_le_roux`'s entry from it.

---

## Module dependencies

```mermaid
flowchart LR
  root["root · project/<br/>calls module.eks"] --> eks["module.eks<br/>cluster, IAM, node group"]
  eks --> subnet["module.subnet<br/>subnets + RT associations"]
  s3["module.s3<br/>count vs for_each demo<br/>(not wired in)"]:::dim
  class s3 dim
  classDef dim stroke-dasharray:4,opacity:0.55
```

| Module | Purpose | Instantiated? |
|--------|---------|---------------|
| `project/` (root) | Wires everything together; owns the S3 backend + provider `default_tags` | — |
| `modules/eks` | EKS cluster, IAM roles (via `for_each`), access entry, node group, NodePort SG rule | ✅ by root |
| `modules/subnet` | One subnet per AZ + route-table associations (via `for_each`) | ✅ by `eks` |
| `modules/s3` | Standalone `count`-vs-`for_each` teaching demo | ❌ (reference only) |

---

## Remote state

The state bucket is a **chicken-and-egg bootstrap**: `project-backend/` creates
the S3 bucket first (with local state), and `project/` then uses it as its
remote backend.

```mermaid
flowchart LR
  boot["project-backend/<br/>aws_s3_bucket.terraform_state"] -->|"1 · creates (local state)"| bucket[("S3 bucket<br/>lerouxbap-s3-backend")]
  bucket -->|"2 · backend for"| proj["project/<br/>terraform init -backend-config=…"]
```

- **Backend:** S3 bucket `lerouxbap-s3-backend` — **versioned**, AES256-encrypted,
  public access fully blocked, with native state locking (`use_lockfile`). These
  are enforced by `project-backend/` so the bucket is bootstrapped correctly for
  every environment.
- **Per-environment keys:** `values/<env>/<env>.tfbackend` → `dev/`, `int/`, `qa/`,
  `prod/…terraform.tfstate` — one state file per environment (created on first apply).
- Initialise for an environment with:

  ```bash
  cd project
  terraform init -backend-config="values/dev/dev.tfbackend"
  terraform plan  -var-file="values/dev/dev.tfvars"
  ```

---

## Branch model & protection

Current branches — `main` (default) plus one per environment, all seeded from `main`:

```mermaid
flowchart LR
  main(("main<br/>default")):::p
  dev([dev]):::p
  int([int]):::p
  qa([qa]):::p
  prod([prod]):::p
  main -. seeded .-> dev & int & qa & prod
  classDef p fill:#eef,stroke:#557
```

All of the above are protected by the **`protect-environments`** ruleset:

| Rule | Effect |
|------|--------|
| Require pull request | No direct pushes; changes land via PR |
| Required approvals = **0** | Solo-friendly (GitHub blocks self-approval, so a PR + green check is the gate) |
| Required status check | **`Plan`** must pass before merge |
| Block force-push / deletion | History and branches are protected |

Feature branches (anything not listed above) are unprotected, so you branch,
push, and open a PR freely.

---

## CI/CD pipeline

`.github/workflows/terraform.yml` — **plan on the PR, apply on merge**, with the
target **environment derived from the branch** (`dev`/`int`/`qa`/`prod`; `main` → dev).

```mermaid
flowchart TD
  open["Open / update PR → env branch"] --> resolve["Resolve env from branch"]
  resolve --> plan["Plan job<br/>init · fmt · validate · plan (coloured)"]
  plan --> post["Plan posted as PR comment + run summary"]
  post --> gate{"Plan good?"}
  gate -- "merge PR (= approval)" --> merge["Merge → push to that branch"]
  gate -- "close/iterate" --> open
  merge --> apply["Apply job (that env)<br/>init · fmt · validate · apply"]
  apply --> aws[("AWS · that env's state")]
```

| Trigger | Runs | Environment |
|---------|------|-------------|
| `pull_request` → env branch | **Plan** only (comment + summary; apply skipped) | target branch |
| `push` after a merge | **Apply** only (`-auto-approve`, re-plans so never stale) | pushed branch |
| Manual `workflow_dispatch` | Plan + Apply | selected branch |
| `terraform-destroy.yml` (manual) | **Destroy** (type `destroy` to confirm) | chosen env |

Each branch uses its own `values/<env>/<env>.tfbackend` (state) and
`<env>.tfvars` (variables); the apply runs under the matching **GitHub
Environment** (`dev`/`int`/`qa`/`prod`) for per-env deployment history.
`fmt` + `validate` run immediately before every plan/apply. Merging a PR **is**
the approval. AWS auth uses the repo secrets `AWS_ACCESS_KEY_ID` /
`AWS_SECRET_ACCESS_KEY`.

---

## Key variables (`project/variables.tf`)

| Variable | Default | Purpose |
|----------|---------|---------|
| `region` | `af-south-1` | AWS region to deploy into |
| `environment` | `dev` | Selects the env's subnet block + names resources |
| `capacity_type` | `SPOT` | `ON_DEMAND` or `SPOT` (validated) |
| `surname` / `initials` | `leroux` / `bap` | Compose the `lerouxbap` resource prefix |
| `vpc_id` / `rt_id` | pre-set | Existing VPC / route table to attach to |
