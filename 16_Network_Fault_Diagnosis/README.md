# RHEL Network Latency Diagnosis Automation

## Overview

This Ansible playbook automates network latency diagnosis for RHEL systems, providing comprehensive network troubleshooting capabilities including interface status checks, system-level diagnostics, traffic capture, and detailed reporting.
### Test reports
<img width="1114" height="1006" alt="image" src="https://github.com/user-attachments/assets/13e2cf29-922a-40c8-98bb-d01cfc79cfd9" />

**Key Feature**: All configuration parameters are centralized in `group_vars/all.yml`, making it easy to customize the playbook for your specific environment without modifying the playbook code itself.

## Features

### ✅ Network Interface Check

- Automatically checks interface status (UP/DOWN), MTU, IP address
- Collects error and dropped packet statistics using ethtool
- Validates network interface configuration
- All checks continue even if individual tasks fail

### ✅ System-Level Diagnosis

- Analyzes TCP connection statistics and retransmit counts
- Searches system logs for network-related keywords (configurable)
- Monitors system load and memory usage
- Comprehensive system health assessment

### ✅ Traffic Capture (Optional)

- Automatic tcpdump installation if not present
- Configurable capture duration and packet count
- Generates standard pcap format files for Wireshark analysis
- Automatic retry mechanism for reliable capture

### ✅ Comprehensive Reporting

- Generates structured diagnostic reports with problem identification
- Severity-based issue classification (CRITICAL, POTENTIAL ISSUE, NOTICE)
- Targeted recommendations based on findings
- Includes timestamps, host information, and analysis duration

### ✅ Robust Error Handling

- All checks are non-blocking: individual task failures do not stop execution
- Graceful degradation: continues with other checks if one fails
- Error collection and reporting in role summaries
- Safe default values prevent failures from missing variables

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
   - Network connectivity for package installation (if tcpdump is not installed)

## Project Structure

```
Ansible救火热线系列之(18)网络故障诊断自动化/
├── ansible.cfg                    # Ansible configuration
├── inventory                      # Host inventory file
├── network_diagnosis_site.yml     # Main playbook
├── group_vars/
│   └── all.yml                    # Global variables configuration
├── roles/
│   ├── network_interface/        # Network interface check role
│   │   └── tasks/
│   │       └── main.yml
│   ├── system_diagnosis/         # System diagnosis role
│   │   └── tasks/
│   │       └── main.yml
│   ├── traffic_capture/           # Traffic capture role
│   │   └── tasks/
│   │       └── main.yml
│   └── report_generation/         # Report generation role
│       ├── tasks/
│       │   └── main.yml
│       └── templates/
│           └── network_analysis_report.j2
└── README.md                      # This file
```

## Configuration

### 1. Inventory Setup

Edit the `inventory` file to add your target hosts. You can organize hosts by groups:

```ini
[diagnose]
TEST-RHEL-8.9-1
ansible25.example.com

[rhel7]
Test-RHEL-7.9-1
Test-RHEL-7.9-2
Test-RHEL-7.9-3

[rhel8]
TEST-RHEL-8.9-1

[rhel9]
ansible25.example.com
```

### 2. Network Interface Configuration

Edit `group_vars/all.yml` to specify the network interface to diagnose:

```yaml
network_interface: "ens33"  # Change to your network interface name
```

### 3. Traffic Capture Configuration

Configure traffic capture settings in `group_vars/all.yml`:

```yaml
traffic_capture:
  enabled: true              # Set to false to disable traffic capture
  duration: 30               # Capture duration in seconds
  packet_count: 1000         # Maximum number of packets to capture
  output_dir: "/var/tmp"     # Output directory for capture files
  filename_prefix: "packet_capture"
```

### 4. Report Configuration

Configure report output settings:

```yaml
report_output_dir: "/tmp/network_analysis_reports"
report_filename: "network_analysis_{{ inventory_hostname }}_{{ ansible_date_time.epoch }}.txt"
```

### 5. Diagnosis Thresholds

Adjust diagnosis thresholds based on your environment:

```yaml
diagnosis_thresholds:
  error_packets: 10          # Threshold for error packets
  dropped_packets: 5         # Threshold for dropped packets
  overrun_packets: 3         # Threshold for overrun packets
  tcp_retransmit_rate: 0.1   # TCP retransmit rate threshold
```

## Usage

### Basic Execution

Run the complete diagnosis on all hosts in the `diagnose` group:

```bash
ansible-playbook network_diagnosis_site.yml -i inventory
```

**Example Output:**

```
PLAY [RHEL Network Latency Diagnosis Automation] ******************************

TASK [Check OS compatibility] ************************************************
ok: [Test-RHEL-7.9-1] => changed=false
  msg: 'OS compatibility check passed: RedHat 7.9'

TASK [network_interface : Report network interface check summary] ************
ok: [Test-RHEL-7.9-1] =>
  msg:
  - === Network Interface Check Summary ===
  - 'Interface: ens192'
  - '✅ Interface Status: UP'
  - 'MTU: 1500'
  - 'IP Address: 10.71.19.192'
  - 'Receive Errors: 0'
  - 'Transmit Errors: 0'
  - ✅ All network interface checks completed

PLAY RECAP *********************************************************************
Test-RHEL-7.9-1            : ok=53   changed=1    unreachable=0    failed=0
```

### Execute on Specific Host Group

Run on specific OS groups:

```bash
# RHEL 7 hosts only
ansible-playbook network_diagnosis_site.yml -i inventory --limit rhel7

# RHEL 8 hosts only
ansible-playbook network_diagnosis_site.yml -i inventory --limit rhel8

# RHEL 9 hosts only
ansible-playbook network_diagnosis_site.yml -i inventory --limit rhel9
```

### Execute Specific Roles

Run only specific diagnosis roles using tags:

```bash
# Network interface check only
ansible-playbook network_diagnosis_site.yml -i inventory --tags network_interface

# System diagnosis only
ansible-playbook network_diagnosis_site.yml -i inventory --tags system_diagnosis

# Traffic capture only
ansible-playbook network_diagnosis_site.yml -i inventory --tags traffic_capture

# Report generation only
ansible-playbook network_diagnosis_site.yml -i inventory --tags report_generation
```

### Parallel Execution

For faster execution on multiple hosts:

```bash
ansible-playbook network_diagnosis_site.yml -i inventory --forks 10
```

### Verbose Output

Get detailed output for troubleshooting:

```bash
ansible-playbook network_diagnosis_site.yml -i inventory -v
# or for more verbosity
ansible-playbook network_diagnosis_site.yml -i inventory -vvv
```

### Check Mode (Dry Run)

Test the playbook without making changes:

```bash
ansible-playbook network_diagnosis_site.yml -i inventory --check
```

## Output

### Diagnostic Report

The playbook generates a comprehensive diagnostic report at:

```
/tmp/network_analysis_reports/network_analysis_<hostname>_<timestamp>.txt
```

**Example Report Structure:**

```
========================================
RHEL Network Latency Diagnosis Report
========================================
Analysis Time: 2026-02-05T03:51:31Z
Hostname: Test-RHEL-7.9-1
Network Interface: ens192
Analysis Duration: <duration> seconds

1. Network Interface Status Check
========================================
Interface Name: ens192
Interface Status: UP
MTU Setting: 1500
IP Address: 10.71.19.192

2. Hardware Statistics
========================================
Receive Error Packets: 0
Transmit Error Packets: 0
Receive Dropped Packets: 0
Transmit Dropped Packets: 0

3. System Diagnosis Results
========================================
TCP Retransmit Count: 0
System Load: <load information>
Memory Usage: <memory information>

4. Problem Diagnosis Conclusions
========================================
[CRITICAL] Network interface error packets exceed threshold
[POTENTIAL ISSUE] Network interface dropped packets exceed threshold
[NOTICE] TCP retransmissions detected

5. Recommended Actions
========================================
- Check physical network connection
- Verify cable quality
- Consider updating network card driver

6. Traffic Capture Files
========================================
Capture File: /var/tmp/packet_capture_Test-RHEL-7.9-1_<timestamp>.pcap
Use tools like Wireshark for deep analysis
```

The report includes:

- Network interface status and statistics
- Hardware error and dropped packet counts
- System diagnosis results (TCP stats, load, memory)
- Problem identification with severity levels (CRITICAL, POTENTIAL ISSUE, NOTICE)
- Targeted recommended actions based on findings
- Traffic capture file location (if enabled)

### Traffic Capture Files

If traffic capture is enabled, pcap files are generated at:

```
/var/tmp/packet_capture_<hostname>_<timestamp>.pcap
```

**Note**: The traffic capture task includes automatic retry mechanism (3 retries by default) to ensure reliable capture completion. This is normal behavior and does not indicate an error.

These files can be analyzed using tools like:

- Wireshark
- tcpdump
- tshark
- Other network analysis tools

### Console Output Summary

Each role provides a summary at the end of execution:

- **Network Interface Check Summary**: Interface status, statistics, and any errors
- **System Diagnosis Summary**: TCP stats, system load, memory usage, log findings
- **Traffic Capture Summary**: Capture status, file location, installation status
- **Report Generation Summary**: Report creation status and file location
- **Final Summary**: Overall analysis duration and next steps

## Role Details

### network_interface Role

**Purpose**: Comprehensive network interface health check

**Tasks**:

- Checks network interface status (UP/DOWN) using `ip link show`
- Retrieves MTU configuration
- Parses IP address information using `ip addr show`
- Collects error and dropped packet statistics using `ethtool -S`
- Validates interface configuration

**Output Variables**:

- `interface_up`: Boolean indicating interface status
- `interface_mtu`: MTU value
- `interface_ip`: IP address
- `rx_errors`, `tx_errors`: Error packet counts
- `rx_dropped`, `tx_dropped`: Dropped packet counts

**Error Handling**: All checks use `failed_when: false` to ensure continuation even if individual tasks fail.

### system_diagnosis Role

**Purpose**: System-level network health analysis

**Tasks**:

- Analyzes TCP connection statistics using `ss -s`
- Parses TCP retransmit counts
- Searches system logs for network-related keywords (configurable in `log_keywords`)
- Checks system load using `uptime`
- Monitors memory usage using `free -h`

**Output Variables**:

- `tcp_retransmit`: TCP retransmit count
- `system_load_output`: System load information
- `memory_usage_output`: Memory usage details
- `network_log_entries`: Aggregated log entries

**Error Handling**: All checks continue even if individual tasks fail, with errors collected in `system_diagnosis_errors`.

### traffic_capture Role

**Purpose**: Optional network traffic capture for deep analysis

**Tasks**:

- Checks if tcpdump is available
- Automatically installs tcpdump if not present (using `ansible.builtin.package`)
- Creates capture directory
- Starts traffic capture with configurable duration and packet count
- Waits for capture completion with automatic retry mechanism (3 retries by default)

**Configuration**:

- `traffic_capture.enabled`: Enable/disable traffic capture
- `traffic_capture.duration`: Capture duration in seconds (default: 30)
- `traffic_capture.packet_count`: Maximum packets to capture (default: 1000)
- `traffic_capture.output_dir`: Output directory (default: /var/tmp)

**Note**: The async task with retry mechanism may show "FAILED - RETRYING" messages during normal operation. This is expected behavior and the capture will complete successfully.

**Error Handling**: Continues even if capture fails, with errors collected in `traffic_capture_errors`.

### report_generation Role

**Purpose**: Generate comprehensive diagnostic reports

**Tasks**:

- Creates report output directory
- Generates structured report using Jinja2 template
- Displays report location and preview
- Collects all diagnostic information from previous roles

**Report Features**:

- Problem severity classification (CRITICAL, POTENTIAL ISSUE, NOTICE)
- Threshold-based issue detection
- Targeted recommendations based on findings
- Complete diagnostic information summary

**Error Handling**: Continues even if report generation fails, with errors collected in `report_generation_errors`.

## Error Handling

This playbook is designed with robust error handling to ensure complete diagnosis even when individual checks fail:

### Non-Blocking Design

- **All checks are non-blocking**: Individual task failures do not stop the playbook execution
- Uses `failed_when: false` for all diagnostic commands
- Uses `ignore_errors: yes` for optional operations
- Uses `block-rescue` structure for comprehensive error handling

### Graceful Degradation

- **If a check fails, the playbook continues with other checks**: Each role operates independently
- Missing variables use safe defaults to prevent failures
- Error collection: All errors are collected in role-specific error lists
- Error reporting: All errors are reported in role summaries at the end

### Example Error Handling Flow

```
TASK [network_interface : Check network interface status]
failed_when: false  # Continues even if command fails

TASK [network_interface : Parse interface status information]
when: interface_status.rc == 0  # Only parses if command succeeded

rescue:
  - name: Record interface status check failure
    # Collects error but continues execution
```

### Error Reporting

Each role provides a summary with:

- ✅ Success indicators for completed checks
- ❌ Failure indicators for failed checks
- ⚠️ Warning messages for non-critical issues
- Error lists for detailed troubleshooting

## Troubleshooting

### Common Issues

1. **SSH Connection Failures**

   - **Symptom**: `UNREACHABLE! => {"changed": false, "msg": "Failed to connect to..."}`
   - **Solution**:
     - Verify SSH key authentication is configured: `ssh-copy-id root@target_host`
     - Check network connectivity: `ping target_host`
     - Verify SSH configuration in `inventory` file
     - Ensure `ansible_user` has sudo privileges
2. **Network Interface Not Found**

   - **Symptom**: Interface status check fails or shows "N/A"
   - **Solution**:
     - Verify the interface name in `group_vars/all.yml`
     - List available interfaces on target host: `ip link show`
     - Common interface names: `ens33`, `ens192`, `eth0`, `eth1`
     - Update `network_interface` variable accordingly
3. **tcpdump Installation Failures**

   - **Symptom**: Traffic capture role shows installation failure
   - **Solution**:
     - Ensure target hosts have access to package repositories
     - Check if `yum` (RHEL 7) or `dnf` (RHEL 8/9) is available
     - Verify network connectivity for package downloads
     - Check repository configuration: `yum repolist` or `dnf repolist`
   - **Workaround**: Install tcpdump manually or disable traffic capture
4. **Report Generation Failures**

   - **Symptom**: Report file not created or template errors
   - **Solution**:
     - Check write permissions on report output directory
     - Verify template file exists: `roles/report_generation/templates/network_analysis_report.j2`
     - Ensure sufficient disk space: `df -h /tmp`
     - Check template syntax for Jinja2 errors
5. **Traffic Capture Retry Messages**

   - **Symptom**: `FAILED - RETRYING: Wait for traffic capture to complete`
   - **Note**: This is **normal behavior**. The async task uses retry mechanism to wait for capture completion.
   - The capture will complete successfully after retries (default: 3 retries)
   - If capture consistently fails, check:
     - tcpdump is installed and functional
     - Sufficient disk space in output directory
     - Network interface is accessible
6. **OS Compatibility Errors**

   - **Symptom**: `Unsupported operating system. This playbook is not available for the current OS.`
   - **Solution**: Ensure target hosts are running RHEL 7/8/9 or CentOS 7/8/9
   - Verify OS version: `cat /etc/redhat-release`

### Debug Mode

Run with increased verbosity to see detailed execution:

```bash
# Basic verbose output
ansible-playbook network_diagnosis_site.yml -i inventory -v

# More detailed output
ansible-playbook network_diagnosis_site.yml -i inventory -vv

# Maximum verbosity (shows all task details)
ansible-playbook network_diagnosis_site.yml -i inventory -vvv
```

### Testing Individual Roles

Test specific roles in isolation:

```bash
# Test only network interface check
ansible-playbook network_diagnosis_site.yml -i inventory --tags network_interface -vvv

# Test only system diagnosis
ansible-playbook network_diagnosis_site.yml -i inventory --tags system_diagnosis -vvv
```

### Validating Configuration

Before running the full playbook, validate your configuration:

```bash
# Validate inventory
ansible-inventory -i inventory --list

# Test connectivity
ansible all -i inventory -m ping

# Check variable values
ansible all -i inventory -m debug -a "var=network_interface"
```

## Best Practices

1. **Regular Monitoring**

   - Run this playbook regularly to establish baseline metrics
   - Schedule periodic runs to track network health trends
   - Compare reports over time to identify patterns
2. **Threshold Tuning**

   - Adjust diagnosis thresholds in `group_vars/all.yml` based on your network environment
   - Start with default values and fine-tune based on your infrastructure
   - Consider network size and typical traffic patterns
3. **Traffic Capture Usage**

   - Use traffic capture sparingly as it can impact performance
   - Reduce capture duration and packet count for production systems
   - Consider disabling traffic capture for routine checks
   - Enable only when deep analysis is needed
4. **Report Archiving**

   - Archive reports for historical analysis and trend identification
   - Use timestamps in filenames for easy sorting
   - Consider implementing automated archiving to long-term storage
5. **Multi-Host Execution**

   - Use parallel execution (`--forks`) for faster diagnosis across multiple hosts
   - Balance fork count with system resources
   - Monitor Ansible control node performance during bulk execution
6. **Configuration Management**

   - Keep `group_vars/all.yml` in version control
   - Document any customizations for your environment
   - Use different variable files for different environments (dev, test, prod)
7. **Performance Optimization**

   - Use tags to run only necessary roles for quick checks
   - Disable traffic capture for routine monitoring
   - Adjust `performance.max_log_lines` to limit log search time
8. **Security Considerations**

   - Ensure SSH keys are properly secured
   - Limit sudo privileges for Ansible user
   - Review captured traffic files for sensitive information before sharing

## Test Results

The playbook has been tested and verified on:

- **RHEL 7.9**: Test completed successfully (53 tasks, 1 changed, 0 failed)
- All roles executed successfully
- Report generation working correctly
- Traffic capture functioning with retry mechanism

**Sample Test Execution:**

```
PLAY RECAP *********************************************************************
Test-RHEL-7.9-1            : ok=53   changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
```

**Key Observations:**

- All diagnostic checks completed successfully
- Network interface information collected correctly
- System diagnosis provided comprehensive results
- Traffic capture completed after automatic retries (normal behavior)
- Report generated with all diagnostic information

For detailed test results, refer to `Playbook_test_results.md`.

## Performance Metrics

**Typical Execution Time:**

- Network interface check: ~2-3 seconds
- System diagnosis: ~5-10 seconds (depends on log search)
- Traffic capture: 30+ seconds (configurable duration)
- Report generation: ~1-2 seconds
- **Total execution time**: ~40-50 seconds (without traffic capture: ~10-15 seconds)

**Resource Usage:**

- Minimal CPU impact on target hosts
- Network traffic capture may use additional disk I/O
- Memory usage is minimal (< 50MB)

## Author

GCG AAP SSA Team + v3.01 Date 20260217

## License

📜 License Type: End User License Agreement (EULA)
🔒 Authorization: Through Subscription

## Support

For issues or questions, please refer to the troubleshooting section or contact the GCG AAP SSA Team.

## Changelog

### v3.01 (2026-02-10)

- Initial release
- Support for RHEL 7/8/9 and CentOS 7/8/9
- Four core diagnostic roles
- Comprehensive error handling
- Tested and verified on RHEL 7.9

