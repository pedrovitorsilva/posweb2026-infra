# Exibe o IP Público da EC2 (Para o Secret HOST)
output "ec2_public_ip" {
  description = "IP Publico da instancia EC2"
  value       = aws_instance.web.public_ip
}

# Exibe o Endpoint de conexão do Banco de Dados RDS (Para o Secret DB_HOST)
output "rds_endpoint" {
  description = "Endpoint de conexao do RDS MySQL"
  value       = aws_db_instance.myapp_db.address
}
