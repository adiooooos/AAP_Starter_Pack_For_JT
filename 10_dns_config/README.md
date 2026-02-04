# Linux DNS Automation (Unbound + BIND)

## Overview

This Ansible Role-based solution provides automated DNS server deployment and management across multiple Linux hosts. It enables deployment of:

- **Unbound** as a caching DNS resolver
- **BIND (named)** as a **Primary (Master)** authoritative DNS server
- **BIND (named)** as a **Secondary (Slave)** authoritative DNS server

The implementation follows AAP Starter Pack guidelines with FQDN modules, OS compatibility assertions, robust error handling, and clear debugging support.

## Features

- **Role-Based Architecture**: Modular, reusable, and maintainable design
- **OS Compatibility**: Supports RHEL 7/8/9, CentOS 7/8/9, Rocky Linux 8/9, AlmaLinux 8/9, and Oracle Linux 7/8/9
- **Template-Based Configuration**: Unbound uses Jinja2 templates for dynamic configuration
- **File-Based Configuration**: BIND uses static configuration files for simplicity and clarity
- **Comprehensive Validation**: OS compatibility checks and parameter validation
- **Error Handling**: Robust error handling with `block-rescue` for critical changes
- **Firewall Management**: Automatic firewalld configuration for DNS service
- **SELinux Support**: Proper SELinux context settings for configuration files

## Files

- `deploy_unbound_site.yml` - Main playbook for Unbound caching DNS deployment
- `deploy_bind_primary_site.yml` - Main playbook for BIND Primary DNS deployment
- `deploy_bind_secondary_site.yml` - Main playbook for BIND Secondary DNS deployment
- `roles/unbound_caching_dns/` - Unbound caching DNS role
  - `defaults/main.yml` - Default variables (template parameters)
  - `tasks/main.yml` - Core role tasks
  - `handlers/main.yml` - Service restart handlers
  - `templates/server.conf.j2` - Jinja2 template for Unbound configuration
- `roles/bind_primary_dns/` - BIND Primary DNS role
  - `defaults/main.yml` - Default variables
  - `tasks/main.yml` - Core role tasks
  - `handlers/main.yml` - Service restart/reload handlers
  - `files/named-primary.conf` - BIND Primary configuration file
  - `files/zones/` - Zone files directory
    - `pvt.example.com.zone` - Forward zone file
    - `10.62.168.192.in-addr.arpa.zone` - Reverse zone file
- `roles/bind_secondary_dns/` - BIND Secondary DNS role
  - `defaults/main.yml` - Default variables
  - `tasks/main.yml` - Core role tasks
  - `handlers/main.yml` - Service restart handlers
  - `files/named-secondary.conf` - BIND Secondary configuration file
- `README.md` - This file

## Prerequisites

- Ansible 2.9 or later
- Ansible control node with network access to target hosts
- Target hosts: RHEL 7/8/9, CentOS 7/8/9, Rocky Linux 8/9, AlmaLinux 8/9, or Oracle Linux 7/8/9
- SSH access to target hosts with root privileges (or sudo access)
- For Unbound: RHEL/CentOS 8/9 (Unbound is not available in RHEL 7)
- For BIND: RHEL/CentOS 7/8/9
- firewalld service (optional, can be disabled via variables)

## Usage

### 1. Prepare Inventory File

Create an inventory file (e.g., `inventory`) with your target hosts organized by function:

```ini

[caching_dns]
dns1.example.com
dns2.example.com

[primary_dns]
instructor.example.com

[secondary_dns]
ns1.example.com
ns2.example.com
```

**Important Notes**:

- This playbook supports RHEL 7/8/9 and CentOS 7/8/9
- Unbound requires RHEL/CentOS 8/9 (not available in RHEL 7)
- BIND works on RHEL/CentOS 7/8/9
- You can organize hosts into functional groups as needed
- The playbook will validate OS compatibility before execution

### 2. Customize Configuration (Optional)

#### Unbound Configuration

Edit `roles/unbound_caching_dns/defaults/main.yml` to customize:

```yaml
# Allowed networks for recursive queries
unbound_allowed_networks:
  - "172.25.0.0/6"
  - "192.168.62.0/24"

# Internal domain without DNSSEC validation
unbound_insecure_domain: "pvt.example.com"

# Forwarder IP address
unbound_forwarder_ip: "172.25.254.254"
```

#### BIND Configuration

Edit the configuration files directly:

- **Primary**: `roles/bind_primary_dns/files/named-primary.conf`
- **Secondary**: `roles/bind_secondary_dns/files/named-secondary.conf`
- **Zone files**: `roles/bind_primary_dns/files/zones/`

Adjust IP addresses, ACLs, and zone definitions to match your environment.

### 3. Run the Playbooks

#### Deploy Unbound Caching DNS

```bash
ansible-playbook -i inventory deploy_unbound_site.yml
```

This will:

- Install Unbound package
- Generate configuration from Jinja2 template
- Start and enable Unbound service
- Configure firewalld to allow DNS service

#### Deploy BIND Primary DNS

```bash
ansible-playbook -i inventory deploy_bind_primary_site.yml
```

This will:

- Install BIND package
- Deploy `named.conf` configuration file
- Deploy zone files to `/var/named/`
- Start and enable named service
- Configure firewalld to allow DNS service

#### Deploy BIND Secondary DNS

```bash
ansible-playbook -i inventory deploy_bind_secondary_site.yml
```

This will:

- Install BIND package
- Deploy `named.conf` configuration file (slave zones configured)
- Start and enable named service
- Configure firewalld to allow DNS service
- Secondary zones will be automatically synced from primary server

## Playbook Structure

### Unbound Playbook (`deploy_unbound_site.yml`)

- **OS Compatibility Validation**: Checks for RHEL/CentOS 8/9
- **Package Installation**: Installs Unbound package
- **Configuration Deployment**: Uses Jinja2 template to generate configuration
- **Service Management**: Starts and enables Unbound service
- **Firewall Configuration**: Configures firewalld to allow DNS service

### BIND Primary Playbook (`deploy_bind_primary_site.yml`)

- **OS Compatibility Validation**: Checks for RHEL/CentOS 7/8/9
- **Package Installation**: Installs BIND package
- **Configuration Deployment**: Copies `named-primary.conf` to `/etc/named.conf`
- **Zone File Deployment**: Copies zone files to `/var/named/`
- **Service Management**: Starts and enables named service
- **Firewall Configuration**: Configures firewalld to allow DNS service

### BIND Secondary Playbook (`deploy_bind_secondary_site.yml`)

- **OS Compatibility Validation**: Checks for RHEL/CentOS 7/8/9
- **Package Installation**: Installs BIND package
- **Configuration Deployment**: Copies `named-secondary.conf` to `/etc/named.conf`
- **Service Management**: Starts and enables named service
- **Firewall Configuration**: Configures firewalld to allow DNS service
- **Zone Sync**: Secondary zones are automatically synced from primary server

## Customization Examples

### Example 1: Customize Unbound Allowed Networks

Edit `roles/unbound_caching_dns/defaults/main.yml`:

```yaml
unbound_allowed_networks:
  - "10.0.0.0/8"
  - "172.16.0.0/12"
  - "192.168.0.0/16"
```

### Example 2: Customize BIND Primary IP Addresses

Edit `roles/bind_primary_dns/files/named-primary.conf`:

```conf
options {
    listen-on port 53 { 127.0.0.1; 10.0.0.10; };
    allow-query     { localhost; 10.0.0.0/24; };
    allow-transfer  { localhost; 10.0.0.11; 10.0.0.12; };
    ...
}
```

### Example 3: Disable Firewall Management

Edit role defaults or use extra vars:

```bash
ansible-playbook -i inventory deploy_unbound_site.yml -e "unbound_manage_firewall=false"
```

## Best Practices

- **Test First**: Use `--check` mode to preview changes:

  ```bash
  ansible-playbook -i inventory deploy_unbound_site.yml --check
  ```
- **Validate Configuration**: After deployment, validate DNS configuration:

  ```bash
  # BIND
  named-checkconf /etc/named.conf
  named-checkzone pvt.example.com /var/named/pvt.example.com.zone

  # Unbound
  unbound-checkconf /etc/unbound/unbound.conf
  ```
- **Test DNS Resolution**: Verify DNS functionality:

  ```bash
  dig @localhost pvt.example.com
  dig @localhost -x 192.168.62.10
  ```
- **Backup Configuration**: Consider backing up DNS configuration before changes
- **Test in Non-Production**: Test DNS configurations in non-production environments first
- **Document Changes**: Document DNS configuration changes for audit and troubleshooting

## Troubleshooting

### Playbook fails with "Unsupported operating system"

- Verify target host OS is supported (RHEL 7/8/9, CentOS 7/8/9)
- For Unbound: Ensure RHEL/CentOS 8/9 (Unbound not available in RHEL 7)
- Check `ansible_distribution` and `ansible_distribution_major_version` facts
- Remove any unsupported hosts from the inventory

### "firewalld service is not available"

- **Disable firewall management** by setting:

  - `unbound_manage_firewall: false` (in `roles/unbound_caching_dns/defaults/main.yml`)
  - `bind_manage_firewall: false` (in role defaults)
- Or install and enable firewalld:

  ```bash
  yum install firewalld
  systemctl enable --now firewalld
  ```

### "named/unbound service fails to start"

- **Check service status:**

  ```bash
  systemctl status named
  systemctl status unbound
  journalctl -u named
  journalctl -u unbound
  ```
- **Validate configuration syntax:**

  ```bash
  # BIND
  named-checkconf /etc/named.conf
  named-checkzone pvt.example.com /var/named/pvt.example.com.zone

  # Unbound
  unbound-checkconf /etc/unbound/unbound.conf
  ```
- **Check SELinux contexts:**

  ```bash
  ls -Z /etc/named.conf
  ls -Z /var/named/
  ```

### "Zone transfer fails (Secondary DNS)"

- **Verify primary DNS allows transfers:**

  - Check `allow-transfer` in primary `named.conf`
  - Ensure secondary IP is in the allow-transfer list
- **Check network connectivity:**

  ```bash
  telnet <primary-ip> 53
  ```
- **Verify zone file permissions:**

  ```bash
  ls -l /var/named/slaves/
  ```

### "SELinux context issues"

- **Check current contexts:**

  ```bash
  ls -Z /etc/named.conf
  ls -Z /var/named/
  ```
- **Restore contexts if needed:**

  ```bash
  restorecon -R /etc/named.conf
  restorecon -R /var/named/
  ```
- **Customize SELinux types** in role defaults:

  - `unbound_config_setype`
  - `bind_config_setype`
  - `bind_zone_setype`

## Example Output

### Deploy Unbound

```
PLAY [Deploy and configure Unbound caching DNS servers] **********************

TASK [Validate OS compatibility] ******************************************
ok: [dns1.example.com] => {
    "msg": "OS compatibility check passed: RedHat 8"
}

TASK [unbound_caching_dns : Ensure Unbound package is installed] ***********
changed: [dns1.example.com]

TASK [unbound_caching_dns : Ensure Unbound configuration is correct] ******
changed: [dns1.example.com]

TASK [unbound_caching_dns : Ensure Unbound service is started and enabled] *
changed: [dns1.example.com]

TASK [unbound_caching_dns : Ensure firewall allows DNS service] ***********
changed: [dns1.example.com]

RUNNING HANDLER [unbound_caching_dns : restart unbound] *******************
changed: [dns1.example.com]

PLAY RECAP ******************************************************************
dns1.example.com          : ok=6    changed=5    unreachable=0    failed=0
```

### Deploy BIND Primary

```
PLAY [Deploy and configure BIND Primary DNS server] ***********************

TASK [Validate OS compatibility] ******************************************
ok: [instructor.example.com] => {
    "msg": "OS compatibility check passed: RedHat 8"
}

TASK [bind_primary_dns : Ensure BIND package is installed] ***************
changed: [instructor.example.com]

TASK [bind_primary_dns : Ensure named primary configuration is correct] **
changed: [instructor.example.com]

TASK [bind_primary_dns : Ensure zone files are correct] ******************
changed: [instructor.example.com]

TASK [bind_primary_dns : Ensure named service is started and enabled] ***
changed: [instructor.example.com]

TASK [bind_primary_dns : Ensure firewall allows DNS service] ************
changed: [instructor.example.com]

RUNNING HANDLER [bind_primary_dns : restart named] ***********************
changed: [instructor.example.com]

PLAY RECAP ******************************************************************
instructor.example.com    : ok=7    changed=6    unreachable=0    failed=0
```

## Role Design Philosophy

This solution uses Ansible Role architecture with the following design principles:

1. **Modularity**: Separate roles for Unbound, BIND Primary, and BIND Secondary
2. **Template-Based (Unbound)**: Dynamic configuration generation using Jinja2 templates
3. **File-Based (BIND)**: Static configuration files for simplicity and clarity
4. **Reusability**: Roles can be used in any playbook or project
5. **Maintainability**: Easy to update and extend
6. **Best Practices**: FQDN modules, OS compatibility checks, error handling
7. **Configuration Flexibility**: Customizable via defaults and direct file editing

## Security Considerations

- **Root Access Required**: This playbook requires root privileges to modify DNS configurations
- **Network Service**: DNS is a critical network service - test thoroughly before production
- **Firewall Rules**: Playbooks automatically configure firewalld - review rules for your environment
- **SELinux**: Proper SELinux contexts are set - ensure your policy allows these contexts
- **Zone Transfers**: Review `allow-transfer` settings in BIND configuration
- **Test First**: Always test in non-production environments
- **Backup Configuration**: Consider backing up DNS configuration before changes

## Author

GCG AAP SSA Team + v3.01 20260217

## License

📜 License Type: End User License Agreement (EULA)
🔒 Authorization: Subscription-based License
