## High Memory Utilization Automatic Diagnosis (RHEL7/8/9 & CentOS7/8/9)

### 1. Overview

This scenario provides a **non-intrusive, read-only** memory utilization diagnosis for RHEL/CentOS 7/8/9 servers.
The playbook automatically collects comprehensive memory-related diagnostic information and generates a **structured text report** on each target host, as well as a **centralized report** on the control node.

Main capabilities:

- **OS compatibility assertion**: Only runs on RHEL/CentOS 7/8/9. Unsupported systems are rejected with a clear message.
- **Memory overview**: Collects memory usage statistics via `free`, `/proc/meminfo`, and `vmstat`.
- **Process analysis**: Identifies memory-consuming processes using `top`, `ps aux`, and `ps auxH`.
- **System performance**: Gathers system-wide performance metrics via `sar`, `iostat`, and `lsof`.
- **Hardware information**: Captures memory hardware details via `dmidecode` and filesystem usage via `df`.
- **Dual report generation**: Generates individual reports on each host and a centralized report on the control node.

The design follows Red Hat Ansible Automation Platform best practices:

- Uses fully qualified module names (e.g. `ansible.builtin.shell`).
- Uses idempotent, read-only checks by default.
- Uses `debug` tasks after each functional section for easier troubleshooting.
- Keeps checks **non-fatal** wherever possible so the playbook continues gathering data even if some steps fail (e.g., missing `sysstat` package for `sar`, missing `lsof` command).

### tested reports
<img width="2510" height="1333" alt="image" src="https://github.com/user-attachments/assets/68af24d3-3da0-4e9c-977d-a797a8cbb886" />
...
<img width="2510" height="1333" alt="image" src="https://github.com/user-attachments/assets/851911b0-9b91-4b48-9e8e-09e02ab44673" />


---

### 2. File Layout

All files for this scenario are under this directory:

- `ansible.cfg` – Local Ansible configuration (inventory, SSH options, fact caching, etc.).
- `inventory` – Example inventory file with memory server groups and your standard OS groups.
- `group_vars/all.yml` – Global variables for this scenario (report paths, target group, etc.).
- `troubleshooting04_HignMemUsage.yml` – Main playbook.
- `templates/memory_diagnosis_report.j2` – Jinja2 template used to generate the diagnosis report.
- `README.md` – This document.

---

### 3. Inventory Example (Using Your Standard Groups)

This scenario uses a dedicated group for memory diagnostics and can also leverage your standard OS groups:

```ini
[memory_servers]
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
target_group: memory_servers
```

You can override it at runtime to point to any group that contains servers for memory diagnosis, for example:

```bash
# Diagnose memory on memory_servers group
ansible-playbook -i inventory troubleshooting04_HignMemUsage.yml -e target_group=memory_servers

# Diagnose memory on a specific OS group
ansible-playbook -i inventory troubleshooting04_HignMemUsage.yml -e target_group=rhel9
```

---

### 4. Variables (group_vars/all.yml)

Key variables you can adjust in `group_vars/all.yml`:

- **Target group**

  - `target_group`: Host group name used by the playbook (must exist in `inventory`).

- **Report paths**

  - `remote_report_dir`: Directory on each target host where individual reports are stored (default: `/var/tmp/memory_diagnosis`).
  - `remote_report_file`: Filename for individual reports on each host (default: `memory_report.txt`).
  - `centralized_report_dir`: Directory on control node where centralized report is stored (default: `/var/tmp/memory_diagnosis_centralized`).
  - `centralized_report_file`: Filename for the centralized report (default: `centralized_memory_report.txt`).

---

### 5. How to Run

From this directory, you can run the playbook in several ways.

**Basic memory diagnosis (analysis only, no changes):**

```bash
ansible-playbook -i inventory troubleshooting04_HignMemUsage.yml
```

**Explicitly target memory servers:**

```bash
ansible-playbook -i inventory troubleshooting04_HignMemUsage.yml -e target_group=memory_servers
```

**Run against a specific OS group from your standard inventory:**

```bash
# Example: diagnose memory on RHEL 9 hosts
ansible-playbook -i inventory troubleshooting04_HignMemUsage.yml -e target_group=rhel9
```

**Parallel execution for bulk diagnosis (improve efficiency):**

```bash
# Run with 10 parallel forks
ansible-playbook -i inventory troubleshooting04_HignMemUsage.yml --forks 10
```

**Limit execution to specific hosts:**

```bash
# Diagnose only specific hosts
ansible-playbook -i inventory troubleshooting04_HignMemUsage.yml --limit web-server-01,db-server-01
```

---

### 6. What You Get

After the playbook finishes, you will get:

**Individual reports on each target host:**

- Path: `/var/tmp/memory_diagnosis/memory_report.txt` (configurable via `remote_report_dir` and `remote_report_file`)
- Content includes:
  - Memory usage overview (`free -t -m`)
  - Detailed memory information (`/proc/meminfo`)
  - Virtual memory statistics (`vmstat -s`)
  - Process resource usage (`top`)
  - Disk I/O statistics (`iostat -x`)
  - Process memory usage details (`ps aux`)
  - Process hierarchy memory usage (`ps auxH`)
  - System performance statistics (`sar -A`)
  - Open files list (`lsof`)
  - Filesystem usage (`df -hT`)
  - Hardware memory information (`dmidecode`)
  - Diagnostic recommendations and common solutions

**Centralized report on control node:**

- Path: `/var/tmp/memory_diagnosis_centralized/centralized_memory_report.txt` (configurable via `centralized_report_dir` and `centralized_report_file`)
- Content: Aggregated reports from all target hosts, making it easy to compare memory usage across multiple servers

Each report section includes:
- **Description**: What the section shows
- **Key Parameters Explanation**: Detailed explanation of important metrics
- **Raw output**: Actual command output for analysis

---

### 7. Diagnostic Coverage

#### ✅ Memory Status Checks

- `free -t -m`: Memory usage overview
- `/proc/meminfo`: Detailed memory information
- `vmstat -s`: Virtual memory statistics

#### ✅ Process Analysis

- `top -b -n 1`: Real-time process status
- `ps aux`: Process memory usage
- `ps auxH`: Hierarchical process view

#### ✅ System Performance Analysis

- `sar -A`: System activity report (requires `sysstat` package)
- `iostat -x`: Disk I/O statistics (requires `sysstat` package)
- `lsof`: Open files statistics

#### ✅ Hardware Information

- `dmidecode -t memory`: Memory hardware information
- `df -hT`: Filesystem usage

---

### 8. Prerequisites

1. **Ansible control node** with Ansible installed
2. **SSH access** to target servers (SSH key-based authentication recommended)
3. **Sudo privileges** for the execution user on target servers
4. **Optional packages** on target servers (playbook will continue even if missing):
   - `sysstat` package (for `sar` and `iostat` commands)
   - `lsof` package (for `lsof` command)

The playbook is designed to be resilient: if optional commands are missing, it will continue with other diagnostic checks and note the missing information in the report.

---

### 9. Notes and Best Practices

- This playbook is designed to be **safe for production**: it runs in analysis-only mode and does not change system configuration, except for writing report files.
- All checks are **non-fatal** wherever possible, so a failure in one area (e.g., missing `sysstat`, `lsof`, or `dmidecode`) will not stop the rest of the diagnostics.
- The playbook collects comprehensive memory information from multiple angles, providing a 360-degree view of memory utilization.
- Reports include detailed parameter explanations, making them accessible to both junior and senior operations staff.
- The centralized report allows you to compare memory usage patterns across multiple servers for trend analysis and proactive troubleshooting.
- Combine the generated reports with your ticketing or monitoring systems to build a repeatable memory troubleshooting workflow.

---

### 10. Troubleshooting

**Issue: Some commands return "N/A" in the report**

- **Solution**: Install missing packages. For `sar` and `iostat`, install `sysstat`. For `lsof`, install the `lsof` package. The playbook will continue even if these are missing.

**Issue: dmidecode returns "N/A"**

- **Solution**: Ensure the playbook runs with root privileges (`become: true` is set by default). `dmidecode` requires root access to read hardware information.

**Issue: Centralized report is empty or missing**

- **Solution**: Check that the `fetch` module has permission to read files from target hosts and write to the centralized directory on the control node.

**Issue: Playbook fails with "Unsupported operating system"**

- **Solution**: This playbook only supports RHEL/CentOS 7/8/9. Ensure your target hosts meet this requirement.

---

### 11. Example Report Analysis

When analyzing the generated reports, focus on:

1. **MemAvailable**: The most important metric for available memory. If close to 0, the system is under memory pressure.
2. **Swap usage**: High swap usage indicates physical memory shortage.
3. **Top memory consumers**: Check the `%MEM` column in `top` and `ps aux` output to identify processes consuming the most memory.
4. **Memory leaks**: Compare process memory usage over time to identify potential memory leaks.
5. **Disk I/O**: High disk I/O combined with high swap usage indicates frequent swapping, which degrades performance.

---

### 12. Integration with Monitoring Systems

The generated reports can be integrated with:

- **Monitoring systems**: Parse reports to extract key metrics and feed into monitoring dashboards
- **Ticketing systems**: Attach reports to incident tickets for faster resolution
- **Automation workflows**: Use reports as input for automated remediation actions
- **Compliance reporting**: Use reports for memory usage compliance checks

---

For questions or issues, please contact the GCG AAP SSA Team.


