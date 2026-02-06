# Zombie Process Root Cause Analysis and Reporting

## Overview

This playbook automates zombie process investigation and root cause analysis on RHEL/CentOS systems. It identifies all zombie processes (Z state) in the system, analyzes their parent process relationships, and generates detailed investigation reports. The playbook is designed for production environments and focuses on investigation and reporting only—it does NOT perform aggressive kill operations, allowing administrators to make informed decisions about remediation.

The playbook generates comprehensive JSON format reports that include zombie process details, parent process information, and investigation timestamps. Reports are automatically collected back to the control node for centralized analysis and monitoring.
### screenshots
<img width="2031" height="1244" alt="image" src="https://github.com/user-attachments/assets/7687348e-9313-4bff-a3cf-c45465903d26" />
<img width="2536" height="875" alt="image" src="https://github.com/user-attachments/assets/631ca65c-c10d-423b-8e28-7c174c7de3e5" />



## Features

- **Complete Automation**: End-to-end zombie process investigation from detection to detailed reporting
- **OS Compatibility**: Supports RHEL 7/8/9 and CentOS 7/8/9 with automatic validation
- **Production-Safe**: Read-only investigation that does not modify system state or kill processes
- **Comprehensive Reporting**: Generates detailed JSON reports with zombie process details and parent-child relationships
- **Centralized Collection**: Automatically collects reports back to control node for centralized analysis
- **Robust Error Handling**: Comprehensive error handling with block-rescue structures ensures execution continues even if individual tasks fail
- **Idempotent Design**: Safe to run multiple times without side effects
- **Comprehensive Validation**: OS compatibility checks and prerequisite validation
- **Parent Process Analysis**: Detailed investigation of parent processes for each zombie to identify root causes

## Prerequisites

### General Prerequisites

- Ansible 2.9 or later
- Ansible control node with network access to target hosts
- Target hosts: RHEL 7/8/9 or CentOS 7/8/9
- SSH access to target hosts (password or key-based authentication)
- Sudo/root privileges on target hosts

### Required Tools on Target Hosts

The playbook requires the following tools to be available on target hosts:

- **ps**: For process listing and state detection (usually pre-installed)
- **bash**: For shell script execution (usually pre-installed)

These tools are typically pre-installed on RHEL/CentOS systems and do not require additional package installation.

## Files

- `zombie_process_rca_site.yml` - Main zombie process investigation playbook
- `inventory` - Host inventory file
- `ansible.cfg` - Ansible configuration file
- `README.md` - This file

## Usage

### 1. Prepare Inventory File

Edit the `inventory` file to define your target hosts. The playbook uses the `all` hosts group by default, but you can use specific groups:

```ini
[zombie_investigation]
# Define target hosts for zombie process investigation here
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

# Group all RHEL hosts as zombie_investigation
[zombie_investigation:children]
rhel7
rhel8
rhel9
```

### 2. Verify Prerequisites

Before running the playbook, verify prerequisites on target hosts:

```bash
# Test connectivity
ansible all -i inventory -m ping

# Check if ps command is available
ansible all -i inventory -m shell -a "which ps"

# Verify system processes
ansible all -i inventory -m shell -a "ps aux | head -5"
```

### 3. Run the Playbook

#### Basic Execution

```bash
# Run investigation on all hosts
ansible-playbook zombie_process_rca_site.yml -i inventory
```

#### Check Specific Host or Group

```bash
# Investigate only RHEL 9 hosts
ansible-playbook zombie_process_rca_site.yml -i inventory --limit rhel9

# Investigate a specific host
ansible-playbook zombie_process_rca_site.yml -i inventory --limit Test-RHEL-7.9-1
```

#### Dry Run (Check Mode)

```bash
# Preview what would be done (check mode)
ansible-playbook zombie_process_rca_site.yml -i inventory --check
```

#### Advanced Usage

```bash
# Run with increased parallelism for bulk execution
ansible-playbook zombie_process_rca_site.yml -i inventory --forks 10

# Run with verbose output for troubleshooting
ansible-playbook zombie_process_rca_site.yml -i inventory -v

# Run with extra verbose output
ansible-playbook zombie_process_rca_site.yml -i inventory -vvv
```

### 4. Review Reports

After successful execution, review the generated reports:

```bash
# List reports on control node
ls -lh reports/

# View a specific report (JSON format)
cat reports/zombie_investigation_<hostname>.json | jq .

# View reports for all hosts
for report in reports/*.json; do
  echo "=== $report ==="
  cat "$report" | jq .
  echo ""
done

# Count zombies across all hosts
for report in reports/*.json; do
  hostname=$(basename "$report" .json | sed 's/zombie_investigation_//')
  zombie_count=$(jq -r '.zombie_count' "$report")
  echo "$hostname: $zombie_count zombie(s)"
done
```

## What Gets Configured

The playbook performs the following tasks:

1. **OS Compatibility Validation**: Verifies RHEL/CentOS 7/8/9 compatibility
2. **Prerequisites Validation**: Checks for required tools availability
3. **Zombie Process Detection**: Scans all processes to identify zombie processes (Z state)
4. **Zombie Process Filtering**: Extracts and counts zombie processes from process list
5. **Summary Reporting**: Displays investigation summary with zombie count
6. **Parent Process Analysis**: For each zombie, collects detailed information about its parent process
7. **Report Generation**: Compiles all collected data into comprehensive JSON format report
8. **Report Collection**: Fetches reports back to control node for centralized analysis
9. **Summary Display**: Displays execution summary with key statistics

## Configuration Details

### Report File Location

- **On Target Host**: `/tmp/zombie_investigation_<hostname>.json`
- **On Control Node**: `./reports/zombie_investigation_<hostname>.json`

### Customizing Report Path

You can customize the report path by overriding variables:

```bash
ansible-playbook zombie_process_rca_site.yml -i inventory \
  -e "report_path=/var/log/zombie_investigation_{{ ansible_hostname }}.json" \
  -e "report_dest_path=./custom_reports/"
```

### Report Format

The generated report is in JSON format and includes:

- `hostname`: Target host hostname
- `os_distribution`: Operating system distribution
- `os_version`: Operating system version
- `investigation_timestamp`: ISO8601 timestamp of investigation
- `zombie_count`: Number of zombie processes found
- `zombie_processes`: Array of zombie process information (PID, PPID, state, command)
- `detailed_investigation`: Array of detailed parent process information for each zombie
- `status`: Investigation status message

## Troubleshooting

### Playbook fails with "Unsupported operating system"

- Verify target host OS is RHEL 7/8/9 or CentOS 7/8/9
- Check `ansible_distribution` and `ansible_distribution_major_version` facts
- Remove any unsupported hosts from the inventory

### "Failed to query process information"

- Verify `ps` command is available: `which ps`
- Check if process table is accessible: `ps aux | head -5`
- Ensure sufficient permissions (playbook requires root/sudo access)
- Check system load and process table size

### "No zombie processes found"

This is normal and indicates a healthy system. The playbook will still generate a report with `zombie_count: 0`.

### Report file was not created successfully

- **Check disk space on target host:**
  ```bash
  df -h /tmp
  ```
- **Check file permissions:**
  ```bash
  ls -la /tmp/zombie_investigation_*.json
  ```
- **Check Ansible logs for errors:**
  ```bash
  ansible-playbook zombie_process_rca_site.yml -i inventory -v
  ```

### Reports not collected to control node

- **Check fetch module permissions:**
  ```bash
  ls -la reports/  # On control node
  ```
- **Verify source path exists on remote host:**
  ```bash
  ansible all -i inventory -m shell -a "ls -la /tmp/zombie_investigation_*.json"
  ```
- **Check network connectivity:**
  ```bash
  ansible all -i inventory -m ping
  ```
- **Ensure reports directory exists:**
  ```bash
  mkdir -p reports/
  ```

### Parent process information not available

- This is normal if the parent process has already terminated
- The report will indicate "Parent process no longer exists" for such cases
- This is a common scenario with zombie processes—the parent may have exited without properly reaping its children

### JSON parsing errors when viewing reports

- Install `jq` for better JSON viewing: `yum install -y jq` or `dnf install -y jq`
- Use `python -m json.tool` as an alternative: `cat report.json | python -m json.tool`

## Best Practices

1. **Regular Monitoring**: Schedule regular zombie process checks (e.g., daily or weekly):
   ```bash
   # Add to crontab
   0 2 * * * ansible-playbook /path/to/zombie_process_rca_site.yml -i /path/to/inventory
   ```

2. **Baseline Establishment**: Run initial checks to establish baseline zombie process counts

3. **Alerting Integration**: Integrate with monitoring systems to alert on zombie process detection:
   - Parse JSON reports for `zombie_count > 0`
   - Set up alerts for persistent zombie processes
   - Monitor parent process health

4. **Remediation Planning**: Use investigation reports to plan remediation:
   - Identify patterns in zombie process creation
   - Review parent process behavior
   - Plan application fixes or process management improvements

5. **Report Archival**: Archive reports for historical analysis:
   ```bash
   # Archive reports with timestamp
   tar -czf zombie_reports_$(date +%Y%m%d).tar.gz reports/
   ```

6. **Documentation**: Keep records of investigation results and any remediation actions taken

7. **Testing**: Test playbook on non-production systems first

8. **Root Cause Analysis**: Use parent process information to identify application bugs or misconfigurations that cause zombie processes

## Understanding Zombie Processes

### What are Zombie Processes?

Zombie processes (Z state) are processes that have completed execution but still have an entry in the process table. They occur when:
- A child process terminates
- The parent process does not call `wait()` or `waitpid()` to reap the child
- The child process entry remains in the process table

### Why Investigate Zombie Processes?

- **Resource Leaks**: While zombies don't consume CPU or memory, they consume process table slots
- **System Health Indicator**: High zombie counts may indicate application bugs
- **Parent Process Issues**: Zombies often indicate problems with parent process management
- **System Stability**: Excessive zombies can eventually exhaust process table capacity

### Remediation Strategies

1. **Fix Parent Process**: Modify the parent process to properly reap children using `wait()` or signal handlers
2. **Kill Parent Process**: If the parent is still running, killing it will transfer zombies to init (PID 1), which will reap them
3. **System Reboot**: As a last resort, rebooting will clear all zombies (not recommended for production)

**Note**: This playbook does NOT perform any of these remediation actions. It only investigates and reports.

## Limitations

- **Read-Only Investigation**: This playbook only investigates and reports; it does not kill or modify processes
- **Parent Process Availability**: Parent process information may not be available if the parent has already terminated
- **Process Table Size**: Very large process tables may take longer to scan
- **Network Dependency**: Requires network connectivity between control node and target hosts
- **Storage Requirements**: Reports consume disk space on both target hosts and control node
- **Real-Time Detection**: Zombie processes may appear or disappear between scans
- **No Automatic Remediation**: This playbook only performs investigation and reporting; remediation must be performed manually

## Security Considerations

1. **Credential Management**: Use Ansible Vault for sensitive credentials if needed
2. **Report Sensitivity**: Investigation reports may contain process information; protect report files appropriately
3. **Access Control**: Limit access to reports directory on control node
4. **Audit Trail**: Keep logs of all investigation executions for compliance
5. **Network Security**: Ensure secure communication channels between control node and target hosts
6. **Privilege Escalation**: Playbook requires root/sudo access; ensure proper access controls

## Support

For issues or questions:

- Check Ansible logs: `ansible-playbook -v` for verbose output
- Review system logs: `journalctl -xe` on target hosts
- Verify process tools: `which ps` and `ps aux | head -5`
- Check Red Hat documentation: https://access.redhat.com/documentation/

## Example Report Output

```json
{
  "hostname": "test-server-01",
  "os_distribution": "RedHat",
  "os_version": "8.9",
  "investigation_timestamp": "2026-02-06T12:00:00Z",
  "zombie_count": 2,
  "zombie_processes": [
    "12345 1000 Z defunct_process",
    "12346 1000 Z defunct_process"
  ],
  "detailed_investigation": [
    "==========================================\nZombie Process Details:\n  PID: 12345\n  Parent PID: 1000\n  Process Name: defunct_process\n  Full Command: 12345 1000 Z defunct_process\n\nParent Process Information:\n  UID   PID  PPID  C STIME TTY          TIME CMD\n  root  1000     1  0 10:00 ?        00:00:01 parent_process\n==========================================",
    "==========================================\nZombie Process Details:\n  PID: 12346\n  Parent PID: 1000\n  Process Name: defunct_process\n  Full Command: 12346 1000 Z defunct_process\n\nParent Process Information:\n  UID   PID  PPID  C STIME TTY          TIME CMD\n  root  1000     1  0 10:00 ?        00:00:01 parent_process\n=========================================="
  ]
}
```

## License

📜 License Type: End User License Agreement (EULA)
🔒 Authorization: Subscription-based License

## Author

GCG AAP SSA Team + v3.01 20260217


