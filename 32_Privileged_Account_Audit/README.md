# Privileged Account and Sudo Security Audit

## Overview

This playbook automates security baseline auditing for privileged accounts and sudo configurations on RHEL/CentOS systems. It checks for non-root users with UID 0 (rogue root users), audits sudoers files for NOPASSWD entries, identifies accounts with empty passwords, and generates comprehensive security audit reports. The playbook is designed for production environments and focuses on investigation and reporting only—it does NOT modify system state or remove users, allowing administrators to make informed decisions about remediation.

The playbook generates comprehensive JSON format reports that include security findings, severity levels, and remediation recommendations. Reports are automatically collected back to the control node for centralized analysis and monitoring.

## Features

- **Complete Automation**: End-to-end security audit from detection to detailed reporting
- **OS Compatibility**: Supports RHEL 7/8/9 and CentOS 7/8/9 with automatic validation
- **Production-Safe**: Read-only investigation that does not modify system state or remove users
- **Comprehensive Reporting**: Generates detailed JSON reports with security findings and severity levels
- **Centralized Collection**: Automatically collects reports back to control node for centralized analysis
- **Robust Error Handling**: Comprehensive error handling with block-rescue structures ensures execution continues even if individual tasks fail
- **Idempotent Design**: Safe to run multiple times without side effects
- **Comprehensive Validation**: OS compatibility checks and prerequisite validation
- **Security Severity Classification**: Classifies findings as CRITICAL or WARNING based on security impact
- **Optional Failure Mode**: Can be configured to fail playbook execution when critical issues are detected

## Prerequisites

### General Prerequisites

- Ansible 2.9 or later
- Ansible control node with network access to target hosts
- Target hosts: RHEL 7/8/9 or CentOS 7/8/9
- SSH access to target hosts (password or key-based authentication)
- Sudo/root privileges on target hosts

### Required Tools on Target Hosts

The playbook requires the following tools to be available on target hosts:

- **awk**: For parsing /etc/passwd and /etc/shadow files (usually pre-installed)
- **grep**: For searching sudoers files (usually pre-installed)
- **bash/sh**: For shell command execution (usually pre-installed)

These tools are typically pre-installed on RHEL/CentOS systems and do not require additional package installation.

## Files

- `privileged_account_audit_site.yml` - Main security audit playbook
- `inventory` - Host inventory file
- `ansible.cfg` - Ansible configuration file
- `README.md` - This file

## Usage

### 1. Prepare Inventory File

Edit the `inventory` file to define your target hosts. The playbook uses the `all` hosts group by default, but you can use specific groups:

```ini
[security_audit]
# Define target hosts for security audit here
# Example:
# server-01 ansible_host=192.168.1.100
# server-02 ansible_host=192.168.1.101

# Using the standard inventory format:
[rhel7]
Test-RHEL-7.9-1
Test-RHEL-7.9-2
Test-RHEL-7.9-3

[rhel8]
TEST-RHEL-8.9-1

[rhel9]
ansible25.example.com

# Group all RHEL hosts as security_audit
[security_audit:children]
rhel7
rhel8
rhel9
```

### 2. Verify Prerequisites

Before running the playbook, verify prerequisites on target hosts:

```bash
# Test connectivity
ansible all -i inventory -m ping

# Check if awk command is available
ansible all -i inventory -m shell -a "which awk"

# Check if grep command is available
ansible all -i inventory -m shell -a "which grep"

# Verify access to /etc/passwd and /etc/shadow (requires root)
ansible all -i inventory -m shell -a "test -r /etc/passwd && test -r /etc/shadow && echo 'Files accessible'"
```

### 3. Run the Playbook

#### Basic Execution

```bash
# Run audit on all hosts
ansible-playbook privileged_account_audit_site.yml -i inventory
```

#### Check Specific Host or Group

```bash
# Audit only RHEL 9 hosts
ansible-playbook privileged_account_audit_site.yml -i inventory --limit rhel9

# Audit a specific host
ansible-playbook privileged_account_audit_site.yml -i inventory --limit Test-RHEL-7.9-1
```

#### Fail on Critical Issues

```bash
# Fail playbook execution if critical security issues are found
ansible-playbook privileged_account_audit_site.yml -i inventory -e "fail_on_critical=true"
```

#### Dry Run (Check Mode)

```bash
# Preview what would be done (check mode)
ansible-playbook privileged_account_audit_site.yml -i inventory --check
```

#### Advanced Usage

```bash
# Run with increased parallelism for bulk execution
ansible-playbook privileged_account_audit_site.yml -i inventory --forks 10

# Run with verbose output for troubleshooting
ansible-playbook privileged_account_audit_site.yml -i inventory -v

# Run with extra verbose output
ansible-playbook privileged_account_audit_site.yml -i inventory -vvv
```

### 4. Review Reports

After successful execution, review the generated reports:

```bash
# List reports on control node
ls -lh reports/

# View a specific report (JSON format)
cat reports/privileged_account_audit_<hostname>.json | jq .

# View reports for all hosts
for report in reports/*.json; do
  echo "=== $report ==="
  cat "$report" | jq .
  echo ""
done

# Count critical issues across all hosts
for report in reports/*.json; do
  hostname=$(basename "$report" .json | sed 's/privileged_account_audit_//')
  critical_count=$(jq -r '.audit_summary.total_critical_issues' "$report")
  status=$(jq -r '.audit_summary.security_status' "$report")
  echo "$hostname: $critical_count critical issue(s), Status: $status"
done
```

## What Gets Configured

The playbook performs the following tasks:

1. **OS Compatibility Validation**: Verifies RHEL/CentOS 7/8/9 compatibility
2. **Prerequisites Validation**: Checks for required tools availability
3. **Rogue UID 0 User Detection**: Scans /etc/passwd for non-root users with UID 0
4. **Sudo NOPASSWD Audit**: Searches sudoers files for NOPASSWD entries
5. **Empty Password Detection**: Scans /etc/shadow for accounts with empty passwords
6. **Summary Reporting**: Displays investigation summary with security findings
7. **Report Generation**: Compiles all collected data into comprehensive JSON format report
8. **Report Collection**: Fetches reports back to control node for centralized analysis
9. **Summary Display**: Displays execution summary with key security statistics

## Configuration Details

### Report File Location

- **On Target Host**: `/tmp/privileged_account_audit_<hostname>.json`
- **On Control Node**: `./reports/privileged_account_audit_<hostname>.json`

### Customizing Report Path

You can customize the report path by overriding variables:

```bash
ansible-playbook privileged_account_audit_site.yml -i inventory \
  -e "report_path=/var/log/security_audit_{{ ansible_hostname }}.json" \
  -e "report_dest_path=./custom_reports/"
```

### Report Format

The generated report is in JSON format and includes:

- `hostname`: Target host hostname
- `os_distribution`: Operating system distribution
- `os_version`: Operating system version
- `audit_timestamp`: ISO8601 timestamp of audit
- `rogue_uid0_users`: Object containing:
  - `count`: Number of rogue UID 0 users found
  - `users`: Array of usernames with UID 0 (excluding root)
  - `severity`: "CRITICAL"
- `empty_password_accounts`: Object containing:
  - `count`: Number of accounts with empty passwords
  - `accounts`: Array of account names with empty passwords
  - `severity`: "CRITICAL"
- `sudo_nopasswd_entries`: Object containing:
  - `count`: Number of NOPASSWD entries found
  - `entries`: Array of NOPASSWD entry lines
  - `severity`: "WARNING"
- `audit_summary`: Object containing:
  - `total_critical_issues`: Total count of critical security issues
  - `total_warnings`: Total count of warnings
  - `security_status`: Overall security status (CRITICAL/WARNING/HEALTHY)
  - `recommendation`: Remediation recommendation

## Troubleshooting

### Playbook fails with "Unsupported operating system"

- Verify target host OS is RHEL 7/8/9 or CentOS 7/8/9
- Check `ansible_distribution` and `ansible_distribution_major_version` facts
- Remove any unsupported hosts from the inventory

### "Failed to detect rogue UID 0 users"

- Verify `/etc/passwd` file is accessible: `test -r /etc/passwd`
- Check if awk command is available: `which awk`
- Ensure sufficient permissions (playbook requires root/sudo access)
- Check file permissions: `ls -la /etc/passwd`

### "Failed to audit sudoers files"

- Verify sudoers files are accessible: `test -r /etc/sudoers`
- Check if grep command is available: `which grep`
- Ensure sufficient permissions (playbook requires root/sudo access)
- Check directory permissions: `ls -la /etc/sudoers.d/`

### "Failed to detect accounts with empty passwords"

- Verify `/etc/shadow` file is accessible: `test -r /etc/shadow`
- Check if awk command is available: `which awk`
- Ensure sufficient permissions (playbook requires root/sudo access)
- Check file permissions: `ls -la /etc/shadow`

### Report file was not created successfully

- **Check disk space on target host:**
  ```bash
  df -h /tmp
  ```
- **Check file permissions:**
  ```bash
  ls -la /tmp/privileged_account_audit_*.json
  ```
- **Check Ansible logs for errors:**
  ```bash
  ansible-playbook privileged_account_audit_site.yml -i inventory -v
  ```

### Reports not collected to control node

- **Check fetch module permissions:**
  ```bash
  ls -la reports/  # On control node
  ```
- **Verify source path exists on remote host:**
  ```bash
  ansible all -i inventory -m shell -a "ls -la /tmp/privileged_account_audit_*.json"
  ```
- **Check network connectivity:**
  ```bash
  ansible all -i inventory -m ping
  ```
- **Ensure reports directory exists:**
  ```bash
  mkdir -p reports/
  ```

### JSON parsing errors when viewing reports

- Install `jq` for better JSON viewing: `yum install -y jq` or `dnf install -y jq`
- Use `python -m json.tool` as an alternative: `cat report.json | python -m json.tool`

## Best Practices

1. **Regular Auditing**: Schedule regular security audits (e.g., daily or weekly):
   ```bash
   # Add to crontab
   0 2 * * * ansible-playbook /path/to/privileged_account_audit_site.yml -i /path/to/inventory
   ```

2. **Baseline Establishment**: Run initial audits to establish baseline security posture

3. **Alerting Integration**: Integrate with monitoring systems to alert on security findings:
   - Parse JSON reports for `security_status == "CRITICAL"`
   - Set up alerts for rogue UID 0 users
   - Monitor empty password account detection
   - Track sudo NOPASSWD entries

4. **Remediation Planning**: Use audit reports to plan remediation:
   - Review rogue UID 0 users and remove or reassign UIDs
   - Set passwords for empty password accounts
   - Review and restrict sudo NOPASSWD entries

5. **Report Archival**: Archive reports for historical analysis and compliance:
   ```bash
   # Archive reports with timestamp
   tar -czf security_audit_reports_$(date +%Y%m%d).tar.gz reports/
   ```

6. **Documentation**: Keep records of audit results and any remediation actions taken

7. **Testing**: Test playbook on non-production systems first

8. **Compliance**: Use audit reports for security compliance reporting (PCI-DSS, HIPAA, etc.)

## Understanding Security Findings

### What are Rogue UID 0 Users?

Rogue UID 0 users are non-root accounts that have been assigned UID 0, giving them root-level privileges. This is a critical security risk because:
- These accounts have full system access
- They may be created by attackers or misconfiguration
- They bypass normal access controls

### What are Empty Password Accounts?

Empty password accounts are user accounts that have no password set in /etc/shadow. This is a critical security risk because:
- Anyone can log in without authentication
- These accounts are vulnerable to unauthorized access
- They violate security best practices

### What are Sudo NOPASSWD Entries?

Sudo NOPASSWD entries allow users to execute sudo commands without entering a password. This is a warning-level security concern because:
- It reduces the security barrier for privilege escalation
- It may be necessary for automation but should be carefully reviewed
- It increases the risk if an account is compromised

### Remediation Strategies

1. **Rogue UID 0 Users**:
   - Remove the account if not needed
   - Reassign UID to a non-zero value if account is legitimate
   - Review account creation processes

2. **Empty Password Accounts**:
   - Set strong passwords for all accounts
   - Disable accounts that are not needed
   - Review account creation processes

3. **Sudo NOPASSWD Entries**:
   - Review each entry for necessity
   - Restrict to specific commands where possible
   - Use sudo rules with password requirements where appropriate

**Note**: This playbook does NOT perform any of these remediation actions. It only investigates and reports.

## Limitations

- **Read-Only Investigation**: This playbook only investigates and reports; it does not remove users or modify configurations
- **File Access Requirements**: Requires read access to /etc/passwd and /etc/shadow
- **Network Dependency**: Requires network connectivity between control node and target hosts
- **Storage Requirements**: Reports consume disk space on both target hosts and control node
- **Real-Time Detection**: Security findings may change between audits
- **No Automatic Remediation**: This playbook only performs investigation and reporting; remediation must be performed manually

## Security Considerations

1. **Credential Management**: Use Ansible Vault for sensitive credentials if needed
2. **Report Sensitivity**: Audit reports contain sensitive security information; protect report files appropriately
3. **Access Control**: Limit access to reports directory on control node
4. **Audit Trail**: Keep logs of all audit executions for compliance
5. **Network Security**: Ensure secure communication channels between control node and target hosts
6. **Privilege Escalation**: Playbook requires root/sudo access; ensure proper access controls
7. **Report Encryption**: Consider encrypting audit reports if they contain sensitive information

## Support

For issues or questions:

- Check Ansible logs: `ansible-playbook -v` for verbose output
- Review system logs: `journalctl -xe` on target hosts
- Verify tools: `which awk` and `which grep`
- Check Red Hat documentation: https://access.redhat.com/documentation/

## Example Report Output

```json
{
  "hostname": "test-server-01",
  "os_distribution": "RedHat",
  "os_version": "8.9",
  "audit_timestamp": "2026-02-06T12:00:00Z",
  "rogue_uid0_users": {
    "count": 0,
    "users": [],
    "severity": "CRITICAL"
  },
  "empty_password_accounts": {
    "count": 1,
    "accounts": [
      "testuser"
    ],
    "severity": "CRITICAL"
  },
  "sudo_nopasswd_entries": {
    "count": 2,
    "entries": [
      "admin ALL=(ALL) NOPASSWD: ALL",
      "automation ALL=(ALL) NOPASSWD: /usr/bin/systemctl"
    ],
    "severity": "WARNING"
  },
  "audit_summary": {
    "total_critical_issues": 1,
    "total_warnings": 2,
    "security_status": "CRITICAL",
    "recommendation": "CRITICAL: Immediate action required. Review and remediate rogue UID 0 users and empty password accounts."
  }
}
```

## License

📜 License Type: End User License Agreement (EULA)
🔒 Authorization: Subscription-based License

## Author

GCG AAP SSA Team + v3.01 20260217

