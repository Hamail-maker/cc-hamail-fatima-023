[frontend]
{{ frontend_ip }}

[backends]
%{ for ip in backend_ips ~}
{{ ip }}
%{ endfor ~}

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_ed25519
