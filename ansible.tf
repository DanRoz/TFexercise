#VARIABLES

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {
 default = "terraform"
}


#PROVIDERS

provider "aws" {
 access_key = "${var.aws_access_key}"
 secret_key = "${var.aws_secret_key}"
 region  = "us-east-2"
}

#RESOURCES

resource "aws_s3_bucket" "tfexer" {
  bucket = "terraformexercise"
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "PutFile" {
 bucket = "${aws_s3_bucket.tfexer.id}"
 key    = "1.gif"
 source = "/home/ubuntu/Downloads/1.gif"
 acl    = "public-read"
}


resource "aws_instance" "nginx" {
 ami = "ami-0f65671a86f061fcd"
 instance_type = "t2.micro"
 key_name = "${var.key_name}"

 connection {
  user = "ubuntu"
  private_key = "${file(var.private_key_path)}"
 }
 provisioner "file" {
  source      = "/home/ubuntu/AnsibleTerraform/install-nginx.yaml"
  destination = "/tmp/install-nginx.yaml"
 }

 provisioner "remote-exec" {
  inline = [
   "sudo apt-get update",
   "sudo apt-get update",
   "sudo apt-get install ansible -y",
   "sudo ansible-playbook /tmp/install-nginx.yaml"
   
  ]
 }
}

#OUTPUT

output "aws_instance_public_dns" {
 value = "${aws_instance.nginx.public_dns}"
}

