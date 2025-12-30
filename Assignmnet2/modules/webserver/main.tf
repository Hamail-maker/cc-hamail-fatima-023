# Fetch latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 1. Key Pair
resource "aws_key_pair" "this" {
  key_name   =  var.key_name

  public_key = file(var.public_key)
}

# 2. EC2 Instance
resource "aws_instance" "this" {

  ami                         = data.aws_ami.amazon_linux.id   # ✅ FIXED
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
key_name = var.key_name


  user_data = file(var.script_path)

  # Enforce IMDSv2 (good practice)
  metadata_options {
    http_tokens = "required"
  }

  tags = merge(var.common_tags, {
    Name = "${var.env_prefix}-${var.instance_name}-${var.instance_suffix}"
  })
}
