/**
This section creates the VPC using a StackSet in multiple regions.
StackSet is used for the actual VPC deployment as Terraform's multi regions support is not the best.
*/

data "aws_regions" "all" {
  all_regions = false
  /*
  filter {
    name = "region-name"
    values = [
      "us-east-1",
      "eu-central-1"
    ]
  }
   */
}

data "aws_regions" "not_opted_in" {
  all_regions = false
  filter {
    name   = "opt-in-status"
    values = ["not-opted-in"]
  }
}

// StackSet Administration Role
data "aws_iam_policy_document" "AWSCloudFormationStackSetAdministrationRole_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = concat(
        ["cloudformation.amazonaws.com"],

        # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/stacksets-prereqs.html#stacksets-opt-in-regions
        [for region in data.aws_regions.not_opted_in.names : "cloudformation.${region}.amazonaws.com"]
      )
      type = "Service"
    }
  }
}

resource "aws_iam_role" "AWSCloudFormationStackSetAdministrationRole" {
  assume_role_policy = data.aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_assume_role_policy.json
  name_prefix        = "CFKEStackSetAdministrationRole"
  tags               = local.tags

}


// Execution Role
data "aws_iam_policy_document" "AWSCloudFormationStackSetExecutionRole_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = [aws_iam_role.AWSCloudFormationStackSetAdministrationRole.arn]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role" "AWSCloudFormationStackSetExecutionRole" {
  assume_role_policy = data.aws_iam_policy_document.AWSCloudFormationStackSetExecutionRole_assume_role_policy.json
  name_prefix        = "CFKEStackSetExecutionRole-"
  tags               = local.tags
}

data "aws_iam_policy_document" "AWSCloudFormationStackSetExecutionRole_MinimumExecutionPolicy" {
  statement {
    actions = [
      "cloudformation:*",
    ]
    effect    = "Allow"
    resources = ["*"]
  }


  statement {
    actions = [
      "ec2:CreateTags"
    ]

    resources = [
      "arn:aws:ec2:*:*:vpc/*",
      "arn:aws:ec2:*:*:internet-gateway/*",
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:subnet/*",
      "arn:aws:ec2:*:*:route-table/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/cfke-cluster-id"
      values = [
        var.cluster_id
      ]
    }

  }

  statement {
    actions = [
      "ec2:CreateVpc",
      "ec2:CreateSecurityGroup",
      "ec2:CreateInternetGateway",
      "ec2:CreateSubnet",
      "ec2:CreateRouteTable",

      "ec2:DescribeVpcs",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeRouteTables",
      "ec2:CreateRoute"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ec2:ModifyVpcAttribute",
      "ec2:ModifySubnetAttribute",
      "ec2:DeleteVpc",
      "ec2:AttachInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteSubnet",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:CreateRoute",
      "ec2:DeleteRoute"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/cfke-cluster-id"
      values = [
        var.cluster_id
      ]
    }
  }

}


resource "aws_iam_role_policy" "AWSCloudFormationStackSetExecutionRole_MinimumExecutionPolicy" {
  name_prefix = "CFKEStackSetExecutionRole-"
  policy      = data.aws_iam_policy_document.AWSCloudFormationStackSetExecutionRole_MinimumExecutionPolicy.json
  role        = aws_iam_role.AWSCloudFormationStackSetExecutionRole.name
}

resource "aws_cloudformation_stack_set" "cfke-vpc" {
  administration_role_arn = aws_iam_role.AWSCloudFormationStackSetAdministrationRole.arn
  execution_role_name     = aws_iam_role.AWSCloudFormationStackSetExecutionRole.name
  name                    = "cfke-vpc-${var.cluster_id}"

  parameters = {
    ClusterId     = var.cluster_id
    VPCCidr       = var.vpc_cidr_block
    SubnetNetMask = 13
  }

  template_body = file("${path.module}/cloudformation/vpc.yaml")
  managed_execution {
    active = true
  }
  operation_preferences {
    region_concurrency_type = "PARALLEL"
    max_concurrent_count    = 10
  }
}

resource "aws_cloudformation_stack_set_instance" "cfke-vpc" {
  depends_on     = [aws_iam_role_policy.AWSCloudFormationStackSetExecutionRole_MinimumExecutionPolicy]
  for_each       = toset(data.aws_regions.all.names)
  stack_set_name = aws_cloudformation_stack_set.cfke-vpc.name
  region         = each.key
}
