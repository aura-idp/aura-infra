locals {
  vm_names = toset(["Gitlab", "Gitlab-runner", "Nexus", "Aura", "Keycloak", "Vault"])
}

data "openstack_networking_network_v2" "external" {
  external = true
}

data "openstack_images_image_v2" "ubuntu" {
  name        = var.image_name
  most_recent = true
  visibility  = "public"
}

data "openstack_compute_flavor_v2" "vm" {
  for_each = toset(values(var.vm_flavors))
  name     = each.value
}

resource "openstack_compute_keypair_v2" "ssh" {
  name       = "${var.server_name_prefix}-key"
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "openstack_networking_network_v2" "private" {
  name           = "${var.server_name_prefix}-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "private" {
  name       = "${var.server_name_prefix}-subnet"
  network_id = openstack_networking_network_v2.private.id
  cidr       = var.private_subnet_cidr
  ip_version = 4
}

resource "openstack_networking_router_v2" "router" {
  name                = "${var.server_name_prefix}-router"
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "private" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.private.id
}

resource "openstack_networking_secgroup_v2" "vm" {
  name        = "${var.server_name_prefix}-vm"
  description = "SSH and traffic between Aura virtual machines"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  security_group_id = openstack_networking_secgroup_v2.vm.id
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "internal" {
  security_group_id = openstack_networking_secgroup_v2.vm.id
  direction         = "ingress"
  ethertype         = "IPv4"
  remote_ip_prefix  = var.private_subnet_cidr
}

resource "openstack_networking_port_v2" "vm" {
  for_each           = local.vm_names
  name               = "${each.key}-port"
  network_id         = openstack_networking_network_v2.private.id
  security_group_ids = [openstack_networking_secgroup_v2.vm.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.private.id
  }
}

resource "openstack_compute_instance_v2" "vm" {
  for_each          = local.vm_names
  name              = each.key
  image_id          = data.openstack_images_image_v2.ubuntu.id
  flavor_id         = data.openstack_compute_flavor_v2.vm[var.vm_flavors[each.key]].id
  key_pair          = openstack_compute_keypair_v2.ssh.name
  availability_zone = var.availability_zone

  network {
    port = openstack_networking_port_v2.vm[each.key].id
  }

  vendor_options {
    ignore_resize_confirmation = true
  }

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_networking_floatingip_v2" "vm" {
  for_each = local.vm_names
  pool     = data.openstack_networking_network_v2.external.name
}

resource "openstack_networking_floatingip_associate_v2" "vm" {
  for_each    = local.vm_names
  floating_ip = openstack_networking_floatingip_v2.vm[each.key].address
  port_id     = openstack_networking_port_v2.vm[each.key].id

  depends_on = [openstack_networking_router_interface_v2.private]
}
