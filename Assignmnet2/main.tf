# Configure AWS provider
provider "aws" {
  region = "me-central-1"  # Only the region, not the availability zone
}

module "security" {
  source = "./modules/security"

  vpc_id     = module.networking.vpc_id
  env_prefix = var.env_prefix
  my_ip      = data.http.my_ip.response_body

  common_tags = var.common_tags
}

resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"
  public_key = file("terraform-key.pub")
}




# Outputs for security groups
output "nginx_sg_id" {
  value = module.security.nginx_sg_id
}

output "backend_sg_id" {
  value = module.security.backend_sg_id
}
module "backend_server_1" {
    key_name = aws_key_pair.terraform_key.key_name

  source             = "./modules/webserver"
  env_prefix         = var.env_prefix
  instance_name      = "backend"
  instance_suffix    = "1"
  instance_type      = var.instance_type
  availability_zone  = var.availability_zone
  vpc_id             = module.networking.vpc_id
  subnet_id          = module.networking.subnet_id
  security_group_id  = module.security.backend_sg_id
  public_key         = var.public_key
  script_path        = "./scripts/apache-setup.sh"
  common_tags        = local.common_tags
}
# Nginx Server
module "nginx_server" {
  source            = "./modules/webserver"
   key_name = aws_key_pair.terraform_key.key_name
  env_prefix        = var.env_prefix
  instance_name     = "nginx-proxy"
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  vpc_id            = module.networking.vpc_id
  subnet_id         = module.networking.subnet_id
  security_group_id = module.security.nginx_sg_id
  public_key        = var.public_key
  script_path       = "./scripts/nginx-setup.sh"
  instance_suffix   = "nginx"
  common_tags       = local.common_tags
}
# Backend Servers
module "backend_servers" {
  for_each = { for idx, server in local.backend_servers : server.name => server }
  
  source            = "./modules/webserver"
  
  key_name = aws_key_pair.terraform_key.key_name
  env_prefix        = var.env_prefix
  instance_name     = each.value.name
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  vpc_id            = module.networking.vpc_id
  subnet_id         = module.networking.subnet_id
  security_group_id = module.security.backend_sg_id
  public_key        = var.public_key
  script_path       = each.value.script_path
  instance_suffix   = each.value.suffix
  common_tags       = local.common_tags
}
module "networking" {
  source              = "./modules/networking"
  vpc_cidr_block      = var.vpc_cidr_block
  subnet_cidr_block   = var.subnet_cidr_block
  availability_zone   = var.availability_zone
  env_prefix          = var.env_prefix
}
