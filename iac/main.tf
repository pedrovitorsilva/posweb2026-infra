# Arquivo principal que provisiona a máquina virtual (EC2) da aplicação.

# Busca a imagem mais recente do Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Criação da instância EC2 vinculada aos grupos de segurança e script de inicialização
resource "aws_instance" "web" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3.micro"
  key_name        = "posweb-myapp-2026"
vpc_security_group_ids = [aws_security_group.posweb_myapp_2026_sg.id]
  security_groups = ["posweb_myapp_2026"]
  user_data       = base64encode(data.template_file.user_data.rendered)

  tags = {
    Name = "HelloWorld2"
  }
}
