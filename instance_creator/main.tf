# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A SINGLE EC2 INSTANCE
# This template uses runs a simple "Hello, World" web server on a single EC2 Instance
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ------------------------------------------------------------------------------

provider "aws" {
  #shared_credentials_file = "c:\\Users\\raja\\.aws\\credentials"
  #profile    = "${var.profile}"
  region     = "${var.region}"

  # This EC2 Instance has a public IP and will be accessible directly from the public Internet
 
}

#provider "aws" {
#  region = "us-east-1"
#}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SINGLE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "example" {
  # Ubuntu Server 14.04 LTS (HVM), SSD Volume Type in us-east-1
  ami = "ami-2d39803a"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "<h1>iCW Poc - Dyanmic Cloud Plateform<h1><br/>{'api-name':'Dyanmic Cloud API on Terraform', 'date': '`$date`'}" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF


   #provisioner "remote-exec" {
   #      inline = [
   #          "echo 'Hello, World1' > index.html",
   #          "nohup busybox httpd -f -p '${var.server_port}'"
   #      ]
   #}
	

  tags {
    Name = "rk-terraform-poc",
	  AutoOn= "True",
	  AutoOff= "True",
    AutoStop= "True"
  }
}

resource "aws_eip" "default" {
  instance = "${aws_instance.example.id}"
  vpc      = true
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT'S APPLIED TO THE EC2 INSTANCE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  # Inbound HTTP from anywhere
  ingress {
    #from_port = "${var.server_port}"
    from_port = "0"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------------
# I AM ROLE AND POLICY
# ---------------------------------------------
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.test_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "test_role" {
  name = "test_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}