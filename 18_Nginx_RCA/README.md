## Nginx Service Fault Automatic Diagnosis (RHEL7/8/9 & CentOS7/8/9)

### 1. Overview

This scenario provides a **non-intrusive, read-only** Nginx service health check for RHEL/CentOS 7/8/9.
The playbook automatically collects key diagnostic information and generates a **structured text report** on each target host.

Main capabilities:

- **OS compatibility assertion**: Only runs on RHEL/CentOS 7/8/9. Unsupported systems are rejected with a clear message.
- **Package & systemd status**: Checks nginx package installation and service active/enabled state.
- **Configuration syntax validation**: Runs `nginx -t` and captures the full output.
- **Network & firewall diagnostics**: Collects listening ports and firewalld status/services/ports.
- **SELinux checks**: Captures SELinux mode and key SELinux booleans related to web access.
- **Directory and file permissions**: Checks nginx configuration, work and website directory permissions.
- **Logs & journal analysis**: Optionally collects tails from error/access logs and recent `journalctl` entries.
- **Final report generation**: Renders a consolidated diagnosis report from a Jinja2 template.

The design follows Red Hat Ansible Automation Platform best practices:

- Uses fully qualified module names (e.g. `ansible.builtin.command`).
- Uses idempotent, read-only checks by default.
- Uses `debug` tasks after each functional section for easier troubleshooting.
- Uses `block`/`rescue` to safely handle optional service start attempts.

### screenshots
<img width="2510" height="1178" alt="image" src="https://github.com/user-attachments/assets/19c3988a-afa5-486a-92d5-7c714f74876e" />
<img width="2510" height="649" alt="image" src="https://github.com/user-attachments/assets/e3288b2c-9810-41b8-a342-409399b8f5af" />


---

### 2. File Layout

All files for this scenario are under this directory:

- `ansible.cfg` – Local Ansible configuration (inventory, SSH options, fact caching, etc.).
- `inventory` – Example inventory file.
- `group_vars/all.yml` – Global variables for this scenario.
- `nginx_diagnosis_site.yml` – Main playbook.
- `templates/nginx_diagnosis_report.j2` – Jinja2 template used to generate the diagnosis report.
- `README.md` – This document.

---

### 3. Inventory Example (Using Your Standard Groups)

This scenario can be used with your standard inventory groups from the development guide:

```ini
[web]
# Add your target RHEL 8/9 or CentOS 8/9 hosts here
# Example:
# web1.example.com
# 10.166.208.232
Test-RHEL-7.9-1

# Using the standard inventory format from development guide:
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
By default it is set to `web`, but you can easily switch it to any group above, for example:

```yaml
target_group: rhel9
```

---

### 4. Variables (group_vars/all.yml)

Key variables you can adjust in `group_vars/all.yml`:

- **Target group**

  - `target_group`: Host group name used by the playbook (must exist in `inventory`).
- **Service and package**

  - `nginx_service`: Service name (default: `nginx`).
  - `nginx_package`: Package name (default: `nginx`).
- **Ports**

  - `http_ports`: List of HTTP ports to check (default: `[80]`).
  - `https_ports`: List of HTTPS ports to check (default: `[443]`).
- **Logs and report**

  - `nginx_error_log`: Error log path (default: `/var/log/nginx/error.log`).
  - `nginx_access_log`: Access log path (default: `/var/log/nginx/access.log`).
  - `nginx_work_dir`: Nginx work directory (default: `/var/lib/nginx`).
  - `nginx_config_dir`: Configuration directory (default: `/etc/nginx`).
  - `nginx_website_dir`: Website root directory (default: `/usr/share/nginx/html`).
  - `collect_journal_lines`: Number of lines to collect from logs/journal (default: `200`).
  - `report_output_path`: Final report path on each host (default: `/root/nginx_diagnosis_report.txt`).
- **Optional service start**

  - `attempt_service_start`: When `true`, the playbook will **attempt to start** the nginx service.
    This is wrapped in a `block/rescue` so any failure is captured but **does not stop** the rest of the diagnostics.
- **SELinux and firewall**

  - `selinux_booleans_to_check`: List of SELinux booleans to inspect.
  - `firewall_services_to_check`: List of firewalld service names to pay attention to (used mainly for reporting).

---

### 5. How to Run

From this directory, you can run the playbook in several ways.

**Basic diagnosis (analysis only, no changes):**

```bash
ansible-playbook -i inventory nginx_diagnosis_site.yml
```

**Attempt to start nginx while diagnosing (for deeper failure analysis):**

```bash
ansible-playbook -i inventory nginx_diagnosis_site.yml -e attempt_service_start=true
```

**Run against a specific OS group from your standard inventory:**

```bash
# Example: diagnose only RHEL 9 hosts
ansible-playbook -i inventory nginx_diagnosis_site.yml -e target_group=rhel9
```

---

### 6. What You Get

After the playbook finishes, each target host will have a text report similar to:

- Path: `/root/nginx_diagnosis_report.txt` (configurable via `report_output_path`)
- Content:
  - OS and SELinux mode
  - Package and systemd status
  - `nginx -t` results
  - Directory and permission checks
  - Port listening and firewalld configuration
  - Selected SELinux booleans
  - Error/access log tails
  - Recent `journalctl` entries for the nginx service
  - A short list of common troubleshooting hints

You can archive these reports centrally or compare them across multiple runs for trend analysis and proactive troubleshooting.

---

### 7. Sample Test Run (RHEL 7.9)

The file `Playbook_test_results.md` in this directory contains a full sample run on `Test-RHEL-7.9-1`.Key observations from this test:

- **OS & variables**

  - The OS assertion passes for `RedHat 7.9`.
  - Baseline variables (ports, service/package names, report path) are printed by the `Debug OS and baseline variables` task.
- **SELinux disabled behavior**

  - On this host, SELinux is **disabled**.
  - The `getsebool` commands return `rc=1` with `stderr: "getsebool:  SELinux is disabled"` for each boolean.
  - Because all these tasks use `failed_when: false`, the play **does not fail**; the raw results are displayed in the SELinux debug output and rendered as `unknown/empty` in the report.
  - This is expected and safe: on systems with SELinux disabled, boolean checks are informational only.
- **Package, service and configuration**

  - `nginx` package is installed (`rpm_query_rc: 0`).
  - Service is `active` and `enabled` (`svc_active_rc: 0`, `svc_enabled_rc: 0`).
  - `nginx -t` returns `rc=0` with:
    - `nginx: the configuration file /etc/nginx/nginx.conf syntax is ok`
    - `nginx: configuration file /etc/nginx/nginx.conf test is successful`
  - Configuration directory, work directory and website directory permissions are:
    - Config directory: `0755`
    - Work directory: `0770`
    - Website directory: `0755`
- **Network & firewall**

  - Expected ports are `[80, 443]` as defined in `group_vars/all.yml`.
  - `ss -lntp` runs successfully (`ss_rc: 0`).
  - On this test host, `firewalld_state` and `firewalld_services/ports` appear as `unknown/empty`, which is normal when firewalld is not active or `firewall-cmd` is not available/enabled.
  - The playbook still completes successfully because all firewall checks are non-fatal.
- **Logs & journal**

  - Error and access log tails are collected successfully (`error_log_collected: true`, `access_log_collected: true`).
  - `journalctl` for the nginx service is also collected (`journal_rc: 0`).
- **Overall result**

  - Play recap: `ok=30  changed=1  failed=0  rescued=0`.
  - The single `changed` comes from the **report generation** task, which writes `/root/nginx_diagnosis_report.txt`.
  - No tasks failed; one task (`Optionally attempt to start nginx service`) was skipped because `attempt_service_start=false`.

You can use `Playbook_test_results.md` as a reference to:

- Understand the expected task flow and debug output on a healthy host.
- Verify that non-critical checks (SELinux booleans, firewalld, logs) do **not** break the play on partially configured systems.
- Cross-check the generated report content against the raw Ansible task output.

