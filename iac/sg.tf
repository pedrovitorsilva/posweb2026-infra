# Define o Security Group da EC2 (Aplicação), controlando portas de entrada e saída.

# Criação do Security Group da aplicação
resource "aws_security_group" "posweb_myapp_2026_sg" {
  name        = "posweb_myapp_2026"
  description = "Allow MyAPP inbound traffic and all outbound traffic"
  vpc_id      = aws_default_vpc.default.id

  tags = {
    Name = "posweb_myapp_2026_sg"
  }
}

# Regra de entrada para acesso via SSH
resource "aws_vpc_security_group_ingress_rule" "posweb_myapp_2026_allow_ssh" {
  security_group_id = aws_security_group.posweb_myapp_2026_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Regra de entrada para acesso via HTTP (porta 80, Frontend)
resource "aws_vpc_security_group_ingress_rule" "posweb_myapp_2026_allow_http" {
  security_group_id = aws_security_group.posweb_myapp_2026_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Regra de entrada para acesso direto à API (porta 5000)
resource "aws_vpc_security_group_ingress_rule" "posweb_myapp_2026_allow_api" {
  security_group_id = aws_security_group.posweb_myapp_2026_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

# Regra de entrada para acesso à segunda API (porta 5001)
resource "aws_vpc_security_group_ingress_rule" "posweb_myapp_2026_allow_api2" {
  security_group_id = aws_security_group.posweb_myapp_2026_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5001
  ip_protocol       = "tcp"
  to_port           = 5001
}


# Regra de saída permitindo que a EC2 acesse qualquer destino externo
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.posweb_myapp_2026_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}