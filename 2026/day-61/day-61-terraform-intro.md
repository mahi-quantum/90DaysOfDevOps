# Day 61 — Introduction to Terraform and My First AWS Infrastructure

Today I started my Infrastructure as Code (IaC) journey with Terraform. I created an S3 bucket and an EC2 instance on AWS using code, modified a tag, and then destroyed everything with a single command.

---

## 1. Infrastructure as Code (IaC) — in my own words

Infrastructure as Code means defining cloud resources (servers, networks, storage) by writing code in a file (`.tf`) instead of clicking through the AWS console manually. We declare "what we want" in the file, and Terraform provisions it.

It matters in DevOps because infrastructure becomes repeatable, version-controlled, and consistent — the same code builds the same setup every time without manual mistakes, Git tracks who changed what, and human error from manual clicking is eliminated.

What problems IaC solves (manual vs IaC):
- Manual: build each resource by hand, repeat every time. IaC: one command.
- Manual: higher chance of human error. IaC: predictable and consistent.
- Manual: no record of who did what. IaC: full history in Git.
- Manual: setup must be documented separately. IaC: the code is the documentation.

Terraform vs other tools:
- Terraform — provisions infrastructure, declarative, multi-cloud (AWS, Azure, GCP).
- CloudFormation — similar to Terraform, but AWS-only.
- Ansible — primarily a configuration management tool (software setup inside servers); it can provision infra too, but that's not its main strength.
- Pulumi — like Terraform, but you write in real programming languages (Python/JS) instead of a DSL.

Declarative and Cloud-agnostic:
- Declarative — we state the desired end result; Terraform figures out how to reach it.
- Cloud-agnostic — one tool works across different cloud providers.

---

## 2. Setup (Task 2)

Installed both Terraform and AWS CLI on my WSL (Ubuntu) machine.

    terraform -version              # Terraform v1.16.5
    aws --version                   # aws-cli/2.37.9
    aws sts get-caller-identity     # verify Account ID + ARN

Note: The assignment used region ap-south-1, but I used us-west-2 because my AWS access and the rest of my setup were in that region. The AMI was also chosen for us-west-2.

---

## 3. First Config — S3 Bucket (Task 3)

I organized the code into two files (professional structure):

provider.tf

    terraform {
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }

    provider "aws" {
      region = "us-west-2"
    }

main.tf

    resource "aws_s3_bucket" "my_bucket" {
      bucket = "terraweek-mahi-2026"
    }

Lifecycle:

    terraform init      # download the AWS provider plugin
    terraform plan      # preview what will be created
    terraform apply     # create (confirm with yes)

What did terraform init download?
init downloaded the AWS provider plugin (hashicorp/aws v5.x) and created a hidden .terraform/ folder to store it. It also created .terraform.lock.hcl, which locks the exact provider version so the same version is used every time.

What does the .terraform/ directory contain?
The downloaded provider plugins (binaries).

Verified the bucket terraweek-mahi-2026 in the us-west-2 (Oregon) region in the console.

---

## 4. EC2 Instance (Task 4)

Instead of hardcoding the AMI, I used a data block so the latest Ubuntu AMI is fetched automatically. AMI IDs change per region, so this is the best practice.

    data "aws_ami" "ubuntu" {
      most_recent = true
      owners      = ["099720109477"]   # Canonical (Ubuntu)

      filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-*/ubuntu-*-24.04-amd64-server-*"]
      }
    }

    resource "aws_instance" "my_server" {
      ami           = data.aws_ami.ubuntu.id   # interpolation
      instance_type = "t2.micro"

      tags = {
        Name = "TerraWeek-Day1"
      }
    }

    terraform plan      # Plan: 1 to add (only EC2; bucket already exists)
    terraform apply

Verified the instance TerraWeek-Day1 (t2.micro, running) in the console.

How does Terraform know the bucket already exists and only the EC2 needs creating?
Terraform reads the state file (terraform.tfstate). The bucket was already recorded in state, so the plan showed only the new EC2 as "to add". State tells Terraform what the code wants vs what already exists on AWS.

---

## 5. State File (Task 5)

    terraform state list
    terraform state show aws_s3_bucket.my_bucket
    terraform state show aws_instance.my_server
    terraform show

state list showed aws_instance.my_server and aws_s3_bucket.my_bucket. (data.aws_ami.ubuntu did not appear because a data source is a lookup, not a managed resource.)

What does the state file store?
Each resource's real details — its AWS id, all the attributes AWS assigned after creation, and the mapping between the code (desired state) and reality (actual state).

Why should you never manually edit the state file?
It would corrupt Terraform's internal bookkeeping — state and actual AWS infrastructure would drift out of sync, causing plan/apply to behave incorrectly.

Why should the state file not be committed to Git?
It can contain secrets/sensitive data (risk of leaks), and it changes on every apply (noise and team conflicts). That's why I added *.tfstate to .gitignore.

---

## 6. Modify & Destroy (Task 6)

Changed the tag TerraWeek-Day1 -> TerraWeek-Modified, then ran plan:

    ~ "Name" = "TerraWeek-Day1" -> "TerraWeek-Modified"
    Plan: 0 to add, 1 to change, 0 to destroy.

Plan symbols:
- `+`   create
- `-`   destroy
- `~`   update in-place (changes without destroying)
- `-/+` destroy and recreate

Here it was `~` → an in-place update, not a recreate. The instance ID stayed the same, only the tag changed: Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

Then destroyed everything:

    terraform destroy    # Plan: 2 to destroy → yes
    # Destroy complete! Resources: 2 destroyed.

Verified in the console — both the bucket and the EC2 instance were gone. (Always run destroy after practice so AWS doesn't keep charging.)

---

## Terraform Commands — summary

- terraform init       — setup + download provider plugins
- terraform plan       — preview what will change (creates nothing)
- terraform apply      — create/update resources
- terraform destroy    — destroy managed resources
- terraform show       — show current state in readable form
- terraform state list — list all managed resources
- terraform fmt        — auto-format the code
- terraform validate   — syntax check (without connecting to AWS)

---

## State file — what it contains and why it matters

terraform.tfstate holds each managed resource's real details (IDs, attributes) and the mapping between code and reality. It's what tells Terraform "what already exists" — from this it decides what to add/change/destroy on the next apply. Without state, Terraform wouldn't know what it is managing.

---

## Screenshots

- terraform apply — creating the S3 bucket + EC2
- AWS S3 console — bucket terraweek-mahi-2026
- AWS EC2 console — instance TerraWeek-Day1 running
- Tag modified — TerraWeek-Modified
- terraform destroy — resources destroyed

(Add screenshots to an images folder and link them: ![apply](images/apply.png))

---

#90DaysOfDevOps #TerraWeek #DevOpsKaJosh #TrainWithShubham
