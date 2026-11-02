mock_provider "aws" {
  mock_data "aws_eks_cluster" {
    defaults = {
      arn = "arn:aws:eks:us-east-1:234878555361:cluster/test-cluster"
    }
  }
  mock_data "aws_caller_identity" {
    defaults = { account_id = "234878555361" }
  }
  mock_resource "aws_route53_zone" {
    defaults = { arn = "arn:aws:route53:::hostedzone/ZTEST" }
  }
  mock_resource "aws_iam_role" {
    defaults = { arn = "arn:aws:iam::234878555361:role/test-external-dns" }
  }
}

variables {
  cluster_name = "test-cluster"
}

run "restrict_external_dns_access" {
  command = plan

  assert {
    condition = alltrue([
      for statement in jsondecode(aws_iam_role_policy.external_dns.policy).Statement :
      !contains(statement.Action, "route53:ChangeResourceRecordSets") || statement.Resource == aws_route53_zone.spacelift.arn
    ])
    error_message = "ExternalDNS must never have record-write access outside the delegated zone."
  }
  assert {
    condition = alltrue([
      for statement in jsondecode(aws_iam_role_policy.external_dns.policy).Statement :
      !contains(statement.Condition["ForAllValues:StringEquals"]["route53:ChangeResourceRecordSetsRecordTypes"], "NS")
      if contains(statement.Action, "route53:ChangeResourceRecordSets")
    ])
    error_message = "ExternalDNS must not change delegation records."
  }
  assert {
    condition = (
      jsondecode(aws_iam_role.external_dns.assume_role_policy).Statement[0].Condition.StringEquals["aws:RequestTag/kubernetes-namespace"] == "external-dns" &&
      jsondecode(aws_iam_role.external_dns.assume_role_policy).Statement[0].Condition.StringEquals["aws:RequestTag/kubernetes-service-account"] == "external-dns" &&
      jsondecode(aws_iam_role.external_dns.assume_role_policy).Statement[0].Condition.ArnEquals["aws:SourceArn"] == data.aws_eks_cluster.shared.arn
    )
    error_message = "Only the named controller in the shared cluster may assume the DNS role."
  }
}
