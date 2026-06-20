variable "region" {
  description = "Пул Selectel, в котором создаются ресурсы."
  type        = string
  default     = "ru-9"
}

variable "availability_zone" {
  description = "Сегмент пула Selectel."
  type        = string
  default     = "ru-9a"
}

variable "server_name_prefix" {
  description = "Префикс имён виртуальных машин."
  type        = string
  default     = "aura"
}

variable "image_name" {
  description = "Имя публичного образа Selectel."
  type        = string
  default     = "Ubuntu 24.04 LTS 64-bit"
}

variable "vm_flavors" {
  description = "Конфигурация Selectel для каждой виртуальной машины."
  type        = map(string)
  default = {
    Gitlab        = "SL1.2-8192-64"
    Gitlab-runner = "SL1.1-2048-16"
    Nexus         = "SL1.2-8192-64"
    Aura          = "SL1.1-2048-16"
    Keycloak      = "SL1.2-4096-32"
    Vault         = "SL1.1-2048-16"
  }

  validation {
    condition = alltrue([
      for name in ["Gitlab", "Gitlab-runner", "Nexus", "Aura", "Keycloak", "Vault"] :
      contains(keys(var.vm_flavors), name)
    ])
    error_message = "vm_flavors должен содержать конфигурацию для каждой VM."
  }
}

variable "ssh_public_key_path" {
  description = "Путь к публичному SSH-ключу."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "private_subnet_cidr" {
  description = "CIDR приватной подсети."
  type        = string
  default     = "192.168.10.0/24"
}
