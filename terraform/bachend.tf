terraform {
  backend "s3" {
    bucket = "terraform-eks-cicd-2098"
    key    = "jenkins/terraform/terraform.tfstate"
    region = "eu-west-3"
  }
}

