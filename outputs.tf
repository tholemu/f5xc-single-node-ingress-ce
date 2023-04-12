output "load_balancer_ip" {
  value = aws_lb.http_lb.dns_name
}

output "f5xc_ce1_eip" {
  value = aws_eip.f5xc_ce1_outside.public_ip
}

output "f5xc_ce1_outside_ip" {
  value = aws_network_interface.f5xc_ce1_outside.private_ip
} 

# output "f5xc_ce1_inside_ip" {
#   value = aws_network_interface.f5xc_ce1_inside.private_ip
# } 