/*
 * variables.tf
 * Common variables to use in various Terraform files (*.tf)
 */

# The AWS region to use for the dev environment's infrastructure
variable "region" {
  default = "us-east-1"
}

# Tags for the infrastructure
variable "tags" {
  type = map(string)
}

variable "default_tags" {
  type = map(string)
}

variable "network_name" {
}

# Network configuration

variable "instance_tenancy" {
  default = "default"
}

variable "dns_support" {
  default = true
}

variable "dns_hostnames" {
  default = true
}

variable "vpc_CIDR_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_a_CIDR_block" {
  default = "10.0.1.0/24"
}

variable "public_subnet_b_CIDR_block" {
  default = "10.0.2.0/24"
}

variable "private_subnet_a_CIDR_block" {
  default = "10.0.3.0/24"
}

variable "private_subnet_b_CIDR_block" {
  default = "10.0.4.0/24"
}

variable "destination_CIDR_block" {
  default = "0.0.0.0/0"
}

variable "ingress_CIDR_block" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "egress_CIDR_block" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "map_public_ip" {
  default = false
}

variable "enable_ipv6" {
  default = true
}

variable "single_nat_gateway" {
  default = true
}

variable "enable_nat_gateway" {
  default = false
}

variable "one_nat_gateway_per_az" {
  default = true
}

variable "enable_dns_hostnames" {
  default = true
}

variable "enable_dns_support" {
  default = true
}