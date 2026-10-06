resource "aws_s3_bucket" "my_bucket" {
  bucket = "terraweek-mahi-2026"
}
resource "aws_instance" "my_server" {
  ami           = "ami-06ae3f109543885fa"
  instance_type = "t2.micro"
  tags = { Name = "TerraWeek-Modified"}
}
