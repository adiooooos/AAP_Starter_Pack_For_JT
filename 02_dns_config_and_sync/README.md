# DNS Configuration Synchronization and Validation

## Overview

This playbook automates the synchronization of DNS configuration files (`/etc/resolv.conf`) from the Ansible control node to multiple target hosts across the network. It provides automatic backup, content validation, and rollback capabilities to ensure safe and reliable DNS configuration management.

```yaml
...

TASK [Verify DNS configuration was not changed (idempotency check)] ***************************************************************************************************************
ok: [Test-RHEL-7.9-1] => {
    "msg": "ℹ️  No file changes detected. Possible reasons: file content is identical, file has not changed"
}
ok: [Test-RHEL-7.9-2] => {
    "msg": "ℹ️  No file changes detected. Possible reasons: file content is identical, file has not changed"
}
ok: [Test-RHEL-7.9-3] => {
    "msg": "ℹ️  No file changes detected. Possible reasons: file content is identical, file has not changed"
}
ok: [TEST-RHEL-8.9-1] => {
    "msg": "ℹ️  No file changes detected. Possible reasons: file content is identical, file has not changed"
}
skipping: [ansible25.example.com]

TASK [Display completion summary] *************************************************************************************************************************************************
ok: [Test-RHEL-7.9-1] => {
    "msg": "DNS configuration synchronization completed for Test-RHEL-7.9-1"
}
ok: [Test-RHEL-7.9-2] => {
    "msg": "DNS configuration synchronization completed for Test-RHEL-7.9-2"
}
ok: [Test-RHEL-7.9-3] => {
    "msg": "DNS configuration synchronization completed for Test-RHEL-7.9-3"
}
ok: [TEST-RHEL-8.9-1] => {
    "msg": "DNS configuration synchronization completed for TEST-RHEL-8.9-1"
}
ok: [ansible25.example.com] => {
    "msg": "DNS configuration synchronization completed for ansible25.example.com"
}
...
```

## Features

- **OS Compatibility**: Supports RHEL 7/8/9 and CentOS 7/8/9
- **Automatic Backup**: Creates timestamped backups before file modification
- **Format Validation**: Validates DNS server IP address format
- **Content Verification**: Verifies file content after synchronization
- **Rollback Mechanism**: Automatically restores from backup on failure
- **Idempotent**: Safe to run multiple times without side effects
- **Robust Error Handling**: Comprehensive error handling with block-rescue-always structure

## Files

- `dns_config_sync.yml` - Main playbook file
- `README.md` - This file

## Prerequisites

- Ansible 2.9 or later
- Ansible control node with network access to target hosts
- Target hosts: RHEL 7/8/9 or CentOS 7/8/9
- SSH access to target hosts with root privileges (or sudo access)
- A standard `resolv.conf` file prepared on the control node

## Usage

### 1. Prepare Source DNS Configuration File

Create a standard `resolv.conf` file on the Ansible control node. Example:

```bash
# /etc/resolv.conf on control node
nameserver 223.5.5.5
nameserver 114.114.114.114
search example.com
```

### 2. Update Playbook Variables (Optional)

If your source file is not at `/etc/resolv.conf`, update the `source_file_path` variable in the playbook:

```yaml
vars:
  source_file_path: "/path/to/your/resolv.conf"
  dest_file_path: "/etc/resolv.conf"
  backup_enabled: true
```

### 3. Prepare Inventory File

Create an inventory file (e.g., `inventory`) with your target hosts:

```ini
[rhel]
rhel7.example.com
rhel8.example.com
rhel9.example.com

[centos]
centos7.example.com
centos8.example.com
```

### 4. Run the Playbook

Execute the playbook from the control node:

```bash
ansible-playbook dns_config_sync.yml -i inventory
```

### 5. Verify Results

After execution, check the output for:

- File synchronization status
- Backup file locations
- Any errors or warnings

## Customization

### Change Source File Path

Modify the `source_file_path` variable:

```yaml
vars:
  source_file_path: "/opt/custom/resolv.conf"
```

### Change Destination File Path

Modify the `dest_file_path` variable:

```yaml
vars:
  dest_file_path: "/etc/resolv.conf"
```

### Disable Automatic Backup

Set `backup_enabled` to `false`:

```yaml
vars:
  backup_enabled: false
```

**Warning**: Disabling backup removes the rollback capability. Use with caution.

### Change File Permissions

Modify file ownership and permissions:

```yaml
vars:
  file_owner: "root"
  file_group: "root"
  file_mode: '0644'
```

## Playbook Structure

1. **OS Compatibility Validation**: Ensures only supported operating systems are processed
2. **Input Parameter Validation**: Validates source file existence and DNS format
3. **DNS Configuration Synchronization**: Copies file with automatic backup
4. **Error Handling**: Comprehensive block-rescue-always structure for robust execution
5. **Post-Synchronization Verification**: Verifies file content and displays results
6. **Debug Output**: Multiple debug tasks for troubleshooting

## Backup and Rollback

### Automatic Backup

When `backup_enabled: true`, the playbook automatically creates a backup of the existing file before modification. Backup files are stored in the same directory as the destination file with a timestamp suffix.

Example backup file: `/etc/resolv.conf.12345.2023-10-27@10:30:00~`

### Manual Rollback

If you need to manually restore from a backup:

```bash
# On the target host
cp /etc/resolv.conf.12345.2023-10-27@10:30:00~ /etc/resolv.conf
```

### Automatic Rollback

The playbook automatically attempts to restore from backup if the synchronization fails.

## Best Practices

- **Test First**: Run in check mode first: `ansible-playbook dns_config_sync.yml -i inventory --check`
- **Verify Source**: Ensure the source file contains valid DNS server entries
- **Use Tags**: Use tags for selective execution: `ansible-playbook dns_config_sync.yml -i inventory --tags validation`
- **Review Backups**: Periodically review and clean up old backup files
- **Document Changes**: Keep track of DNS server changes for audit purposes

## Troubleshooting

### Playbook fails with "Unsupported operating system"

- Verify target host OS is RHEL 7/8/9 or CentOS 7/8/9
- Check `ansible_distribution` and `ansible_distribution_major_version` facts

### Source file not found

- Verify source file exists on the control node at the specified path
- Check file permissions (must be readable)
- Ensure the path is correct and absolute

### DNS format validation fails

- Verify source file contains valid `nameserver` entries
- Check IP address format (must be valid IPv4 addresses)
- Ensure file format follows standard resolv.conf structure

### File synchronization fails

- Check SSH connectivity to target hosts
- Verify root/sudo privileges on target hosts
- Check disk space on target hosts
- Review playbook output for specific error messages

### Backup restoration fails

- Verify backup file exists on target host
- Check backup file permissions
- Ensure sufficient disk space for restoration

## Security Considerations

- **Root Access Required**: This playbook requires root privileges to modify `/etc/resolv.conf`
- **File Permissions**: Default file permissions are set to `0644` (readable by all, writable by owner)
- **Backup Security**: Backup files inherit permissions from the original file
- **Network Security**: Ensure secure SSH connections when synchronizing files

## Author

GCG AAP SSA Team + v3.01 20260217

## License

📜 License Type: End User License Agreement (EULA)
🔒 Authorization: Subscription-based License
