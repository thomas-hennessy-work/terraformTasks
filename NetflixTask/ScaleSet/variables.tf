variable "region" {
    description = "The region in wihc the resorce will be provisioned"
}

variable "key"{
    description = "A number to identify the resource groups"
}

variable "ResourceGroupName" {
    description = "Name of the resorce group the resorce will be contained in"
}


variable "timezone"{
    description = "timezone of the resource"
}

variable "active_hour" {
  description = "the hour starting the active period"
}
variable "active_min" {
  description = "the minuet starting the active period"
}

variable "inactive_hour" {
  description = "the hour starting the inactive period"
}
variable "inactive_min" {
  description = "the minuet starting the inactive period"
}