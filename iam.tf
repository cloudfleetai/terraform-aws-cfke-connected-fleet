locals {
  cloudfleet_controller_aws_accounts = {
    "staging" : "891376988818"
    "northamerica-central-1" : "891376988818",
    "europe-central-1a" : "902873844300"
  }
}


data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
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
      values   = ["cfke"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/cfke-cluster-id"
      values   = [var.cluster_id]
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
      values   = ["cfke"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/cfke-cluster-id"
      values   = [var.cluster_id]
    }
    condition {
      test     = "StringEquals"
      variable = "ec2:CreateAction"
      values   = ["RunInstances"]
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
      values   = ["cfke"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/cfke-cluster-id"
      values   = [var.cluster_id]
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
      values   = ["cfke"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/cfke-cluster-id"
      values   = [var.cluster_id]
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

  statement {
    sid    = "AllowSecurityGroupCreationTagging"
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:RequestTag/cfke-cluster-id"
      values   = [var.cluster_id]
    }
  }

  statement {
    sid    = "AllowScopedVPCActions"
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup"
    ]
    resources = [
      "arn:aws:ec2:*:*:vpc/*",
      "arn:aws:ec2:*:*:security-group/*"
    ]
  }

  statement {
    sid    = "AllowSecurityGroupManagement"
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteSecurityGroup",
      "ec2:RevokeSecurityGroupIngress"
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/cfke-cluster-id"
      values   = [var.cluster_id]
    }
  }

  statement {
    sid    = "Temporary"
    effect = "Allow"
    actions = [
      "ec2:GetSecurityGroupsForVpc",
      "ec2:GetCoipPoolUsage",
      "ec2:DescribeVpcs",
      "ec2:DescribeVpcPeeringConnections",
      "ec2:DescribeVpcClassicLink",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeRouteTables",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeInstances",
      "ec2:DescribeCoipPools",
      "ec2:DescribeClassicLinkInstances",
      "ec2:DescribeAddresses",
      "ec2:DescribeAccountAttributes",
      "cognito-idp:DescribeUserPoolClient"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AttachSecurityGroupToInstance"
    effect = "Allow"
    actions = [
      "ec2:ModifyInstanceAttribute"
    ]
    resources = [
      "arn:aws:ec2:*:*:security-group/*",
      "arn:aws:ec2:*:*:instance/*"
    ]
  }

}

data "aws_iam_policy_document" "load-balancer-management-policy" {
  statement {
    sid    = "AllowTargetGroupActionsScoped"
    effect = "Allow"
    actions = [
      "iam:CreateServiceLinkedRole",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:CreateTargetGroup"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowScopedTargetGroupActions"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:ModifyTargetGroupAttributes",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:DeleteTargetGroup",
      "ec2:DescribeVpcs",
      "ec2:DescribeInternetGateways"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowListenerActions"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:DescribeListeners",
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:CreateListener"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowLoadBalancerActions"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticLoadBalancing:DeleteLoadBalancer"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowTargetRegistration"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:DeregisterTargets"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowELBTagging"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:DescribeTags",
      "elasticloadbalancing:AddTags"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cfke-controller" {
  policy = data.aws_iam_policy_document.control-plane-policy.json
  name   = "CFKEController-${var.cluster_id}"
  tags   = local.tags
}

resource "aws_iam_policy" "cfke-load-balancer-management" {
  count  = var.attach_load_balancer_policy ? 1 : 0
  policy = data.aws_iam_policy_document.load-balancer-management-policy.json
  name   = "CFKELoadBalancerManagement-${var.cluster_id}"
  tags   = local.tags
}

resource "aws_iam_role" "cfke-controller" {
  name               = "CFKEController-${var.cluster_id}"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
  tags               = local.tags
}

resource "aws_iam_policy_attachment" "cfke-controller" {
  policy_arn = aws_iam_policy.cfke-controller.arn
  roles      = [aws_iam_role.cfke-controller.name]
  name       = "CFKEController-${var.cluster_id}"
}

resource "aws_iam_policy_attachment" "cfke-load-balancer-management" {
  count      = var.attach_load_balancer_policy ? 1 : 0
  policy_arn = aws_iam_policy.cfke-load-balancer-management[0].arn
  roles      = [aws_iam_role.cfke-controller.name]
  name       = "CFKELoadBalancerManagement-${var.cluster_id}"
}

resource "aws_iam_service_linked_role" "spot" {
  count            = var.create_spot_service_linked_role ? 1 : 0
  aws_service_name = "spot.amazonaws.com"
}
