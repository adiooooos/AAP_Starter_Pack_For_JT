# RHEL OS Performance Analysis with PCP

## Overview

This playbook automates RHEL system performance analysis using Performance Co-Pilot (PCP), Red Hat's enterprise-grade monitoring solution. It performs comprehensive performance data collection and generates detailed Markdown reports, enabling standardized, automated performance analysis across your infrastructure.

## Features

- **Enterprise-Grade Monitoring**: Based on Red Hat's official PCP (Performance Co-Pilot) platform
- **Comprehensive Analysis**: 8 core analysis modules covering system overview, load, memory, NUMA, disk I/O, processes, metrics, and historical trends
- **Automated Installation**: Automatically installs and configures PCP on target hosts
- **Standardized Reports**: Generates professional Markdown format reports with expert-level analysis
- **OS Compatibility**: Supports RHEL 7/8/9 and CentOS 7/8/9
- **Bulk Execution**: Optimized for analyzing multiple hosts simultaneously
- **Error Resilience**: Robust error handling ensures analysis continues even if individual checks fail
- **Historical Analysis**: Supports performance trend analysis and capacity planning

## Prerequisites

- Ansible 2.9 or later
- Ansible control node with network access to target hosts
- Target hosts: RHEL 7/8/9 or CentOS 7/8/9
- SSH access to target hosts (password or key-based authentication)
- Sudo/root privileges on target hosts
- Internet access or configured YUM/DNF repository for PCP packages
- Target hosts must have access to Red Hat software repositories (for PCP installation)

## Files

- `os_pcp_analysis_site.yml` - Main performance analysis playbook
- `inventory` - Host inventory file
- `ansible.cfg` - Ansible configuration file
- `README.md` - This file
- `reports/` - Directory where generated reports are saved (created automatically)

## Usage

### 1. Prepare Inventory File

Edit the `inventory` file to define your target hosts. The playbook uses the `pcp_servers` group:

```ini
[pcp_servers]
# Define target hosts for PCP performance analysis here
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

# Group all RHEL hosts as pcp_servers
[pcp_servers:children]
rhel7
rhel8
rhel9
```

### 2. Run the Playbook

```bash
# Dry run first (recommended) - check what would be done
ansible-playbook os_pcp_analysis_site.yml -i inventory --check

# Execute performance analysis
ansible-playbook os_pcp_analysis_site.yml -i inventory

# Run with increased parallelism for bulk execution
ansible-playbook os_pcp_analysis_site.yml -i inventory --forks 10

# Analyze specific host or group
ansible-playbook os_pcp_analysis_site.yml -i inventory --limit rhel9
```

### 3. View Generated Reports

After execution, the performance report will be generated in the `reports/` directory:

```bash
# List generated reports
ls -lh reports/

# View the latest report
cat reports/integrated_pcp_report_YYYY-MM-DD.md

# Or open with a Markdown viewer
less reports/integrated_pcp_report_YYYY-MM-DD.md
```

## What Gets Created

### On Target Hosts

- PCP packages installed (`pcp`, `pcp-system-tools`)
- PCP services started and enabled:
  - `pmcd` - Performance Metrics Collector Daemon
  - `pmlogger` - Performance Metrics Logger (for historical data)

### On Control Node

- `reports/` directory (created automatically)
- Markdown format performance report: `integrated_pcp_report_YYYY-MM-DD.md`

## Report Contents

The generated report includes 8 comprehensive analysis sections for each host:

1. **System Overview (PCP)**: PCP configuration, hardware summary, and running agents
2. **System Load and Uptime**: Current time, uptime, logged-in users, and load averages (1, 5, 15 minutes)
3. **Memory Usage**: Physical memory and swap space details in MB
4. **NUMA Architecture Statistics**: Non-Uniform Memory Access statistics for multi-CPU servers
5. **Disk I/O Statistics**: Read/write rates, queue length, average wait time, device utilization
6. **Top 5 Processes by CPU Usage**: Processes consuming the most CPU resources
7. **Metric Description**: Detailed explanation of PCP metrics (using kernel.all.load as example)
8. **Historical Performance Summary**: Average values from archived performance data

## Customization

### Change Report Output Directory

Edit the `report_output_dir` variable in Play 3:

```yaml
vars:
  report_output_dir: "./custom_reports"
```

### Modify Performance Data Collection

You can customize the PCP commands in Play 2:

- **Extended I/O Statistics**: Change `pcp iostat -x` to `pcp iostat -x 1 5` for continuous 5-second sampling
- **More Processes**: Modify `head -n 8` in pidstat command to show more processes
- **Additional Metrics**: Add more `pmlogsummary` metrics:
  ```yaml
  ansible.builtin.command: pmlogsummary -l kernel.all.cpu.user disk.all.total network.interface.total.bytes
  ```

### Add Custom PCP Commands

Add additional tasks in Play 2 to collect more performance data:

```yaml
- name: "Get network statistics"
  ansible.builtin.command: pcp netstat
  register: pcp_netstat_result
  changed_when: false
  ignore_errors: true
```

## Advanced Usage

### Scheduled Performance Analysis

Set up a cron job for regular performance analysis:

```bash
# Add to crontab - run every day at 9 AM
0 9 * * * cd /path/to/pcp-analysis && ansible-playbook -i inventory os_pcp_analysis_site.yml
```

### Performance Baseline Establishment

Establish a performance baseline when the system is in normal state:

```bash
# Run analysis during normal operation
ansible-playbook os_pcp_analysis_site.yml -i inventory

# Save report as baseline
cp reports/integrated_pcp_report_YYYY-MM-DD.md reports/baseline_performance.md
```

### Performance Problem Diagnosis

When system performance issues occur, quickly generate current state report:

```bash
# Analyze specific problematic server
ansible-playbook os_pcp_analysis_site.yml -i inventory --limit problematic-server

# Compare with baseline to identify anomalies
diff reports/baseline_performance.md reports/integrated_pcp_report_YYYY-MM-DD.md
```

## Troubleshooting

### PCP Installation Fails

- **Check repository access**: Verify target hosts can access Red Hat repositories
  ```bash
  yum repolist
  ```
- **Check package availability**: Ensure PCP packages are available
  ```bash
  yum search pcp
  ```

### PCP Services Fail to Start

- **Check service status**: `systemctl status pmcd pmlogger`
- **View service logs**: `journalctl -u pmcd -u pmlogger`
- **Verify PCP installation**: `which pmcd`

### Performance Data Collection Fails

- **Check PCP daemon**: Ensure `pmcd` is running
  ```bash
  systemctl status pmcd
  ```
- **Test PCP commands manually**: Run `pcp uptime` on target host
- **Check permissions**: Ensure execution user has sufficient privileges
- **Review playbook output**: Check debug messages for specific failures

### Report Generation Issues

- **Check reports directory**: Ensure `reports/` directory exists and is writable
- **Verify hostvars**: Check if performance data was collected successfully
- **Review template**: Check Jinja2 template syntax in Play 3

### No Historical Data Available

Historical summary requires `pmlogger` to have been running for some time. If you just installed PCP, historical data may not be available yet. This is expected and will populate over time.

## Performance Analysis Best Practices

1. **Establish Baselines**: Run analysis during normal operation to establish performance baselines
2. **Regular Monitoring**: Schedule regular performance analysis to track trends
3. **Compare Reports**: Compare current reports with baselines to identify anomalies
4. **Multi-Host Analysis**: Use bulk execution to analyze multiple hosts simultaneously
5. **Historical Trends**: Leverage historical data for capacity planning and problem prevention

## Author

GCG AAP SSA Team + v3.01 20260217

## License

📜 License Type: End User License Agreement (EULA)
🔒 Authorization: Subscription-based License

