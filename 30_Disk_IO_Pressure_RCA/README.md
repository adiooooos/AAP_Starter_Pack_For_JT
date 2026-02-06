# Disk IO Pressure Root Cause Analysis and Reporting

## Overview

This playbook automates disk IO pressure investigation and root cause analysis on RHEL/CentOS systems. It collects detailed disk IO statistics, identifies top IO-consuming processes, detects processes stuck in Disk Sleep (D state / uninterruptible sleep), and generates structured JSON investigation reports.  

The playbook is designed for production environments and is **read-only**: it does **not** kill processes, change kernel parameters, or modify storage configuration. It focuses on investigation and reporting so that administrators can make informed decisions about remediation.
### screenshots
<img width="2031" height="1195" alt="image" src="https://github.com/user-attachments/assets/1c525ed5-ee8c-4912-991a-c3848c2c54bc" />
<img width="2536" height="564" alt="image" src="https://github.com/user-attachments/assets/deba938d-ecf5-4fdd-9e43-d5e69ac8d8d5" />


## Features

- **Disk IO Pressure Visibility**: Uses `iostat` to capture extended IO utilization and latency metrics per device
- **High IO Process Detection**: Uses `pidstat` to identify processes with heavy IO activity
- **D State Process Detection**: Detects processes in Disk Sleep (D state), which often indicate blocked IO or storage issues
- **OS Compatibility Validation**: Supports RHEL 7/8/9 and CentOS 7/8/9 with automatic validation
- **Production-Safe Design**: Read-only investigation; no disruptive actions are taken
- **Structured Reporting**: Generates JSON reports containing IO statistics, high IO processes, and D state process details
- **Centralized Collection**: Automatically collects reports back to the control node for centralized analysis
- **Robust Error Handling**: Uses `block`/`rescue` to handle command failures while allowing the playbook to continue
- **Bulk Execution Friendly**: Designed to run safely across many hosts in parallel

## Prerequisites

### General Prerequisites

- Ansible 2.9 or later
- Ansible control node with network access to target hosts
- Target hosts: RHEL 7/8/9 or CentOS 7/8/9
- SSH access to target hosts (password or key-based authentication)
- Sudo/root privileges on target hosts

### Required Tools on Target Hosts

The playbook relies on the following tools on target hosts:

- **sysstat** package providing:
  - `iostat` – disk IO statistics
  - `pidstat` – per-process IO statistics
- **ps** – for process state inspection (usually pre-installed)
- **bash/sh** – for shell command execution (usually pre-installed)

If `iostat` or `pidstat` is not available, the playbook will continue to run, but some sections of the report will be marked as unavailable.

## Files

- `disk_io_pressure_rca_site.yml` - Main disk IO pressure investigation playbook
- `inventory` - Host inventory file
- `ansible.cfg` - Ansible configuration file
- `README.md` - This file

## Usage

### 1. Prepare Inventory File

Edit the `inventory` file to define your target hosts. Example layout:

```ini
[disk_io_investigation]
# Define target hosts for disk IO investigation here
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

# Group all RHEL hosts as disk_io_investigation
[disk_io_investigation:children]
rhel7
rhel8
rhel9
```

You can also reuse your existing global inventory that defines `[rhel7]`, `[rhel8]`, and `[rhel9]` groups, as long as you reference it when running the playbook.

### 2. Verify Prerequisites

Before running the playbook, verify prerequisites on target hosts:

```bash
# Test connectivity
ansible all -i inventory -m ping

# Check if iostat and pidstat are available (from sysstat)
ansible all -i inventory -m shell -a "which iostat || echo 'iostat not found'"
ansible all -i inventory -m shell -a "which pidstat || echo 'pidstat not found'"

# Quick check of current disk IO and processes (optional)
ansible all -i inventory -m shell -a "iostat -xz 1 1"   # if available
ansible all -i inventory -m shell -a "ps aux | head -5"
```

If `iostat`/`pidstat` are missing, install `sysstat` using your standard package management procedures.

### 3. Run the Playbook

#### Basic Execution

```bash
# Run disk IO pressure investigation on all hosts in inventory
ansible-playbook disk_io_pressure_rca_site.yml -i inventory
```

#### Limit to Specific Host or Group

```bash
# Investigate only RHEL 9 hosts
ansible-playbook disk_io_pressure_rca_site.yml -i inventory --limit rhel9

# Investigate a specific host
ansible-playbook disk_io_pressure_rca_site.yml -i inventory --limit Test-RHEL-7.9-1
```

#### Dry Run (Check Mode)

```bash
# Preview tasks (note: command output is not simulated)
ansible-playbook disk_io_pressure_rca_site.yml -i inventory --check
```

#### Advanced Usage

```bash
# Run with increased parallelism for bulk execution
ansible-playbook disk_io_pressure_rca_site.yml -i inventory --forks 10

# Run with verbose output for troubleshooting
ansible-playbook disk_io_pressure_rca_site.yml -i inventory -v

# Extra verbose output
ansible-playbook disk_io_pressure_rca_site.yml -i inventory -vvv
```

### 4. Review Reports

After successful execution, review the generated reports on the control node:

```bash
# List reports on control node
ls -lh reports/

# View a specific report (JSON format)
cat reports/disk_io_investigation_<hostname>.json | jq .

# View reports for all hosts
for report in reports/disk_io_investigation_*.json; do
  echo "=== $report ==="
  cat "$report" | jq .
  echo ""
done
```

You can parse the JSON to build dashboards or integrate with monitoring/alerting systems.

## What Gets Configured

The playbook performs the following tasks:

1. **OS Compatibility Validation**: Verifies that the target system is RHEL/CentOS 7/8/9. Unsupported systems will fail with a clear error message:  
   `"Unsupported operating system. This playbook is not available for the current OS."`
2. **Prerequisites Validation**: Checks availability of `iostat` and `pidstat` (sysstat). Missing tools are reported but do not abort the playbook.
3. **Disk IO Statistics Collection**: Runs `iostat -xz 1 3` to collect detailed disk IO metrics.
4. **High IO Process Detection**: Runs `pidstat -d 1 1` to identify processes with high IO usage.
5. **D State Process Detection**: Uses `ps aux` to find processes in Disk Sleep (D state).
6. **Summary Reporting**: Prints a human-readable summary of IO statistics, high IO processes, and D state processes.
7. **JSON Report Generation**: Combines all collected data into a structured JSON report on each target host.
8. **Report Collection**: Fetches JSON reports back to the control node into a `reports/` directory.
9. **Final Summary**: Prints a concise summary with IO pressure indicators and report file paths.

The playbook does **not** change system configuration or kill any processes.

## Configuration Details

### Report File Location

- **On Target Host**: `/tmp/disk_io_investigation_<hostname>.json`
- **On Control Node**: `./reports/disk_io_investigation_<hostname>.json`

### Customizing Report Paths

You can override report paths at runtime:

```bash
ansible-playbook disk_io_pressure_rca_site.yml -i inventory \
  -e "report_path=/var/log/disk_io_investigation_{{ ansible_hostname }}.json" \
  -e "report_dest_path=./disk_io_reports/"
```

### Report Format

The generated JSON report includes (fields may evolve over time):

- `hostname`: Target system hostname
- `os_distribution`: OS distribution (e.g., `RedHat`)
- `os_version`: OS version string
- `investigation_timestamp`: ISO 8601 timestamp of the investigation
- `sysstat_available`: Whether sysstat tools were detected
- `io_statistics`:
  - `available`: Whether `iostat` output is available
  - `data`: Raw `iostat` output
- `high_io_processes`:
  - `available`: Whether `pidstat` output is available
  - `data`: Raw `pidstat` output
- `d_state_processes`:
  - `count`: Number of processes in D state
  - `data`: Raw text listing of processes in D state
  - `processes`: List of individual lines for easier parsing
- `analysis_summary`:
  - `io_pressure_detected`: Heuristic indicator based on D state processes and high IO processes
  - `recommendation`: High-level guidance based on collected data

## Troubleshooting

### Playbook fails with "Unsupported operating system"

- Verify that the target host is RHEL 7/8/9 or CentOS 7/8/9.
- Check Ansible facts: `ansible -i inventory all -m setup -a 'filter=ansible_distribution*'`.
- Remove unsupported hosts from the inventory or limit the play to supported groups.

### IO statistics not available (`iostat not available`)

- Confirm `iostat` is installed:
  ```bash
  which iostat
  rpm -q sysstat || dnf list installed sysstat || yum list installed sysstat
  ```
- Install `sysstat` if needed (for example):
  ```bash
  yum install -y sysstat   # RHEL/CentOS 7
  dnf install -y sysstat   # RHEL/CentOS 8/9
  ```

### High IO process data not available (`pidstat not available`)

- Confirm `pidstat` is available (also part of sysstat):
  ```bash
  which pidstat
  ```
- Install `sysstat` as above.

### No processes in D state found

This is usually a **good** sign and indicates no obvious IO blocking from processes stuck in uninterruptible sleep. The report will still be generated with `d_state_processes.count = 0`.

### Report file not created or not fetched

- Check disk space on target host:
  ```bash
  df -h /tmp
  ```
- Verify report file on target host:
  ```bash
  ls -la /tmp/disk_io_investigation_*.json
  ```
- Check `reports/` directory on control node:
  ```bash
  ls -la reports/
  ```
- Re-run the playbook with verbose output:
  ```bash
  ansible-playbook disk_io_pressure_rca_site.yml -i inventory -v
  ```

## Best Practices

1. **Regular Monitoring**: Schedule regular disk IO investigations (e.g., daily during off-peak hours):
   ```bash
   0 2 * * * ansible-playbook /path/to/disk_io_pressure_rca_site.yml -i /path/to/inventory
   ```
2. **Baseline Establishment**: Run the playbook under normal load to establish a baseline for IO metrics and high IO processes.
3. **Alerting Integration**: Integrate JSON reports with monitoring tools to alert when `io_pressure_detected` is `Yes` or when `d_state_processes.count` is above a threshold.
4. **Correlation with Storage Metrics**: Combine Ansible reports with storage array metrics, SAN statistics, or cloud disk metrics for deeper analysis.
5. **Documentation and RCA**: Use reports as evidence in formal RCA (Root Cause Analysis) documents when investigating IO-related incidents.

## Limitations

- **Read-Only Investigation**: The playbook does not remediate issues; it only collects and reports data.
- **Tool Availability**: If `sysstat` is not installed, IO metrics will be limited.
- **Sampling Window**: `iostat -xz 1 3` and `pidstat -d 1 1` provide a short sampling window; they may miss intermittent spikes.
- **Real-Time Changes**: IO load may change between measurements; results represent a snapshot, not continuous monitoring.
- **Large Environments**: Very large environments may generate many JSON reports—plan storage and log rotation accordingly.

## Security Considerations

1. **Credential Management**: Use Ansible Vault or a secure credential store for any sensitive data.
2. **Report Sensitivity**: Reports can contain process names and command lines; restrict access to the `reports/` directory.
3. **Privilege Escalation**: The playbook requires root/sudo to access full IO statistics; ensure proper RBAC and auditing.
4. **Network Security**: Ensure secure channels between control node and managed hosts (e.g., SSH with hardened configuration).

## License

📜 License Type: End User License Agreement (EULA)  
🔒 Authorization: Subscription-based License

## Author

GCG AAP SSA Team + v3.01 20260217



