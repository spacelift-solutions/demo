terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = ["234878555361"]
}

resource "aws_route53_zone" "spacelift" {
  name    = "spacelift.shovel-emporium.com"
  comment = "Delegated demo DNS; parent zone is managed by TheOutdoorProgrammer/configurations in Cloudflare"

  tags = {
    Project   = "spacelift-demos"
    ManagedBy = "OpenTofu"
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "zone_id" {
  value = aws_route53_zone.spacelift.zone_id
}

output "name_servers" {
  description = "Publish all four as NS records for spacelift in the Cloudflare parent zone."
  value       = sort(aws_route53_zone.spacelift.name_servers)
}
