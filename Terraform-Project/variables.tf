variable "region" {
  default = "us-east-1"
}

variable "zone_id" {
  description = "Hosted zone ID for Route53 record creation."
  type        = string
}

variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
  default     = "platform"
}

variable "environment" {
  description = "Environment name such as dev, stage, or prod."
  type        = string
  default     = "prod"
}

variable "route53_record_name" {
  description = "DNS record name to create in Route53."
  type        = string
  default     = "app-services"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks."
  type        = list(string)
  default     = ["10.10.0.0/19", "10.10.32.0/19", "10.10.64.0/19"]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks."
  type        = list(string)
  default     = ["10.10.96.0/19", "10.10.128.0/19", "10.10.160.0/19"]
}

variable "azs" {
  description = "Availability zones for subnet placement."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "prod-eks"
}

variable "node_group_name" {
  description = "EKS managed node group name."
  type        = string
  default     = "prod-nodes"
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 3
}

variable "common_tags" {
  description = "Common tags applied to supported resources."
  type        = map(string)
  default = {
    Project     = "Terraform-Project"
    ManagedBy   = "Terraform"
    Environment = "prod"
  }
}
