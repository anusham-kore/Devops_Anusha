variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "target_group_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
