# Terraform

Terraform-конфигурация для создания инфраструктуры Aura в Selectel Cloud.

## Запуск

```bash
source openrc.sh
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

После применения можно сгенерировать inventory для Ansible:

```bash
terraform output -raw ansible_inventory > ../ansible/inventory/hosts.yml
```

Удаление инфраструктуры:

```bash
terraform destroy
```
