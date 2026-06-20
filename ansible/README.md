# Ansible

Ansible-плейбуки для развёртывания сервисов Aura.

## Подготовка

```bash
ansible-galaxy collection install -r requirements.yml
cp inventory/hosts.yml.example inventory/hosts.yml
cp inventory/group_vars/all.yml.example inventory/group_vars/all.yml
ansible all -m ping
```

## Запуск

```bash
ansible-playbook playbooks/site.yml --ask-vault-pass
```

Отдельный сервис можно запустить через соответствующий playbook в `playbooks/`.

## Сервисы

- GitLab
- GitLab Runner
- Nexus
- Aura
- Keycloak
- Vault
