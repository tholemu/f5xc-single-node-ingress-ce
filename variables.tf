variable "aws_access_key" {
    type = string
    default = "YOUR_AWS_KEY"
  
}

variable "aws_secret_key" {
    type = string
    default = "YOUR_SECRET_KEY"
}

variable "aws_region" {
    type = string
    default = "us-east-1"
}


/* F5XC Section */

variable "f5xc_ce_gateway_multi_node" {
  description = "OPTIONAL: Set to true to deploy a 3 node cluster of Customer Edges"
  type        = bool
  default     = false
}

# variable "az1" {
#   description = "OPTIONAL: AWS availability zone to deploy first Customer Edge into"
#   type        = string
# }

variable "project_prefix" {
  description = "OPTIONAL: Provide a project name prefix that will be applied"
  type        = string
  default     = "prod"
}

variable "resource_owner" {
  description = "OPTIONAL: Provide owner of the deployment for tagging purposes"
  type        = string
  default     = "754157466775"
}

# variable "ce1_outside_subnet_id" {
#   description = "REQUIRED: The AWS subnet ID for the outside subnet of Customer Edge 1"
#   type        = string
#   default     = ""
# }

# variable "ce1_inside_subnet_id" {
#   description = "REQUIRED: The AWS subnet ID for the inside subnet of Customer Edge 1"
#   type        = string
#   default     = ""
# }

# variable "outside_security_group" {
#   description = "REQUIRED: The AWS security group ID for the outside interfaces"
#   type        = string
#   default     = ""
# }

# variable "inside_security_group" {
#   description = "REQUIRED: The AWS security group ID for the inside interfaces"
#   type        = string
#   default     = ""
# }

variable "amis" {
  description = "REQUIRED: The AWS amis for the Customer Edge image"
  type        = map(any)
  # Multi-NIC
#   default = {
#     "ca-central-1"   = "ami-052252c245ff77338"
#     "af-south-1"     = "ami-0c22728f79f714ed1"
#     "ap-east-1"      = "ami-0a6cf3665c0612f91"
#     "ap-northeast-2" = "ami-01472d819351faf92"
#     "ap-southeast-2" = "ami-03ff18dfb7f90eb54"
#     "ap-south-1"     = "ami-0277ab0b4db359c93"
#     "ap-northeast-1" = "ami-0384d075a36447e2a"
#     "ap-southeast-1" = "ami-0d6463ee1e3727e84"
#     "eu-central-1"   = "ami-06d5e0073d97ecf99"
#     "eu-west-1"      = "ami-090680f491ad6d46a"
#     "eu-west-3"      = "ami-03bd7c41ca1b586a8"
#     "eu-south-1"     = "ami-0baafa10ffcd081b7"
#     "eu-north-1"     = "ami-006c465449ed98c69"
#     "eu-west-2"      = "ami-0df8a483722043a41"
#     "me-south-1"     = "ami-094efc1a78169dd7c"
#     "sa-east-1"      = "ami-07369c4b06cf22299"
#     "us-east-1"      = "ami-089311edbe1137720"
#     "us-east-2"      = "ami-01ba94b5a83adcb35"
#     "us-west-1"      = "ami-092a2a07d2d3a445f"
#     "us-west-2"      = "ami-07252e5ab4023b8cf"
#   }

    default = {
        "ca-central-1"=	"ami-0ddc009ae69986eb4"
        "af-south-1"=	"ami-0bcfb554a48878b52"
        "ap-east-1"=	"ami-03cf35954fb9084fc"
        "ap-south-1"=	"ami-099c0c7e19e1afd16"
        "ap-northeast-2"=	"ami-04f6d5781039d2f88"
        "ap-southeast-2"=	"ami-0ae68f561b7d20682"
        "ap-northeast-1"=	"ami-07dac882268159d52"
        "ap-southeast-1"=	"ami-0dba294abe676bd58"
        "eu-central-1"=	"ami-027625cb269f5d7e9"
        "eu-west-1"=	"ami-01baaca2a3b1b0114"
        "eu-west-3"=	"ami-0e1361351f9205511"
        "eu-south-1"=	"ami-00cb6474298a310af"
        "eu-north-1"=	"ami-0366c929eb2ac407b"
        "eu-west-2"=	"ami-05f5a414a42961df6"
        "me-south-1"=	"ami-0fb5db9d908d231c3"
        "sa-east-1"=	"ami-09082c4758ef6ec36"
        "us-east-1"=	"ami-0f94aee77d07b0094"
        "us-east-2"=	"ami-0660aaf7b6edaa980"
        "us-west-1"=	"ami-0cf44e35e2aecacb4"
        "us-west-2"=	"ami-0cba83d31d405a8f5"
    }
}

variable "instance_type" {
  description = "REQUIRED: The AWS instance type for the Customer Edge"
  type        = string
  default     = "t3.xlarge"
}

variable "instance_disk_size" {
  description = "OPTIONAL: The AWS disk size for the Customer Edge"
  type        = string
  default     = "40"
}
variable "sitelatitude" {
  description = "REQUIRED: Site Physical Location Latitude. See https://www.latlong.net/"
  type        = string
  default     = "39.027002"
}
variable "sitelongitude" {
  description = "REQUIRED: Site Physical Location Longitude. See https://www.latlong.net/"
  type        = string
  default     = "-77.458113"
}
variable "clustername" {
  description = "REQUIRED: Customer Edge site cluster name."
  type        = string
  default     = "prod-cluster"
}
variable "sitetoken" {
  description = "REQUIRED: Distributed Cloud Customer Edge site registration token."
  type        = string
  sensitive   = true
  default     = "YOUR_SITE_TOKEN"
}


/* ECS Section */

variable "app_count" {
    type = number
    default = 1
}