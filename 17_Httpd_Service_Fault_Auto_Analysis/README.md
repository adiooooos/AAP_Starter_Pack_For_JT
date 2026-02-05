# RHEL Httpd Service Fault Diagnosis Automation

## Overview

This Ansible playbook automates comprehensive httpd service fault diagnosis for RHEL/CentOS systems, providing systematic troubleshooting capabilities including package status checks, service state analysis, configuration validation, network port diagnostics, security policy verification, and detailed reporting.

### screenshots
<img width="2510" height="1333" alt="image" src="https://github.com/user-attachments/assets/c03d88c9-f56b-4e97-8b39-0ac32866f1d5" />


**Key Feature**: All configuration parameters are centralized in `group_vars/all.yml`, making it easy to customize the playbook for your specific environment without modifying the playbook code itself.

## Features

### ✅ Package Installation Check

- Automatically checks httpd package installation status
- Retrieves package version information
- All checks continue even if individual tasks fail

### ✅ Service Status Analysis

- Checks systemd service active status (running/stopped)
- Checks systemd service enabled status (enabled/disabled at boot)
- Validates service dependency relationships
- Comprehensive service health assessment

### ✅ Configuration Syntax Validation

- Runs `httpd -t` syntax check
- Validates configuration file paths
- Identifies configuration errors with detailed output
- Non-blocking: continues even if syntax check fails

### ✅ Network Port Diagnostics

- Checks port listening status using `ss -lntp`
- Analyzes process binding to ports 80/443
- Detects port conflicts with other services
- Comprehensive port analysis

### ✅ Security Policy Checks

- Checks SELinux working mode (Enforcing/Permissive/Disabled)
- Verifies critical SELinux boolean values for httpd
- Checks firewalld running status
- Validates firewalld services and ports configuration
- All security checks are non-blocking

### ✅ Log Analysis

- Extracts error log content (configurable line count)
- Analyzes system journal logs via journalctl
- Searches for fault clues in logs
- Comprehensive log-based diagnosis

### ✅ Comprehensive Reporting

- Generates structured diagnostic reports with problem identification
- Severity-based issue classification (ROOT CAUSE, POTENTIAL ISSUE, NO ISSUES)
- Targeted recommendations based on findings
- Includes timestamps, host information, and complete diagnosis results

### ✅ Robust Error Handling

- **All checks are non-blocking**: Individual task failures do not stop execution
- **Graceful degradation**: Continues with other checks if one fails
- **Error collection and reporting**: All errors and warnings are collected and displayed in summaries
- **Safe default values**: Prevents failures from missing variables
- **Block-rescue structure**: Each check is wrapped in block-rescue to ensure continuation

### ✅ Multi-OS Support

- Supports RHEL 7/8/9 and CentOS 7/8/9
- OS compatibility checks with clear error messages

## Supported Operating Systems

- **RHEL 7/8/9**
- **CentOS 7/8/9**

The playbook includes OS compatibility checks and will fail gracefully if run on unsupported systems.

## Prerequisites

1. **Ansible Installation**

   ```bash
   ansible --version
   ```

   Ensure Ansible 2.9+ is installed.

2. **SSH Key Authentication**

   ```bash
   ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
   ssh-copy-id root@target_server_ip
   ```

3. **Target Host Requirements**

   - SSH access with sudo privileges
   - Python 2.7 or 3.x installed
   - Network connectivity (if package installation is needed)

## Project Structure

```
Ansible救火热线系列之(19)Httpd服务故障自动化分析/
├── ansible.cfg                    # Ansible configuration
├── inventory                       # Host inventory file
├── httpd_diagnosis_site.yml        # Main playbook
├── group_vars/
│   └── all.yml                     # Global variables configuration (CUSTOMIZE HERE)
├── templates/
│   └── httpd_diagnosis_report.j2   # Diagnostic report template
└── README.md                       # This file
```

## Configuration

### ⭐ Customization via `group_vars/all.yml`

**The most important file for customization is `group_vars/all.yml`.** This file contains all configurable parameters that control the behavior of the playbook. You can customize the entire playbook behavior by editing this single file.

### 1. Inventory Setup

Edit the `inventory` file to add your target hosts. You can organize hosts by groups:

```ini
[web]
web1.example.com
10.166.208.232

# Or use the standard inventory format:
[rhel7]
Test-RHEL-7.9-1
Test-RHEL-7.9-2
Test-RHEL-7.9-3

[rhel8]
TEST-RHEL-8.9-1

[rhel9]
ansible25.example.com
```

### 2. Variable Configuration

Edit `group_vars/all.yml` to customize:

- **Service and Package Names**: Change `httpd_service` and `httpd_package` if using different names
- **Port Configuration**: Modify `http_ports` and `https_ports` lists
- **Log Paths**: Adjust `httpd_error_log` and `httpd_access_log` paths
- **Report Location**: Change `report_output_path` to your preferred location
- **Service Start Attempt**: Set `attempt_service_start: true` to attempt starting the service (default: false for analysis-only mode)
- **SELinux Booleans**: Add or remove boolean values in `selinux_booleans_to_check`
- **Journal Log Lines**: Adjust `collect_journal_lines` to change log tail size

## Usage

### Basic Diagnosis (Analysis Only, No Changes)

```bash
ansible-playbook httpd_diagnosis_site.yml -i inventory
```

This mode performs all diagnostic checks without making any changes to the system.

### Diagnosis with Service Start Attempt

```bash
ansible-playbook httpd_diagnosis_site.yml -i inventory -e attempt_service_start=true
```

This mode attempts to start the httpd service to capture startup errors. Use with caution in production environments.

### Run on Specific Host Group

```bash
ansible-playbook httpd_diagnosis_site.yml -i inventory --limit rhel9
```

### Run with Verbose Output

```bash
ansible-playbook httpd_diagnosis_site.yml -i inventory -v
```

### Check Mode (Dry Run)

```bash
ansible-playbook httpd_diagnosis_site.yml -i inventory --check
```

Note: Most tasks are read-only, so check mode may not show significant differences.

## Diagnosis Coverage

### ✅ Package Check

- Httpd package installation status
- Package version information

### ✅ Service Status Analysis

- systemd service active status
- Boot-time auto-start configuration
- Service dependency relationships

### ✅ Configuration Syntax Validation

- `httpd -t` syntax check
- Configuration file path validation
- Configuration error identification

### ✅ Network Port Diagnostics

- Port listening status check
- Process binding analysis
- Port conflict detection

### ✅ Security Policy Checks

- SELinux working mode
- Critical boolean value status
- Firewall rules check (firewalld services and ports)

### ✅ Log Analysis

- Error log extraction
- System log analysis (journalctl)
- Fault clue aggregation

## Output

### Diagnostic Report

The playbook generates a comprehensive diagnostic report at the location specified in `report_output_path` (default: `/root/httpd_diagnosis_report.txt`).

The report includes:

- **Basic Information**: OS, kernel, SELinux mode
- **Package and Service Status**: Installation status, service state
- **Configuration Syntax Check**: Results from `httpd -t`
- **Port Listening and Firewall**: Port status, firewall configuration
- **SELinux Boolean Values**: Current boolean settings
- **Configuration and Logs**: Config file existence, error logs, journalctl output
- **Root Cause Analysis**: Automated problem identification with recommendations
- **Common Fault Clues**: Troubleshooting tips and solutions

### Console Output

The playbook provides real-time feedback during execution:

- Start information with host details
- Progress updates for each check
- Warnings for failed checks (non-blocking)
- Final summary with diagnosis status

## Error Handling

### Robust Design Principles

1. **Non-Blocking Checks**: All diagnostic tasks use `failed_when: false` to prevent execution stops
2. **Block-Rescue Structure**: Each check is wrapped in `block-rescue` to ensure continuation
3. **Error Collection**: All errors and warnings are collected in variables
4. **Graceful Degradation**: Missing information is handled with safe defaults
5. **Comprehensive Reporting**: All collected information is included in the final report

### Example Error Handling

```yaml
- name: Check httpd package
  block:
    - name: Query package
      ansible.builtin.command: "rpm -q {{ httpd_package }}"
      register: rpm_query
      failed_when: false
      changed_when: false
  rescue:
    - name: Record failure
      ansible.builtin.set_fact:
        diagnosis_warnings: "{{ diagnosis_warnings + ['Failed to check package'] }}"
    - name: Continue with warning
      ansible.builtin.debug:
        msg: "Warning: Package check failed. Continuing with other checks."
```

## Customization Examples

### Change Report Output Location

Edit `group_vars/all.yml`:

```yaml
report_output_path: /var/log/httpd_diagnosis_report.txt
```

### Add Custom Ports

Edit `group_vars/all.yml`:

```yaml
http_ports:
  - 80
  - 8080
https_ports:
  - 443
  - 8443
```

### Enable Service Start Attempt

Edit `group_vars/all.yml`:

```yaml
attempt_service_start: true
```

Or override at runtime:

```bash
ansible-playbook httpd_diagnosis_site.yml -i inventory -e attempt_service_start=true
```

### Add More SELinux Booleans

Edit `group_vars/all.yml`:

```yaml
selinux_booleans_to_check:
  - httpd_can_network_connect
  - httpd_can_network_connect_db
  - httpd_can_sendmail
  - httpd_use_cifs
  - httpd_use_nfs
  - httpd_anon_write  # Add custom boolean
```

## Best Practices

- **Test First**: Use `--check` mode to preview execution
- **Review Reports**: Always review the generated diagnostic report for comprehensive analysis
- **Production Safety**: Default mode is analysis-only; service start attempts require explicit enablement
- **Batch Execution**: Use inventory groups to diagnose multiple hosts simultaneously
- **Regular Diagnostics**: Run periodic diagnostics to maintain service health awareness

## Troubleshooting

### Playbook Fails on OS Check

**Error**: "Unsupported operating system"

**Solution**: Ensure target hosts are RHEL 7/8/9 or CentOS 7/8/9. Check `ansible_distribution` and `ansible_distribution_major_version` facts.

### Report Not Generated

**Error**: Report file not found

**Solution**: 
- Check write permissions on target host for `report_output_path`
- Verify template file exists: `templates/httpd_diagnosis_report.j2`
- Review playbook output for template errors

### Some Checks Show "unknown" or "N/A"

**Behavior**: Expected for non-blocking design

**Solution**: This is normal behavior. The playbook continues even if individual checks fail. Review the warnings section in the report to identify which checks failed and why.

### Service Start Attempt Fails

**Error**: Service cannot be started

**Solution**: This is expected if there are configuration errors. Review the diagnostic report for:
- Configuration syntax errors
- Missing dependencies
- Port conflicts
- SELinux denials
- Permission issues

## Example Output

```
═══════════════════════════════════════════════════════════════
🎯 HTTPD SERVICE DIAGNOSIS SUMMARY
═══════════════════════════════════════════════════════════════
📋 Diagnosis Status:
   • Package Installed: ✅ Yes
   • Service Active: inactive
   • Service Enabled: disabled
   • Syntax Check: ✅ PASSED
   • SELinux Mode: Permissive
   • Firewalld Running: ✅ Yes

✅ No critical errors
✅ No warnings

📝 Report Location: /root/httpd_diagnosis_report.txt

📝 Next Steps:
   • Review the generated diagnostic report
   • Address any identified issues based on recommendations
   • Check service logs for detailed error information
═══════════════════════════════════════════════════════════════
```

## Advanced Usage

### Parallel Execution

```bash
ansible-playbook httpd_diagnosis_site.yml -i inventory --forks 10
```

### Tag-Based Execution

The playbook supports tags for selective execution (all tasks are tagged with `always` by default).

### Integration with AAP

This playbook can be integrated into Ansible Automation Platform (AAP) as:
- A job template for on-demand diagnosis
- A scheduled job for periodic health checks
- Part of a larger automation workflow

## Support

For issues, questions, or contributions, please refer to the development guidelines in `AAP_Starter_Pack场景改写概要.md`.

## License

📜 License Type: End User License Agreement (EULA)  
🔒 Authorization: Through Subscription

---

**Author**: GCG AAP SSA Team + v3.01 Date 20260217


