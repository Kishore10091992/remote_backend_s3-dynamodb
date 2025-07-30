output "vpc_id" {
 description = "vpc id"
 value = aws_vpc.rs_vpc.id
}

output "subnet_id" {
 description = "subnet id"
 value = aws_subnet.rs_subnet.id
}

output "IGW_id" {
 description = "internet gateway id"
 value = aws_inetrnet_gateway.rs_IGW.id
}

output "rt_id" {
 description = "route table id"
 value = aws_route_table.rs_route_table.id
}

output "sg_id" {
 description = "security group id"
 value = aws_security_group.rs_sg.id
}

output "keypair_public_key" {
 description = "public key from keypair"
 value = aws_key_pair.rs_keypair.public_key
}

output "ec2_instance_id" {
 description = "ec2 instance id"
 value = aws_instance.rs_ec2.id
}