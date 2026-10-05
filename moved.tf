# The VPC resources gained a count for create_vpc. These keep existing state
# in place on upgrade instead of replacing the stack set and its roles.

moved {
  from = aws_iam_role.AWSCloudFormationStackSetAdministrationRole
  to   = aws_iam_role.AWSCloudFormationStackSetAdministrationRole[0]
}

moved {
  from = aws_iam_role.AWSCloudFormationStackSetExecutionRole
  to   = aws_iam_role.AWSCloudFormationStackSetExecutionRole[0]
}

moved {
  from = aws_iam_role_policy.AWSCloudFormationStackSetExecutionRole_MinimumExecutionPolicy
  to   = aws_iam_role_policy.AWSCloudFormationStackSetExecutionRole_MinimumExecutionPolicy[0]
}

moved {
  from = aws_cloudformation_stack_set.cfke-vpc
  to   = aws_cloudformation_stack_set.cfke-vpc[0]
}
