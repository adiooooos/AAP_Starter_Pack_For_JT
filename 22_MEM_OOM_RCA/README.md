## Out of Memory (OOM) Automatic Diagnosis (RHEL7/8/9 & CentOS7/8/9)

### 1. Overview

This scenario provides a **non-intrusive, read-only** Out of Memory (OOM) diagnosis for RHEL/CentOS 7/8/9 servers.
The playbook automatically collects comprehensive OOM-related diagnostic information and generates a **structured text report** on each target host.

Main capabilities:

- **OS compatibility assertion**: Only runs on RHEL/CentOS 7/8/9. Unsupported systems are rejected with a clear message.
- **OOM log analysis**: Collects OOM killer logs from `/var/log/messages` and `journalctl` to identify when and which processes were killed.
- **Killed process analysis**: Analyzes memory usage details of processes killed by OOM killer.
- **Historical memory analysis**: Gathers historical memory, swap, and CPU usage trends via SAR (System Activity Reporter).
- **Real-time memory status**: Captures current memory status via `vmstat`, `/proc/meminfo`, and `free`.
- **Hardware information**: Collects memory hardware details via `dmidecode`.
- **Final report generation**: Renders a consolidated diagnosis report from a Jinja2 template on each host.

The design follows Red Hat Ansible Automation Platform best practices:

- Uses fully qualified module names (e.g. `ansible.builtin.shell`).
- Uses idempotent, read-only checks by default.
- Uses `debug` tasks after each functional section for easier troubleshooting.
- Keeps checks **non-fatal** wherever possible so the playbook continues gathering data even if some steps fail (e.g., missing `sysstat` package for SAR, missing logs).

---

### 2. File Layout

All files for this scenario are under this directory:

- `ansible.cfg` – Local Ansible configuration (inventory, SSH options, fact caching, etc.).
- `inventory` – Example inventory file with OOM server groups and your standard OS groups.
- `group_vars/all.yml` – Global variables for this scenario (report paths, target group, etc.).
- `troubleshooting03_oom.yml` – Main playbook.
- `templates/oom_diagnosis_report.j2` – Jinja2 template used to generate the diagnosis report.
- `README.md` – This document.

---

### 3. Inventory Example (Using Your Standard Groups)

This scenario uses a dedicated group for OOM diagnostics and can also leverage your standard OS groups:

```ini
[oom_servers]
# Add your RHEL/CentOS 7/8/9 servers here
# web-server-01 ansible_host=192.168.1.100
# db-server-01 ansible_host=192.168.1.101
# app-server-01 ansible_host=192.168.1.102

# Standard groups from the development guide:
[rhel7]
Test-RHEL-7.9-1
Test-RHEL-7.9-2
Test-RHEL-7.9-3

[rhel8]
TEST-RHEL-8.9-1

[rhel9]
ansible25.example.com
```

For the playbook, the **target group** is controlled by the `target_group` variable in `group_vars/all.yml`.
By default it is set to:

```yaml
target_group: oom_servers
```

You can override it at runtime to point to any group that contains servers for OOM diagnosis, for example:

```bash
# Diagnose OOM on oom_servers group
ansible-playbook -i inventory troubleshooting03_oom.yml -e target_group=oom_servers

# Diagnose OOM on a specific OS group
ansible-playbook -i inventory troubleshooting03_oom.yml -e target_group=rhel9
```

---

### 4. Variables (group_vars/all.yml)

Key variables you can adjust in `group_vars/all.yml`:

- **Target group**

  - `target_group`: Host group name used by the playbook (must exist in `inventory`).

- **Report paths**

  - `report_dir`: Directory on each target host where reports are stored (default: `/var/tmp/oom_diagnosis`).
  - `report_file`: Filename for reports on each host (default: `oom_report.txt`).

---

### 5. How to Run

From this directory, you can run the playbook in several ways.

**Basic OOM diagnosis (analysis only, no changes):**

```bash
ansible-playbook -i inventory troubleshooting03_oom.yml
```

**Explicitly target OOM servers:**

```bash
ansible-playbook -i inventory troubleshooting03_oom.yml -e target_group=oom_servers
```

**Run against a specific OS group from your standard inventory:**

```bash
# Example: diagnose OOM on RHEL 9 hosts
ansible-playbook -i inventory troubleshooting03_oom.yml -e target_group=rhel9
```

**Parallel execution for bulk diagnosis (improve efficiency):**

```bash
# Run with 10 parallel forks
ansible-playbook -i inventory troubleshooting03_oom.yml --forks 10
```

**Limit execution to specific hosts:**

```bash
# Diagnose only specific hosts
ansible-playbook -i inventory troubleshooting03_oom.yml --limit web-server-01,db-server-01
```

---

### 6. What You Get

After the playbook finishes, each target host will have a text report similar to:

- Path: `/var/tmp/oom_diagnosis/oom_report.txt` (configurable via `report_dir` and `report_file`)
- Content includes:
  - **OOM Killer Logs**: When and which processes were killed due to memory shortage
  - **Killed Process Memory Usage**: Detailed memory consumption of killed processes
  - **SAR Memory Usage**: Historical memory usage trends and %commit metric (critical for OOM prediction)
  - **SAR Swap Usage**: Historical swap usage patterns
  - **SAR CPU Usage**: Historical CPU usage (to correlate with memory pressure)
  - **vmstat Output**: Real-time memory, swap, and I/O statistics
  - **Total Memory**: System total memory from `/proc/meminfo`
  - **Free Memory**: Current memory usage from `free -m`
  - **Memory Hardware Info**: Physical memory hardware details from `dmidecode`
  - **Diagnostic Recommendations**: Analysis points, common issues, solutions, and prevention strategies

Each report section includes:
- **Description**: What the section shows
- **Key Parameters Explanation**: Detailed explanation of important metrics
- **Raw output**: Actual command output for analysis

---

### 7. Diagnostic Coverage

#### ✅ OOM Log Analysis

- **OOM Killer Logs**: Collects system OOM killer triggered logs from `/var/log/messages` and `journalctl`
- **Killed Process Memory Usage**: Analyzes memory usage details of processes killed by OOM killer
- **Timestamp Analysis**: Identifies when OOM events occurred

#### ✅ Historical Memory Usage Analysis

- **SAR Memory Usage**: Analyzes historical memory usage trends and %commit metric
  - **%commit is critical**: If it exceeds 100%, the system is at risk of OOM
- **SAR Swap Usage**: Analyzes swap usage patterns and trends
- **SAR CPU Usage**: Correlates CPU usage with memory pressure events

#### ✅ Real-time Memory Status

- **vmstat Output**: Real-time memory, swap, and I/O status
- **Total Memory**: System total memory from `/proc/meminfo`
- **Free Memory**: Current memory usage from `free -m`

#### ✅ Memory Hardware Information

- **Hardware Details**: Physical memory hardware information via `dmidecode`
- **Memory Configuration**: Memory module configuration and capacity information

#### ✅ Intelligent Report Generation

- **Structured Report**: Generates comprehensive diagnosis report with all key information
- **Timestamp Recording**: Records diagnosis execution time
- **Host Information**: Includes hostname and system information
- **Diagnostic Recommendations**: Provides analysis points, common issues, solutions, and prevention strategies

---

### 8. Prerequisites

1. **Ansible control node** with Ansible installed
2. **SSH access** to target servers (SSH key-based authentication recommended)
3. **Sudo privileges** for the execution user on target servers
4. **Optional packages** on target servers (playbook will continue even if missing):
   - `sysstat` package (for `sar` command to collect historical data)
   - `dmidecode` package (for memory hardware information)

The playbook is designed to be resilient: if optional commands are missing, it will continue with other diagnostic checks and note the missing information in the report.

---

### 9. Notes and Best Practices

- This playbook is designed to be **safe for production**: it runs in analysis-only mode and does not change system configuration, except for writing report files.
- All checks are **non-fatal** wherever possible, so a failure in one area (e.g., missing `sysstat`, missing logs, or `dmidecode` not available) will not stop the rest of the diagnostics.
- The playbook collects comprehensive OOM information from multiple sources:
  - System logs (`/var/log/messages` and `journalctl`)
  - Historical performance data (SAR)
  - Real-time system status (`vmstat`, `free`, `/proc/meminfo`)
  - Hardware information (`dmidecode`)
- Reports include detailed parameter explanations, making them accessible to both junior and senior operations staff.
- The **%commit metric** from SAR is particularly important: it shows committed memory relative to total memory + swap. If this exceeds 100%, the system is at high risk of OOM.
- Combine the generated reports with your ticketing or monitoring systems to build a repeatable OOM troubleshooting workflow.

---

### 10. Troubleshooting

**Issue: SAR data shows "N/A" in the report**

- **Solution**: Install the `sysstat` package and ensure `sadc` (System Activity Data Collector) is running. SAR data is collected by `sadc` and stored in `/var/log/sa/`. The playbook will continue even if SAR data is not available.

**Issue: OOM logs show "N/A"**

- **Solution**: OOM events may not have occurred recently, or logs may have been rotated. Check `/var/log/messages` and `journalctl -k` manually. The playbook will continue with other diagnostic checks.

**Issue: dmidecode returns "N/A"**

- **Solution**: Ensure the playbook runs with root privileges (`become: true` is set by default). `dmidecode` requires root access to read hardware information. Also ensure `dmidecode` package is installed.

**Issue: Playbook fails with "Unsupported operating system"**

- **Solution**: This playbook only supports RHEL/CentOS 7/8/9. Ensure your target hosts meet this requirement.

---

### 11. Example Report Analysis

When analyzing the generated reports, focus on:

1. **%commit metric**: The most critical metric for OOM prediction. If it exceeds 100%, the system is at high risk of OOM.
2. **OOM killer logs**: Identify which processes were killed and when, to understand the pattern of memory pressure.
3. **Killed process memory usage**: Check `total-vm` and `anon-rss` to understand how much memory processes were consuming.
4. **Swap usage**: High swap usage indicates physical memory shortage and can cause performance degradation.
5. **Historical trends**: SAR data shows memory usage patterns over time, helping identify memory leaks or gradual memory pressure increases.
6. **Real-time status**: `vmstat` and `free` show current memory status, which can be compared with historical data.

---

### 12. OOM Prevention Strategies

Based on the diagnostic report, consider these prevention strategies:

1. **Monitor %commit regularly**: Set alerts when %commit exceeds 80% to get early warning of potential OOM events.
2. **Implement memory limits**: Use cgroups or systemd limits to prevent applications from consuming excessive memory.
3. **Memory monitoring**: Use memory monitoring tools to track memory usage trends and identify memory leaks early.
4. **Application optimization**: Review and optimize application memory allocation (e.g., JVM heap sizes, application memory limits).
5. **Adequate swap space**: Ensure adequate swap space, but prefer increasing physical memory over relying on swap.
6. **Memory overcommit settings**: Review `/proc/sys/vm/overcommit_memory` and `/proc/sys/vm/oom_kill_allocating_task` based on workload characteristics.

---

### 13. Integration with Monitoring Systems

The generated reports can be integrated with:

- **Monitoring systems**: Parse reports to extract key metrics (especially %commit) and feed into monitoring dashboards
- **Ticketing systems**: Attach reports to incident tickets for faster OOM incident resolution
- **Automation workflows**: Use reports as input for automated remediation actions (e.g., restart services, adjust memory limits)
- **Compliance reporting**: Use reports for memory usage compliance checks and capacity planning

---

### 14. Important Notes about OOM

- **OOM events are critical**: They often lead to system crashes and service interruptions. Early detection and prevention are crucial.
- **%commit is the key metric**: Monitor %commit from SAR data regularly. If it consistently exceeds 100%, the system will experience OOM events.
- **Memory leaks**: OOM events may be caused by memory leaks. Use historical SAR data to identify processes with continuously growing memory usage.
- **Performance impact**: High swap usage (swap thrashing) causes severe performance degradation. Prefer increasing physical memory over relying on swap.

---

For questions or issues, please contact the GCG AAP SSA Team.

