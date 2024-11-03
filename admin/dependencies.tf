resource "spacelift_stack_dependency" "ansible_ec2" {
  stack_id            = spacelift_stack.ansible-ec2.id
  depends_on_stack_id = spacelift_stack.ec2-stack.id
}

resource "spacelift_stack_dependency_reference" "ansible_ec2_output" {
  stack_dependency_id = spacelift_stack_dependency.ansible_ec2.id
  output_name         = "aws_instance_ip"
  input_name          = "host"