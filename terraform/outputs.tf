output "servers" {
  description = "Имена и адреса созданных виртуальных машин."
  value = {
    for name, server in openstack_compute_instance_v2.vm : name => {
      private_ip = openstack_networking_port_v2.vm[name].all_fixed_ips[0]
      public_ip  = openstack_networking_floatingip_v2.vm[name].address
    }
  }
}

output "ssh_commands" {
  description = "Команды подключения к виртуальным машинам."
  value = [
    for name, ip in openstack_networking_floatingip_v2.vm : "ssh ubuntu@${ip.address}"
  ]
}

output "ansible_inventory" {
  description = "Минимальный inventory для ansible/inventory/hosts.yml."
  value       = <<-YAML
all:
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ~/.ssh/id_ed25519
  children:
    gitlab:
      hosts:
        Gitlab:
          ansible_host: ${openstack_networking_floatingip_v2.vm["Gitlab"].address}
    gitlab_runner:
      hosts:
        Gitlab-runner:
          ansible_host: ${openstack_networking_floatingip_v2.vm["Gitlab-runner"].address}
    nexus:
      hosts:
        Nexus:
          ansible_host: ${openstack_networking_floatingip_v2.vm["Nexus"].address}
    aura:
      hosts:
        Aura:
          ansible_host: ${openstack_networking_floatingip_v2.vm["Aura"].address}
    keycloak:
      hosts:
        Keycloak:
          ansible_host: ${openstack_networking_floatingip_v2.vm["Keycloak"].address}
    vault:
      hosts:
        Vault:
          ansible_host: ${openstack_networking_floatingip_v2.vm["Vault"].address}
YAML
}
