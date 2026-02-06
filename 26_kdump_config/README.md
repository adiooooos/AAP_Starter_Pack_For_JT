# Automated RHEL Kdump Service Configuration

## Overview

This playbook automates the installation and configuration of Kdump kernel crash dump service on RHEL/CentOS systems. It provides a complete, enterprise-grade solution for deploying kernel crash dump capabilities across your infrastructure, eliminating manual configuration steps and ensuring consistent, reliable system fault diagnosis capabilities.

Kdump is a kernel crash dumping mechanism that allows you to save the contents of system memory when the kernel crashes. This playbook automates the entire Kdump configuration process, from package installation to service startup, with support for multiple storage backends and kernel panic trigger conditions.

## Features

- **Complete Automation**: End-to-end Kdump deployment from package installation to service startup
- **Multiple Storage Backends**: Supports Local, NFS, SSH, and Raw device storage targets
- **OS Compatibility**: Supports RHEL 7/8/9 and CentOS 7/8/9 with automatic validation
- **Flexible Configuration**: Variable-driven design supports different dump targets, compression levels, and failure actions
- **Kernel Panic Triggers**: Configurable triggers for system hang, OOM, soft lockup, and hung tasks
- **Robust Error Handling**: Comprehensive error handling with block-rescue structures ensures execution continues even if individual tasks fail
- **Idempotent Design**: Safe to run multiple times without side effects
- **Comprehensive Validation**: Input parameter validation prevents configuration errors
- **RHEL 9+ Optimization**: Uses `kdumpctl reset-crashkernel` for RHEL 9+ systems

## Prerequisites

- Ansible 2.9 or later
- Ansible control node with network access to target hosts
- Target hosts: RHEL 7/8/9 or CentOS 7/8/9
- SSH access to target hosts (password or key-based authentication)
- Sudo/root privileges on target hosts
- Internet access or configured YUM/DNF repository for kexec-tools package
- Target hosts must have access to Red Hat software repositories
- `ansible.posix` collection installed (for sysctl module)
- Sufficient disk space for vmcore files (typically 1-2GB minimum, depends on system memory)
- For NFS/SSH targets: Network connectivity and proper authentication configured

## Installation

### Install Required Collections

```bash
# Install ansible.posix collection for sysctl module
ansible-galaxy collection install ansible.posix
```

## Files

- `kdumpconfig_site.yml` - Main Kdump configuration playbook
- `inventory` - Host inventory file
- `ansible.cfg` - Ansible configuration file
- `README.md` - This file

## Usage

### 1. Prepare Inventory File

Edit the `inventory` file to define your target hosts. The playbook uses the `kdump_servers` group:

```ini
[kdump_servers]
# Define target hosts for Kdump configuration here
# Example:
# rhel-server-01 ansible_host=192.168.1.100
# rhel-server-02 ansible_host=192.168.1.101

# Using the standard inventory format:
[rhel7]
Test-RHEL-7.9-1
Test-RHEL-7.9-2
Test-RHEL-7.9-3

[rhel8]
TEST-RHEL-8.9-1

[rhel9]
ansible25.example.com

# Group all RHEL hosts as kdump_servers
[kdump_servers:children]
rhel7
rhel8
rhel9
```

### 2. Configure Variables

The playbook uses the following default variables (defined in the playbook):

```yaml
# --- Kdump Core Configuration ---
kdump_dump_target: "Local"                    # Storage target: Local | NFS | SSH | Raw
kdump_local_path: "/var/crash"                 # Local storage path
kdump_nfs_server: "nfs.example.com:/remote/crash/path"  # NFS server and path
kdump_ssh_server: "ssh.example.com"           # SSH server hostname
kdump_ssh_user: "root"                        # SSH username
kdump_raw_device: "/dev/sdb1"                 # Raw device path
kdump_dump_level: 31                          # Compression/filtering level (0-31)
kdump_failure_action: "reboot"                # Failure action: reboot | halt | poweroff | shell | dump_to_rootfs

# --- Kernel Panic Trigger Configuration ---
kdump_panic_triggers:
  system_hang: true       # Respond to NMI or SysRq triggered panic
  oom_killer: true        # Panic on Out of Memory (OOM)
  soft_lockup: true      # Panic on kernel soft lockup detection
  process_d_state: true   # Panic on task stuck in D state (Hung Task)
```

### 3. Run the Playbook

#### Basic Usage (Local Storage)

```bash
# Dry run first (recommended) - check what would be done
ansible-playbook kdumpconfig_site.yml -i inventory --check

# Execute Kdump configuration with default variables (Local storage)
ansible-playbook kdumpconfig_site.yml -i inventory
```

#### NFS Storage Configuration

```bash
ansible-playbook kdumpconfig_site.yml -i inventory \
  -e "kdump_dump_target=NFS" \
  -e "kdump_nfs_server=192.168.1.100:/exports/kdump"
```

#### SSH Storage Configuration

```bash
ansible-playbook kdumpconfig_site.yml -i inventory \
  -e "kdump_dump_target=SSH" \
  -e "kdump_ssh_server=192.168.1.101" \
  -e "kdump_ssh_user=root"
```

#### Raw Device Storage Configuration

```bash
ansible-playbook kdumpconfig_site.yml -i inventory \
  -e "kdump_dump_target=Raw" \
  -e "kdump_raw_device=/dev/sdb1"
```

#### Custom Dump Level and Failure Action

```bash
ansible-playbook kdumpconfig_site.yml -i inventory \
  -e "kdump_dump_level=15" \
  -e "kdump_failure_action=halt"
```

#### Configure Specific Panic Triggers

```bash
# Only enable OOM killer trigger
ansible-playbook kdumpconfig_site.yml -i inventory \
  -e '{"kdump_panic_triggers":{"system_hang":false,"oom_killer":true,"soft_lockup":false,"process_d_state":false}}'

# Enable all triggers (default)
ansible-playbook kdumpconfig_site.yml -i inventory
```

#### Advanced Usage

```bash
# Run with increased parallelism for bulk execution
ansible-playbook kdumpconfig_site.yml -i inventory --forks 10

# Configure specific host or group
ansible-playbook kdumpconfig_site.yml -i inventory --limit rhel9

# Run with verbose output for troubleshooting
ansible-playbook kdumpconfig_site.yml -i inventory -v
```

### 4. Verify Configuration

After successful execution, verify the Kdump configuration:

```bash
# Check kdump service status
ssh <hostname> "systemctl status kdump"

# Verify kdump configuration file
ssh <hostname> "cat /etc/kdump.conf"

# Check crashkernel memory allocation
ssh <hostname> "cat /proc/cmdline | grep crashkernel"

# Test kdump configuration
ssh <hostname> "kdumpctl status"
```

## What Gets Configured

The playbook performs the following tasks:

1. **OS Compatibility Validation**: Verifies RHEL/CentOS 7/8/9 compatibility
2. **Input Parameter Validation**: Validates all configuration variables (dump target, paths, levels, etc.)
3. **Package Installation**: Installs `kexec-tools` package
4. **Service Management**: Unmasks kdump service to ensure it's manageable
5. **Crashkernel Configuration**: Sets default crashkernel memory using `kdumpctl reset-crashkernel` (RHEL 9+)
6. **Configuration File Generation**: Dynamically generates `/etc/kdump.conf` based on selected dump target
7. **Storage Backend Configuration**:
   - Local: Configures dump path
   - NFS: Configures NFS server and path
   - SSH: Configures SSH server and propagates keys
   - Raw: Configures raw device path
8. **Kernel Panic Triggers**: Configures sysctl parameters in `/etc/sysctl.d/90-kdump-panic.conf`:
   - System hang triggers (SysRq, NMI)
   - OOM killer trigger
   - Soft lockup trigger
   - Hung task trigger
9. **Service Management**: Restarts and enables kdump service

## Configuration Details

### Dump Target Types

#### Local Storage
- **Use Case**: Single server, local storage
- **Configuration**: `kdump_dump_target: "Local"`, `kdump_local_path: "/var/crash"`
- **Requirements**: Sufficient local disk space

#### NFS Storage
- **Use Case**: Centralized storage, multiple servers
- **Configuration**: `kdump_dump_target: "NFS"`, `kdump_nfs_server: "server:/path"`
- **Requirements**: NFS server accessible, proper mount permissions

#### SSH Storage
- **Use Case**: Remote storage, secure transfer
- **Configuration**: `kdump_dump_target: "SSH"`, `kdump_ssh_server: "server"`, `kdump_ssh_user: "user"`
- **Requirements**: SSH access, key-based authentication (keys are propagated automatically)

#### Raw Device Storage
- **Use Case**: Dedicated storage device
- **Configuration**: `kdump_dump_target: "Raw"`, `kdump_raw_device: "/dev/sdb1"`
- **Requirements**: Dedicated block device, no filesystem

### Dump Level

The `kdump_dump_level` parameter controls compression and filtering:
- **0**: No filtering, full dump
- **31** (default): Maximum filtering, excludes zero pages, cache, private, and user pages
- **Lower values**: Less filtering, larger files
- **Higher values**: More filtering, smaller files

### Failure Actions

- **reboot**: Reboot the system after dump (default)
- **halt**: Halt the system after dump
- **poweroff**: Power off the system after dump
- **shell**: Drop to shell after dump
- **dump_to_rootfs**: Save dump to root filesystem

### Kernel Panic Triggers

- **system_hang**: Enables SysRq and NMI panic triggers (x86_64 only for NMI)
- **oom_killer**: Triggers panic when Out of Memory killer activates
- **soft_lockup**: Triggers panic on kernel soft lockup detection
- **process_d_state**: Triggers panic when tasks are stuck in D state (hung tasks)

## Troubleshooting

### Service Not Starting

```bash
# Check service status
systemctl status kdump

# Check service logs
journalctl -u kdump -n 50

# Verify configuration
kdumpctl status
```

### Configuration File Issues

```bash
# Verify configuration file syntax
kdumpctl showmem

# Check crashkernel allocation
cat /proc/cmdline | grep crashkernel

# Verify dump path exists and has permissions
ls -ld /var/crash
```

### Storage Backend Issues

#### NFS Issues
```bash
# Test NFS connectivity
showmount -e <nfs-server>

# Verify NFS mount
mount | grep nfs
```

#### SSH Issues
```bash
# Verify SSH key propagation
kdumpctl propagate

# Test SSH connectivity
ssh <ssh-user>@<ssh-server> "echo test"
```

### Insufficient Memory

If crashkernel allocation fails:
```bash
# Check available memory
free -h

# Check current crashkernel setting
cat /proc/cmdline | grep crashkernel

# Manually set crashkernel (if needed)
grubby --update-kernel=ALL --args="crashkernel=auto"
```

## Best Practices

1. **Test First**: Always use `--check` mode before actual execution
2. **Storage Planning**: Ensure sufficient storage space for vmcore files (typically 1-2GB per system)
3. **Network Configuration**: For NFS/SSH targets, ensure network connectivity and proper authentication
4. **Regular Testing**: Periodically test Kdump functionality to ensure it works correctly
5. **Monitoring**: Monitor disk space on dump storage locations
6. **Documentation**: Document your dump storage strategy and access procedures
7. **Security**: For SSH targets, use dedicated SSH keys with limited permissions
8. **Backup Strategy**: Implement backup strategy for vmcore files if needed for long-term analysis

## Playbook Structure

The playbook consists of a single play with the following task groups:

1. **OS Compatibility Validation**: Validates RHEL/CentOS 7/8/9
2. **Input Parameter Validation**: Validates all configuration variables
3. **Package Installation**: Installs kexec-tools
4. **Service Unmasking**: Ensures kdump service is manageable
5. **Crashkernel Configuration**: Sets default crashkernel (RHEL 9+)
6. **Configuration Generation**: Dynamically generates kdump.conf
7. **Configuration Deployment**: Writes kdump.conf to /etc/kdump.conf
8. **SSH Key Propagation**: Propagates SSH keys for SSH targets
9. **Sysctl Configuration**: Configures kernel panic triggers
10. **Service Management**: Restarts and enables kdump service
11. **Final Report**: Displays configuration summary

## Customization

### Change Default Storage Path

Edit the playbook variables or override at runtime:

```bash
ansible-playbook kdumpconfig_site.yml -i inventory \
  -e "kdump_local_path=/opt/crash"
```

### Adjust Dump Level

```bash
ansible-playbook kdumpconfig_site.yml -i inventory \
  -e "kdump_dump_level=15"  # Less filtering, larger files
```

### Custom Failure Action

```bash
ansible-playbook kdumpconfig_site.yml -i inventory \
  -e "kdump_failure_action=halt"
```

## Limitations

- Requires root/sudo privileges on target hosts
- RHEL 9+ crashkernel reset requires `kdumpctl` command availability
- SSH target requires SSH key-based authentication setup
- NFS target requires NFS server to be accessible
- Raw device target requires dedicated block device
- Some panic triggers (NMI-related) are x86_64 architecture specific

## Support

For issues or questions:
- Check Ansible logs: `ansible-playbook -v` for verbose output
- Review service logs: `journalctl -u kdump`
- Verify configuration: `kdumpctl status`
- Test manually: `kdumpctl showmem`

## License

📜 License Type: End User License Agreement (EULA)
🔒 Authorization: Subscription-based License

## Author

GCG AAP SSA Team + v3.01 20260217

