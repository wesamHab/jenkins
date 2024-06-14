#using public Modules
#https://registry.terraform.io/browse/modules?provider=aws

#create VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                     = data.aws_availability_zones.azs.name
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true

  enable_dns_hostname = true

  tags = {
    Name       = var.vpc_name
    terraform  = "true"
    Enviroment = "dev"
  }

  public_subnet_tags = {
    Name = "jenkins-subnet"
  }
}


# Create Security Gruppe
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.jenkins_security_group
  description = "Security Group for Jenkins Server"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "JenkinsPort"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port    = 443
      to_port      = 443
      protocol     = "tcp"
      description  = "HTTPS"
      cidir_blocks = "0.0.0.0/0"
    },
    {
      from_port    = 80
      to_port      = 80
      protocol     = "tcp"
      description  = "HTTP"
      cidir_blocks = "0.0.0.0/0"
    },
    {
      from_port    = 22
      to_port      = 22
      protocol     = "tcp"
      description  = "SSH"
      cidir_blocks = "0.0.0.0/0"
    },
    {
      from_port    = 9000
      to_port      = 9000
      protocol     = "tcp"
      description  = "SonarQubePort"
      cidir_blocks = "0.0.0.0/0"
    }

  ]

  egress_with_cidr_blocks = [
    {
      from_port    = 0
      to_port      = 0
      protocol     = "-1"
      cidir_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "jenkins-sg"
  }
}

# Create EC2
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.jenkins_ec2_instance

  instance_type               = "t2.micro"
  ami                         = "ami-0e8a34246278c21e4"
  key_name                    = "jenkins_server_keypair"
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("../scripts/install_build_tools.sh")
  availability_zone           = data.aws_availability_zones.names[0]

  tags = {
    Name       = "jenkins-Server"
    Terraform  = "ture"
    Enviroment = "dev"
  }
}


