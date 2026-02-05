## FTP Service Fault Automatic Diagnosis (RHEL7/8/9 & CentOS7/8/9)

### 1. Overview

This scenario provides a **non-intrusive, read-only** FTP (vsftpd) service health check for RHEL/CentOS 7/8/9.
The playbook automatically collects key diagnostic information from both **FTP servers** and **FTP clients**, and generates a **structured text report** on each target host.

Main capabilities:

- **OS compatibility assertion**: Only runs on RHEL/CentOS 7/8/9. Unsupported systems are rejected with a clear message.
- **Package & systemd status** (server side): Checks vsftpd package installation and service active/enabled state.
- **Port & firewall diagnostics** (server side): Captures listening sockets for FTP ports and summarizes firewalld/iptables configuration.
- **Configuration checks** (server side): Verifies the existence of `/etc/vsftpd/vsftpd.conf` and inspects the `anonymous_enable` setting.
- **Client connectivity tests** (client side): From FTP clients, runs ICMP ping and TCP connect tests to each FTP server.
- **Logs & journal analysis**: Collects recent `journalctl` entries for the FTP service.
- **Final report generation**: Renders a consolidated diagnosis report from a Jinja2 template on each host.

The design follows Red Hat Ansible Automation Platform best practices:

- Uses fully qualified module names (e.g. `ansible.builtin.command`).
- Uses idempotent, read-only checks by default.
- Uses `debug` tasks after each functional section for easier troubleshooting.
- Uses `block`/`rescue` to safely handle optional service start attempts.
- Keeps checks **non-fatal** wherever possible so the playbook continues gathering data even if some steps fail.

---

### 2. File Layout

All files for this scenario are under this directory:

- `ansible.cfg` – Local Ansible configuration (inventory, SSH options, fact caching, etc.).
- `inventory` – Example inventory file with FTP server/client groups and your standard OS groups.
- `group_vars/all.yml` – Global variables for this scenario (service/ports/report path, etc.).
- `troubleshooting02_ftp.yml` – Main playbook.
- `templates/ftp_diagnosis_report.j2` – Jinja2 template used to generate the diagnosis report.
- `README.md` – This document.

---

### 3. Inventory Example (Using Your Standard Groups)

This scenario uses two dedicated groups for FTP diagnostics and can also leverage your standard OS groups:

```ini
[ftp_servers]
# Add your FTP servers (RHEL/CentOS 7/8/9) here
# ftp-server1.example.com
# 10.66.208.232

[ftp_clients]
# Add your FTP client hosts (RHEL/CentOS 7/8/9) here
# ftp-client1.example.com

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
target_group: ftp_servers
```

You can override it at runtime to point to any group that contains FTP-related hosts, for example:

```bash
# Diagnose only FTP servers
ansible-playbook -i inventory troubleshooting02_ftp.yml -e target_group=ftp_servers

# Diagnose only FTP clients (connectivity tests only)
ansible-playbook -i inventory troubleshooting02_ftp.yml -e target_group=ftp_clients
```

---

### 4. Variables (group_vars/all.yml)

Key variables you can adjust in `group_vars/all.yml`:

- **Target group**

  - `target_group`: Host group name used by the playbook (must exist in `inventory`).

- **Service and package**

  - `ftp_service`: FTP service name (default: `vsftpd`).
  - `ftp_package`: FTP package name (default: `vsftpd`).

- **Ports**

  - `ftp_ports`: List of FTP ports to check (default: `[21]`).

- **Report path**

  - `report_output_path`: Final report path on each host (default: `/root/ftp_diagnosis_report.txt`).

- **Client connectivity**

  - `ftp_ping_count`: Number of ICMP ping packets sent from each client to each FTP server (default: `2`).
  - `ftp_test_timeout`: Timeout (in seconds) for the TCP connectivity test using `/dev/tcp` (default: `5`).

- **Logs and journal**

  - `collect_journal_lines`: Number of lines to collect from `journalctl` for the FTP service (default: `200`).

- **Optional service start**

  - `attempt_service_start`: When `true`, the playbook will **attempt to start** the FTP service on servers.
    This is wrapped in a `block/rescue` so any failure is captured but **does not stop** the rest of the diagnostics.

---

### 5. How to Run

From this directory, you can run the playbook in several ways.

**Basic diagnosis on FTP servers (analysis only, no changes):**

```bash
ansible-playbook -i inventory troubleshooting02_ftp.yml
```

**Explicitly target FTP servers:**

```bash
ansible-playbook -i inventory troubleshooting02_ftp.yml -e target_group=ftp_servers
```

**Run only client‑side connectivity tests:**

```bash
ansible-playbook -i inventory troubleshooting02_ftp.yml -e target_group=ftp_clients
```

**Attempt to start the FTP service on servers while diagnosing (for deeper failure analysis):**

```bash
ansible-playbook -i inventory troubleshooting02_ftp.yml -e attempt_service_start=true
```

**Run against a specific OS group from your standard inventory (after adjusting `ftp_servers`/`ftp_clients` accordingly):**

```bash
# Example: diagnose only RHEL 9 hosts that act as FTP servers or clients
ansible-playbook -i inventory troubleshooting02_ftp.yml -e target_group=rhel9
```

---

### 6. What You Get

After the playbook finishes, each target host will have a text report similar to:

- Path: `/root/ftp_diagnosis_report.txt` (configurable via `report_output_path`)
- Content:
  - OS and architecture information
  - FTP package and systemd service status (servers)
  - Listening sockets and basic firewall information (servers)
  - vsftpd configuration existence and `anonymous_enable` setting (servers)
  - ICMP ping and TCP connectivity results from clients to each FTP server (clients)
  - Recent `journalctl` entries for the FTP service
  - A short diagnostic hint section that summarizes the most likely issue (package missing, service down, no listening port, or network problem)

You can archive these reports centrally or compare them across multiple runs for trend analysis and proactive troubleshooting.

---

### 7. Notes and Best Practices

- This playbook is designed to be **safe for production**: by default it runs in analysis-only mode and does not change system configuration, except for writing the report file.
- All checks are **non-fatal** wherever possible, so a failure in one area (e.g. missing `ss`, `journalctl` or `firewall-cmd`) will not stop the rest of the diagnostics.
- For a full end‑to‑end view of an FTP incident, you can:
  - Run the playbook once against `ftp_servers` to validate server‑side configuration and firewall.
  - Run it again against `ftp_clients` to validate network reachability and TCP connectivity from client side.
- Combine the generated reports with your ticketing or monitoring systems to build a repeatable FTP troubleshooting workflow.


