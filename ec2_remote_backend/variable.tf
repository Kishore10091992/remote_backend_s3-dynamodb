variable "aws_region" {
  description = "region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "vpc cidr block"
  type        = string
  default     = "172.168.0.0/16"
}

variable "az" {
  description = "availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "sub_cidr" {
  description = "subnet cidr"
  type        = string
  default     = "172.168.0.0/24"
}

variable "inst_type" {
  description = "instance type"
  type        = string
  default     = "t2.micro"
}

variable "route_cidr" {
  description = "cidr for route"
  type        = string
  default     = "0.0.0.0/0"
}

variable "from_port" {
  description = "sg from port"
  type        = string
  default     = "0"
}

variable "to_port" {
  description = "sg to port"
  type        = string
  default     = "0"
}

variable "sg_protocol" {
  description = "protocol for sg"
  type        = string
  default     = "-1"
}