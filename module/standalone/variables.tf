variable "region" {
  type = string
}

variable "project" {
 type= string 
}

variable "instance" {
  type = string
}

variable "apis" {
  type=list
  default=["compute.googleapis.com","servicenetworking.googleapis.com","sqladmin.googleapis.com"]
}