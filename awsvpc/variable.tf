variable "nvpc_cidr" {
    type = string
    default = "10.10.0.0./16"
  
}
variable "nvpc_region" {
    type = string
    default = "us-east-2"
  
}
variable "nvpc_subnet_azs" {
    type = list(string)
    default = [ "us-east-1a", "us-east-1a", "us-east-1a" ]

}
variable "nvpc_subnet_tags" {
    type = list(string)
    default = [ "web1", "app1", "db1" ]
  
}
variable "web_subnet_indexes" {
    type = list(number)
    default = [ 0 ]
  
}
variable "other_subnet_indexes" {
    type = list(number)
    default = [ 1,3 ]
  
}