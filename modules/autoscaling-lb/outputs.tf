output "autoscaling_security_group_id" {
  value = aws_security_group.wordpress_sg.id
}


output "rendered" {
  value = data.template_file.install_wordpress.rendered
}
 
output "key_name" {
  value       = aws_key_pair.app_key.key_name
  description = "Name of SSH key"
}