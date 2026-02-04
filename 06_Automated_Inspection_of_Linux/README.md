# Automated Service Status Check

## Overview

This Ansible Role-based solution provides automated service status checking across multiple Linux hosts. It checks the status of critical services (such as `sshd`, `firewalld`, `chronyd`, etc.) and generates detailed reports that are collected back to the control node for centralized analysis.

## Features

- **Role-Based Architecture**: Modular, reusable, and maintainable design
- **OS Compatibility**: Supports RHEL 7/8/9 and CentOS 7/8/9
- **Bulk Service Checking**: Uses `service_facts` module for efficient bulk operation
- **Customizable Service List**: Easily configure which services to check via variables
- **Detailed Reports**: Generates comprehensive service status reports on each host
- **Centralized Collection**: Automatically collects reports back to control node
- **Comprehensive Validation**: Parameter validation and OS compatibility checks
- **Error Handling**: Robust error handling with detailed debugging information

## Files

- `service_check_site.yml` - Main playbook file
- `roles/service_check/` - Service check role
  - `defaults/main.yml` - Default variables (service list, paths)
  - `tasks/main.yml` - Core role tasks
- `README.md` - This file

## Prerequisites

- Ansible 2.9 or later
- Ansible control node with network access to target hosts
- Target hosts: RHEL 7/8/9 or CentOS 7/8/9
- SSH access to target hosts with root privileges (or sudo access)

## Usage

### 1. Prepare Inventory File

Create an inventory file (e.g., `inventory`) with your target hosts:

```ini
[rhel7]
Test-RHEL-7.9-1
Test-RHEL-7.9-2
Test-RHEL-7.9-3

[rhel8]
TEST-RHEL-8.9-1

[rhel9]
ansible25.example.com

[all:children]
rhel7
rhel8
rhel9
```

**Important Notes**:

- This playbook supports RHEL 7/8/9 and CentOS 7/8/9 only
- You can organize hosts into groups as needed
- The playbook will validate OS compatibility before execution

### 2. Customize Service List (Optional)

Edit `roles/service_check/defaults/main.yml` to customize which services to check:

```yaml
critical_services_list:
  - sshd
  - firewalld
  - chronyd
  - tuned
  - NetworkManager
  - rsyslog
  - auditd
  - crond
  - dbus
  - systemd-journald
  # Add or remove services as needed
```

**Note**: Service names should be without the `.service` suffix (e.g., use `sshd`, not `sshd.service`).

### 3. Customize Report Paths (Optional)

Edit `roles/service_check/defaults/main.yml` to change report storage locations:

```yaml
# Base path for report storage on remote hosts
report_base_path: "/tmp"

# Destination path on control node for collected reports
collection_dest_path: "/tmp"
```

### 4. Run the Playbook

Execute the playbook from the control node:

```bash
ansible-playbook service_check_site.yml -i inventory
```

### 5. Review Reports

After execution, reports are collected to the control node's `/tmp/` directory (or your configured `collection_dest_path`):

```bash
# List all collected reports
ls -la /tmp/linux_service_check_*.txt

# View a specific report
cat /tmp/linux_service_check_Test-RHEL-7.9-1.txt
```

## Report Format

Each report file contains detailed service status information:

```
# RHEL Key Service Status Check Report for Test-RHEL-7.9-1
# Generated at: 2025-07-27T23:02:20Z
# Distribution: RedHat 7
# Architecture: x86_64
# ---

[Service Status Report: sshd]
   Service Name: sshd.service
   Current State: RUNNING
   Boot Status: ENABLED
   Service Source: systemd

[Service Status Report: firewalld]
   Service Name: firewalld.service
   Current State: INACTIVE
   Boot Status: DISABLED
   Service Source: systemd

[Service Status Report: chronyd]
   Service Name: chronyd.service
   Current State: RUNNING
   Boot Status: ENABLED
   Service Source: systemd

[Service Status Report: imaginary-service]
  [CRITICAL] Service imaginary-service is not installed or not recognized by systemd!
```

## Playbook Structure

### Main Playbook (`service_check_site.yml`)

The playbook consists of three plays:

1. **Play 1: Execute Service Check**

   - OS compatibility validation
   - Executes `service_check` role on all target hosts
   - Generates service status reports on each host
2. **Play 2: Collect Reports**

   - Fetches report files from all target hosts
   - Collects reports to control node's `/tmp/` directory
3. **Play 3: Final Summary**

   - Displays completion summary and next steps
   - Runs on localhost

### Role Structure (`roles/service_check/`)

- **`defaults/main.yml`**: Default variables (service list, paths)
- **`tasks/main.yml`**: Core role tasks
  - Parameter validation
  - OS compatibility check
  - Service facts collection (bulk operation)
  - Report generation
  - Report verification

## Customization

### Add or Remove Services

Edit `roles/service_check/defaults/main.yml`:

```yaml
critical_services_list:
  - sshd
  - firewalld
  - nginx      # Add new service
  - mysql      # Add new service
  # Remove services you don't need
```

### Change Report Storage Location

Edit `roles/service_check/defaults/main.yml`:

```yaml
report_base_path: "/var/log/service_check"      # On remote hosts
collection_dest_path: "/opt/reports/service_check"  # On control node
```

### Override Variables at Runtime

You can override variables when running the playbook:

```bash
ansible-playbook service_check_site.yml -i inventory \
  -e "report_base_path=/var/log/service_check" \
  -e "collection_dest_path=/opt/reports"
```

## Best Practices

- **Test First**: Use `--check` mode to preview changes:

  ```bash
  ansible-playbook service_check_site.yml -i inventory --check
  ```
- **Use Tags**: Use tags for selective execution:

  ```bash
  # Only run validation
  ansible-playbook service_check_site.yml -i inventory --tags validation

  # Only run service check
  ansible-playbook service_check_site.yml -i inventory --tags check

  # Only collect reports
  ansible-playbook service_check_site.yml -i inventory --tags collection
  ```
- **Regular Scheduling**: Schedule regular service checks using cron or AAP schedules
- **Report Analysis**: Aggregate reports for trend analysis and compliance reporting
- **Documentation**: Document service status changes and corrective actions

## Troubleshooting

### Playbook fails with "Unsupported operating system"

- Verify target host OS is RHEL 7/8/9 or CentOS 7/8/9
- Check `ansible_distribution` and `ansible_distribution_major_version` facts
- Remove any unsupported hosts from the inventory

### "critical_services_list must be a non-empty list"

- Ensure `critical_services_list` is defined in `defaults/main.yml`
- Verify the list is not empty
- Check YAML syntax in `defaults/main.yml`

### "Report file was not created successfully"

- **Check disk space on target host:**

  ```bash
  df -h /tmp
  ```
- **Check file permissions:**

  ```bash
  ls -la /tmp/linux_service_check_*.txt
  ```
- **Check Ansible logs for errors:**

  ```bash
  ansible-playbook service_check_site.yml -i inventory -v
  ```
- **Verify service_facts module works:**

  ```bash
  ansible all -i inventory -m service_facts
  ```

### Service shows as "not recognized by systemd"

- **Verify service name is correct:**

  ```bash
  systemctl list-unit-files | grep <service-name>
  ```
- **Check if service is installed:**

  ```bash
  rpm -qa | grep <service-package>
  ```
- **Note**: Some services may have different names (e.g., `NetworkManager` vs `NetworkManager.service`)

### Reports not collected to control node

- **Check fetch module permissions:**

  ```bash
  ls -la /tmp/  # On control node
  ```
- **Verify source path exists on remote host:**

  ```bash
  ansible all -i inventory -m shell -a "ls -la /tmp/linux_service_check_*.txt"
  ```
- **Check network connectivity:**

  ```bash
  ansible all -i inventory -m ping
  ```

### "service_facts module not found"

- **Install Ansible 2.9 or later:**

  ```bash
  ansible --version
  ```
- **Note**: `service_facts` is part of `ansible.builtin` collection (included by default)

## Example Output

### Playbook Execution

```
PLAY [Execute service check and generate reports on all hosts] ************

TASK [Validate OS compatibility (RHEL/CentOS 7/8/9 only)] ***************
ok: [Test-RHEL-7.9-1] => {
    "msg": "OS compatibility check passed: RedHat 7"
}

TASK [Include service_check role] *****************************************
TASK [service_check : Validate critical_services_list parameter] *********
ok: [Test-RHEL-7.9-1] => {
    "msg": "Parameter validation passed: 10 services to check"
}

TASK [service_check : Collect service facts (bulk operation)] ************
ok: [Test-RHEL-7.9-1]

TASK [service_check : Check service status and append to report] **********
changed: [Test-RHEL-7.9-1] => (item=sshd)
changed: [Test-RHEL-7.9-1] => (item=firewalld)
...

PLAY [Collect service check reports from all hosts] **********************

TASK [Fetch report file from remote host] ********************************
changed: [Test-RHEL-7.9-1]

PLAY [Display final summary and confirmation] ****************************

TASK [Display completion summary] ****************************************
ok: [localhost] => {
    "msg": [
	"✅ All service check reports have been successfully collected!",
        "Reports are stored in the control node's /tmp/ directory.",
        "Report file naming format: linux_service_check_<hostname>.txt",
        "You can review individual reports or aggregate them for analysis."

    ]
}
TASK [Display next steps] *************************************************
ok: [localhost] => {
    "msg": [
        "Next steps:",
        "  1. Review individual reports: cat /tmp/linux_service_check_<hostname>.txt",
        "  2. Aggregate reports for analysis",
        "  3. Identify services that are not running or not enabled",
        "  4. Take corrective actions as needed"
    ]
}

PLAY RECAP ***************************************************************
Test-RHEL-7.9-1            : ok=15   changed=12   failed=0
localhost                  : ok=2    changed=0    failed=0
```

## Role Design Philosophy

This solution uses Ansible Role architecture for the following benefits:

1. **Modularity**: Clear separation of concerns (variables vs. tasks)
2. **Reusability**: Role can be used in any playbook or project
3. **Maintainability**: Easy to update and extend
4. **Team Collaboration**: Standard structure for team development
5. **Configuration Flexibility**: Variables in `defaults/main.yml` allow easy customization

## Security Considerations

- **Root Access Required**: This playbook requires root privileges to check service status
- **Report Storage**: Reports may contain sensitive information - secure storage locations
- **Network Access**: Ensure secure network communication between control node and targets
- **File Permissions**: Reports are created with `0644` permissions - adjust as needed

## Author

GCG AAP SSA Team + v3.01 20260217

## License

📜 License Type: End User License Agreement (EULA)
🔒 Authorization: Subscription-based License
