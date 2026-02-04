# Automated Filesystem Health Check

## Overview

This Ansible Role-based solution provides automated filesystem health scanning across multiple Linux hosts. It performs read-only filesystem health checks (using `xfs_scrub` for XFS filesystems and `fsck -n` for ext2/3/4 filesystems), collects disk space and inode usage information, and generates comprehensive HTML reports that are collected back to the control node for centralized analysis.

## Filesystem Health Reports

![1770176185421](image/README/1770176185421.png)

## Features

- **Role-Based Architecture**: Modular, reusable, and maintainable design
- **OS Compatibility**: Supports RHEL 7/8/9 and CentOS 7/8/9
- **Read-Only Safety**: All filesystem checks are read-only and safe for production systems
- **Comprehensive Reporting**: Generates detailed HTML reports with disk space, inode usage, and filesystem health status
- **Multiple Filesystem Support**: Supports XFS (via `xfs_scrub`) and ext2/3/4 (via `fsck -n`)
- **Customizable Exclusions**: Easily configure which filesystem types and mount points to exclude
- **Centralized Collection**: Automatically collects reports back to control node
- **Comprehensive Validation**: Parameter validation and OS compatibility checks
- **Error Handling**: Robust error handling with detailed debugging information

## Files

- `filesystem_check_site.yml` - Main playbook file
- `roles/filesystem_check/` - Filesystem check role
  - `defaults/main.yml` - Default variables (exclusion lists, paths)
  - `tasks/main.yml` - Core role tasks
  - `templates/report.html.j2` - HTML report template
- `README.md` - This file

## Prerequisites

- Ansible 2.9 or later
- Ansible control node with network access to target hosts
- Target hosts: RHEL 7/8/9 or CentOS 7/8/9
- SSH access to target hosts with root privileges (or sudo access)
- `xfs_scrub` command available on hosts with XFS filesystems (optional, will skip if not available)

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

### 2. Customize Exclusion Lists (Optional)

Edit `roles/filesystem_check/defaults/main.yml` to customize which filesystem types and mount points to exclude:

```yaml
# Filesystem types to exclude from checking
exclude_fs_types:
  - tmpfs
  - devtmpfs
  - iso9660
  - squashfs
  - overlay
  - nfs
  - cifs
  # Add or remove filesystem types as needed

# Mount points to exclude from checking
exclude_mount_points:
  - /
  # Add other mount points as needed (e.g., /boot, /var)
```

**Note**: Root filesystem (`/`) is excluded by default as it typically requires rescue mode for checking. Virtual filesystems (tmpfs, devtmpfs, etc.) are also excluded by default.

### 3. Customize Report Paths (Optional)

Edit `roles/filesystem_check/defaults/main.yml` to change report storage locations:

```yaml
# Base path for report storage on remote hosts
report_base_path: "/tmp"

# Destination path on control node for collected reports
collection_dest_path: "/tmp"
```

### 4. Run the Playbook

Execute the playbook from the control node:

```bash
ansible-playbook filesystem_check_site.yml -i inventory
```

### 5. Review Reports

After execution, HTML reports are collected to the control node's `/tmp/` directory (or your configured `collection_dest_path`):

```bash
# List all collected reports
ls -la /tmp/*-fs-report-*.html

# Open a specific report in a web browser
# On Linux:
xdg-open /tmp/Test-RHEL-7.9-1-fs-report-2025-01-27T10-30-45.html

# On Windows (using WSL or Git Bash):
start /tmp/Test-RHEL-7.9-1-fs-report-2025-01-27T10-30-45.html
```

## Report Format

Each report is an HTML file containing:

1. **Summary Information**: Hostname, OS version, report generation time
2. **Disk Space Usage**: Complete output of `df -h` command
3. **Inode Usage**: Complete output of `df -i` command
4. **Filesystem Health Check Results**: Table showing:
   - Device name
   - Mount point
   - Filesystem type
   - Health status (✅ OK, ⚠️ Issues Found, or ⏭️ SKIPPED)
   - Detailed information (if issues found)

The report uses color coding:

- **Green (✅ OK)**: Filesystem is healthy
- **Red (⚠️ Issues Found)**: Filesystem has detected issues
- **Orange (⏭️ SKIPPED)**: Filesystem check was skipped (unsupported type or command not available)

## Playbook Structure

### Main Playbook (`filesystem_check_site.yml`)

The playbook consists of three plays:

1. **Play 1: Execute Filesystem Check**

   - OS compatibility validation
   - Executes `filesystem_check` role on all target hosts
   - Generates HTML reports on each host
2. **Play 2: Collect Reports**

   - Finds and fetches HTML report files from all target hosts
   - Collects reports to control node's `/tmp/` directory
3. **Play 3: Final Summary**

   - Displays completion summary and next steps
   - Runs on localhost

### Role Structure (`roles/filesystem_check/`)

- **`defaults/main.yml`**: Default variables (exclusion lists, paths)
- **`tasks/main.yml`**: Core role tasks
  - Parameter validation
  - OS compatibility check
  - Disk space and inode information collection
  - Filesystem health checks (read-only)
  - HTML report generation
- **`templates/report.html.j2`**: HTML report template with styling

## Customization

### Add or Remove Excluded Filesystem Types

Edit `roles/filesystem_check/defaults/main.yml`:

```yaml
exclude_fs_types:
  - tmpfs
  - devtmpfs
  - nfs
  - cifs
  - autofs      # Add new filesystem type to exclude
  # Remove filesystem types you want to check
```

### Add or Remove Excluded Mount Points

Edit `roles/filesystem_check/defaults/main.yml`:

```yaml
exclude_mount_points:
  - /
  - /boot       # Add new mount point to exclude
  - /var        # Add new mount point to exclude
  # Remove mount points you want to check
```

### Change Report Storage Location

Edit `roles/filesystem_check/defaults/main.yml`:

```yaml
report_base_path: "/var/log/filesystem_check"      # On remote hosts
collection_dest_path: "/opt/reports/filesystem_check"  # On control node
```

### Override Variables at Runtime

You can override variables when running the playbook:

```bash
ansible-playbook filesystem_check_site.yml -i inventory \
  -e "report_base_path=/var/log/fscheck" \
  -e "collection_dest_path=/opt/reports"
```

## Best Practices

- **Test First**: Use `--check` mode to preview changes:

  ```bash
  ansible-playbook filesystem_check_site.yml -i inventory --check
  ```
- **Use Tags**: Use tags for selective execution:

  ```bash
  # Only run validation
  ansible-playbook filesystem_check_site.yml -i inventory --tags validation

  # Only run filesystem checks
  ansible-playbook filesystem_check_site.yml -i inventory --tags check

  # Only collect reports
  ansible-playbook filesystem_check_site.yml -i inventory --tags collection
  ```
- **Regular Scheduling**: Schedule regular filesystem checks using cron or AAP schedules
- **Report Analysis**: Aggregate reports for trend analysis and capacity planning
- **Maintenance Windows**: Plan repair operations during maintenance windows if issues are detected
- **Documentation**: Document filesystem issues and corrective actions

## Safety Considerations

⚠️ **Important**: This playbook performs **read-only** filesystem checks:

- **XFS filesystems**: Uses `xfs_scrub` (read-only online check)
- **ext2/3/4 filesystems**: Uses `fsck -n` (read-only check, no repair)

**For repair operations**:

- Schedule a maintenance window
- Use appropriate repair tools (`xfs_repair` for XFS, `fsck` without `-n` for ext filesystems)
- Perform repairs in rescue mode or single-user mode
- Ensure proper backups before repair operations

## Troubleshooting

### Playbook fails with "Unsupported operating system"

- Verify target host OS is RHEL 7/8/9 or CentOS 7/8/9
- Check `ansible_distribution` and `ansible_distribution_major_version` facts
- Remove any unsupported hosts from the inventory

### "exclude_fs_types must be a list of filesystem types"

- Ensure `exclude_fs_types` is defined in `defaults/main.yml`
- Verify the list is properly formatted (YAML list syntax)
- Check YAML syntax in `defaults/main.yml`

### "xfs_scrub command not available"

- This is normal for systems without XFS filesystems or older RHEL versions
- The playbook will skip XFS checks and continue with other filesystems
- To install `xfs_scrub` (if needed):
  ```bash
  yum install xfsprogs  # RHEL 7
  dnf install xfsprogs  # RHEL 8/9
  ```

### "Report file was not created successfully"

- **Check disk space on target host:**
  ```bash
  df -h /tmp
  ```
- **Check file permissions:**
  ```bash
  ls -la /tmp/*-fs-report-*.html
  ```
- **Check Ansible logs for errors:**
  ```bash
  ansible-playbook filesystem_check_site.yml -i inventory -v
  ```

### Reports not collected to control node

- **Check fetch module permissions:**
  ```bash
  ls -la /tmp/  # On control node
  ```
- **Verify source path exists on remote host:**
  ```bash
  ansible all -i inventory -m shell -a "ls -la /tmp/*-fs-report-*.html"
  ```
- **Check network connectivity:**
  ```bash
  ansible all -i inventory -m ping
  ```

### Filesystem check shows "SKIPPED"

- **Check if filesystem type is in exclude list:**
  - Review `exclude_fs_types` in `defaults/main.yml`
- **Check if mount point is in exclude list:**
  - Review `exclude_mount_points` in `defaults/main.yml`
- **For XFS filesystems:**
  - Verify `xfs_scrub` command is available
  - Check if filesystem is mounted and accessible

### "fsck -n" shows errors

- This indicates potential filesystem issues
- Review the detailed error message in the HTML report
- Plan a maintenance window for repair operations
- **Do not run `fsck` without `-n` on mounted filesystems**
- Use rescue mode or single-user mode for repairs

## Example Output

### Playbook Execution

```
PLAY [Execute filesystem check and generate reports on all hosts] **********

TASK [Validate OS compatibility (RHEL/CentOS 7/8/9 only)] ******************
ok: [Test-RHEL-7.9-1] => {
    "msg": "OS compatibility check passed: RedHat 7"
}

TASK [Include filesystem_check role] **************************************
TASK [filesystem_check : Validate exclude_fs_types parameter] *************
ok: [Test-RHEL-7.9-1] => {
    "msg": "Parameter validation passed: 10 filesystem types to exclude"
}

TASK [filesystem_check : Gather disk space usage information (df -h)] *****
ok: [Test-RHEL-7.9-1]

TASK [filesystem_check : Gather inode usage information (df -i)] ***********
ok: [Test-RHEL-7.9-1]

TASK [filesystem_check : Check if xfs_scrub command exists] ***************
ok: [Test-RHEL-7.9-1]

TASK [filesystem_check : Perform read-only filesystem health checks] ******
ok: [Test-RHEL-7.9-1] => (item={'mount': '/boot', 'device': '/dev/sda1', 'fstype': 'xfs'})
ok: [Test-RHEL-7.9-1] => (item={'mount': '/home', 'device': '/dev/sda2', 'fstype': 'ext4'})

TASK [filesystem_check : Generate HTML report from template] ***************
changed: [Test-RHEL-7.9-1]

PLAY [Collect filesystem check reports from all hosts] ********************

TASK [Find report files on remote host] ************************************
ok: [Test-RHEL-7.9-1]

TASK [Fetch report file from remote host] **********************************
changed: [Test-RHEL-7.9-1]

PLAY [Display final summary and confirmation] *****************************

TASK [Display completion summary] ******************************************
ok: [localhost] => {
    "msg": [
        "✅ All filesystem check reports have been successfully collected!",
        "Reports are stored in the control node's /tmp/ directory.",
        "Report file naming format: <hostname>-fs-report-<timestamp>.html",
        "You can review individual reports in a web browser for detailed analysis."
    ]
}

PLAY RECAP ******************************************************************
Test-RHEL-7.9-1            : ok=12   changed=2    failed=0
localhost                  : ok=2    changed=0    failed=0
```

## Role Design Philosophy

This solution uses Ansible Role architecture for the following benefits:

1. **Modularity**: Clear separation of concerns (variables vs. tasks vs. templates)
2. **Reusability**: Role can be used in any playbook or project
3. **Maintainability**: Easy to update and extend
4. **Team Collaboration**: Standard structure for team development
5. **Configuration Flexibility**: Variables in `defaults/main.yml` allow easy customization
6. **Safety First**: All checks are read-only, ensuring production safety

## Security Considerations

- **Root Access Required**: This playbook requires root privileges to check filesystem health
- **Report Storage**: Reports may contain sensitive information (disk usage, filesystem details) - secure storage locations
- **Network Access**: Ensure secure network communication between control node and targets
- **File Permissions**: Reports are created with `0644` permissions - adjust as needed for your security requirements
- **Read-Only Operations**: All filesystem checks are read-only and safe for production systems

## Author

GCG AAP SSA Team + v3.01 20260217

## License

📜 License Type: End User License Agreement (EULA)
🔒 Authorization: Subscription-based License
