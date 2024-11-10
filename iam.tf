locals {
  cloudfleet_controller_aws_accounts = {
    "staging" : "891376988818"
    "northamerica-central-1" : "891376988818"
  }
}


data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.cloudfleet_controller_aws_accounts[var.control_plane_region]}:role/cfke-${var.cluster_id}"
      ]
    }
  }
}

data "aws_iam_policy_document" "control-plane-policy" {
  statement {
    sid    = "AllowScopedEC2InstanceActions"
    effect = "Allow"
    actions = [
      "ec2:RunInstances"
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:spot-instances-request/*",
      "arn:aws:ec2:*:*:subnet/*",
      "arn:aws:ec2:*:*:network-interface/*",
      "arn:aws:ec2:*::image/*",
      "arn:aws:ec2:*::snapshot/*"
    ]
  }

  statement {
    sid    = "AllowScopedEC2InstanceActionsWithTags"
    effect = "Allow"
    actions = [
      "ec2:RunInstances"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ec2:*:*:network-interface/*",
      "arn:aws:ec2:*:*:spot-instances-request/*",
      "arn:aws:ec2:*:*:volume/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/cfke-managed-by"
      values = ["cfke"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/cfke-cluster-id"
      values = [var.cluster_id]
    }
  }

  statement {
    sid    = "AllowScopedResourceCreationTagging"
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*",
      "arn:aws:ec2:*:*:network-interface/*",
      "arn:aws:ec2:*:*:spot-instances-request/*",
      "arn:aws:ec2:*:*:volume/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/cfke-managed-by"
      values = ["cfke"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/cfke-cluster-id"
      values = [var.cluster_id]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values = ["RunInstances"]
    }
  }

  statement {
    sid    = "AllowScopedResourceTagging"
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/cfke-managed-by"
      values = ["cfke"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/cfke-cluster-id"
      values = [var.cluster_id]
    }
  }

  statement {
    sid    = "AllowScopedDeletion"
    effect = "Allow"
    actions = [
      "ec2:TerminateInstances"
    ]
    resources = [
      "arn:aws:ec2:*:*:instance/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/cfke-managed-by"
      values = ["cfke"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/cfke-cluster-id"
      values = [var.cluster_id]
    }
  }

  statement {
    sid    = "AllowReadActions"
    effect = "Allow"
    actions = [
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeImages",
      "ec2:DescribeInstances",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }

}

resource "aws_iam_policy" "cfke-controller" {
  policy = data.aws_iam_policy_document.control-plane-policy.json
  name = "CFKEController-${var.cluster_id}"
  tags = local.tags
}

resource "aws_iam_role" "cfke-controller" {
  name               = "CFKEController-${var.cluster_id}"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
  tags = local.tags
}

resource "aws_iam_policy_attachment" "cfke-controller" {
  policy_arn = aws_iam_policy.cfke-controller.arn
  roles = [aws_iam_role.cfke-controller.name]
  name = "CFKEController-${var.cluster_id}"
}
