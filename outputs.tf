output "ec2_public_ip" {
  description = "IP pública de la instancia EC2 con los microservicios"
  value       = aws_instance.microservicios.public_ip
}
