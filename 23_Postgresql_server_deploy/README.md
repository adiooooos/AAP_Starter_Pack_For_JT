# Simple PostgreSQL Deployment

## Overview

This is a simplified playbook for deploying a single PostgreSQL instance on RHEL/CentOS hosts. It installs PostgreSQL, initializes the database, and starts the service.

## Features

- **Simple**: Single instance deployment, no complex configurations
- **OS Compatibility**: Supports RHEL 7/8/9 and CentOS 7/8/9
- **Idempotent**: Safe to run multiple times
- **No Collections Required**: Uses only built-in Ansible modules

## Prerequisites

- Ansible 2.9 or later
- Ansible control node with network access to target hosts
- Target hosts: RHEL 7/8/9 or CentOS 7/8/9
- SSH access to target hosts (password or key-based authentication)
- Sudo/root privileges on target hosts
- Internet access or configured YUM repository for PostgreSQL packages

## Files

- `postgresql_simple_deploy.yml` - Simple PostgreSQL deployment playbook
- `inventory` - Host inventory file (same as main playbook)
- `ansible.cfg` - Ansible configuration file (same as main playbook)
- `README_SIMPLE.md` - This file

## Usage

### 1. Prepare Inventory File

Edit the `inventory` file to define your target hosts:

```ini
[postgres_servers]
Test-RHEL-7.9-3

# Or use the standard inventory format:
[rhel7]
Test-RHEL-7.9-3

[rhel8]
TEST-RHEL-8.9-1

[rhel9]
ansible25.example.com

[postgres_servers:children]
rhel7
rhel8
rhel9
```

### 2. Run the Playbook

```bash
# Dry run first (recommended)
ansible-playbook postgresql_simple_deploy.yml -i inventory --check

# Execute deployment
ansible-playbook postgresql_simple_deploy.yml -i inventory
```

### 3. Verify Deployment

After execution, verify the deployment:

```bash
# Check service status
systemctl status postgresql

# Check if PostgreSQL is listening
ss -tlnp | grep 5432

# Test connection
sudo -u postgres psql -c "SELECT version();"
```

## What Gets Created

- PostgreSQL packages installed
- Database initialized at `/var/lib/pgsql/data`
- PostgreSQL service started and enabled
- Default port: 5432

## Customization

### Change PostgreSQL Port

Edit the `postgresql_port` variable in the playbook:

```yaml
vars:
  postgresql_port: 5433
```

Then update `postgresql.conf` manually after deployment.

### Change Data Directory

Edit the `postgresql_data_dir` variable in the playbook:

```yaml
vars:
  postgresql_data_dir: "/custom/path/pgsql/data"
```

## Troubleshooting

### Service fails to start

- Check PostgreSQL logs: `journalctl -u postgresql`
- Verify data directory permissions: `ls -la /var/lib/pgsql/data`
- Check if port is already in use: `ss -tlnp | grep 5432`

### Database initialization fails

- Ensure PostgreSQL packages are installed
- Check disk space: `df -h /var/lib/pgsql`
- Verify postgres user exists: `id postgres`

## Author

GCG AAP SSA Team + v3.01 20260217

## License

📜 License Type: End User License Agreement (EULA)
🔒 Authorization: Subscription-based License
