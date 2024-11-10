output "fleet_arn" {
  value       = aws_iam_role.cfke-controller.arn
  description = "The ARN of the IAM role for the CFKE controller. Use this when you create the Fleet for the cluster"
}