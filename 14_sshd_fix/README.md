## Scenario 16 – SSH Connection Troubleshooting & Auto‑Remediation

This scenario is part of the AAP Starter Pack and demonstrates how to automatically diagnose and remediate common SSH connectivity issues on RHEL/CentOS 7/8/9 using Ansible Automation Platform best practices.  
The playbook focuses on safety, observability, and repeatability: strong OS and input validation, idempotent tasks, detailed reports, and clear client‑side guidance.

### 1. Use Case Overview

- **Goal**: Detect and remediate typical SSH problems such as DNS resolution failures, SSH service not running, missing port listeners, and host key mismatch warnings.
- **Target systems**: RHEL or CentOS **7/8/9** acting as SSH servers.
- **Typical scenario**: Operations teams frequently see `REMOTE HOST IDENTIFICATION HAS CHANGED`, intermittent SSH failures, or DNS inconsistencies between clients and servers.

### 2. Inventory Example

You can reuse your existing inventory and simply define an `ssh_fix_targets` group that points to the hosts where you want to run diagnostics and remediation:

```ini
[rhel7]
Test-RHEL-7.9-1
Test-RHEL-7.9-2
Test-RHEL-7.9-3

[rhel8]
TEST-RHEL-8.9-1

[rhel9]
ansible25.example.com

[ssh_fix_targets]
ansible25.example.com
```

The provided `inventory` file in this folder already includes an example group definition aligned with the AAP Starter Pack reference hosts.

### 3. Playbook Location and Structure

- **Path**: `02_AAP_Starter_Pack/02_Playbooks/Ansible救火热线系列之(16)SSH连接故障自动修复/ssh_connection_auto_fix_site.yml`
- **Host group**: `ssh_fix_targets`
- **Main steps**:
  1. Assert OS compatibility (RHEL/CentOS 7/8/9 only) and validate core input variables.
  2. Collect basic system facts (hostname, IP, network interfaces).
  3. Create a time‑stamped report directory under `/tmp`.
  4. Run DNS diagnostics before and after remediation and optionally add a safe `hosts` entry.
  5. Verify that the SSH service is running and enabled, and confirm that the expected port is listening.
  6. Collect SSH host key fingerprints (SHA256 and MD5) for client verification.
  7. Inspect network connectivity and firewall configuration (including `firewalld` ports when available).
  8. Generate detailed text reports (DNS, SSH status, network connectivity) into the report directory.
  9. Generate a client‑side remediation guide (for Linux and Windows users).
  10. Deploy a simple, optional SSH network monitoring script.
  11. Create a remediation summary file and print a concise summary via `debug`.

Each functional step is followed by at least one `ansible.builtin.debug` task to make troubleshooting and auditing easier in both CLI and AAP UI.

### 4. Variables

Global variables for this scenario are defined in `group_vars/all.yml`:

```yaml
target_hostname: "ansible25.example.com"
target_short_name: "ansible25"
hosts_file_path: "/etc/hosts"
ssh_host_keys_path: "/etc/ssh"
report_base_dir: "/tmp"
report_prefix: "ssh_network_fix"
monitor_interval_seconds: 300
monitor_script_name: "monitor_ssh_network.sh"
ssh_service_name: "sshd"
ssh_port: 22
supported_os_families: ["RedHat", "CentOS"]
supported_os_versions: ["7", "8", "9"]
```

- **`target_hostname`**: FQDN used for DNS checks and client‑side remediation.
- **`target_short_name`**: Short hostname to be added as an alias in `/etc/hosts`.
- **`hosts_file_path`**: Path to the server‑side hosts file. Typically `/etc/hosts`.
- **`ssh_host_keys_path`**: Directory containing SSH host public keys (usually `/etc/ssh`).
- **`report_base_dir`** and **`report_prefix`**: Control where reports are stored, e.g. `/tmp/ssh_network_fix_YYYYMMDD_HHMMSS`.
- **`monitor_interval_seconds`** and **`monitor_script_name`**: Control the behavior of the optional monitoring script.
- **`ssh_service_name`** and **`ssh_port`**: Define which SSH service and TCP port to validate.
- **`supported_os_families`** and **`supported_os_versions`**: Limit the playbook to supported RHEL/CentOS versions.

The playbook uses `ansible.builtin.assert` to validate OS compatibility and critical variables before making changes.

### 5. How to Run

From your Ansible control node, run:

```bash
ansible-playbook -i inventory ssh_connection_auto_fix_site.yml
```

Or, if you are using Ansible Automation Platform:

1. Upload this project to your AAP Project (e.g. via Git).
2. Create an Inventory that includes your SSH target hosts in the `ssh_fix_targets` group.
3. Create a Job Template that references:
   - **Playbook**: `ssh_connection_auto_fix_site.yml`
   - **Inventory**: your inventory containing `ssh_fix_targets`
4. Launch the job and review the output and generated reports.

### 6. What You Should See

On a successful run, you should observe:

- A new report directory under `/tmp` with a time‑stamped name starting with `ssh_network_fix_`.
- DNS diagnostics showing the before/after status of name resolution for `target_hostname`.
- Confirmation that the `sshd` service is running and enabled, and that the configured TCP port is listening.
- SSH host key fingerprints collected in both SHA256 and MD5 formats.
- Network and firewall information recorded in the generated reports.
- A `client_fix_instructions.txt` file with clear steps for Linux and Windows users to clean SSH caches and verify host keys.
- A `ssh_network_monitor.log` file (once you start the monitoring script in the background) tracking ongoing health checks.

If a change to the hosts file fails, the playbook uses a `block`/`rescue` structure to log a warning and point you to the backup created by `ansible.builtin.lineinfile`, helping you perform a safe manual rollback if necessary.


