## Scenario 15 – NFS Server Deployment and Configuration

This playbook is part of the AAP Starter Pack and demonstrates how to deploy a simple, production‑ready NFS server on RHEL/CentOS 7/8/9 using Ansible Automation Platform best practices.  
It focuses on clarity and safety: minimal variables, strong input validation, idempotent tasks, and explicit debug output after each functional step.

### 1. Use Case Overview

- **Goal**: Install NFS utilities, configure one exported directory, open the firewall, and validate the active NFS exports.
- **Target systems**: RHEL or CentOS **7/8/9** acting as NFS servers.
- **Typical scenario**: Central file share for application servers, web servers, or backup targets.

### 2. Inventory Example

You can reuse your existing inventory and simply define an `nfs_servers` group that points to the hosts where you want to enable NFS:

```ini
[rhel7]
Test-RHEL-7.9-1
Test-RHEL-7.9-2
Test-RHEL-7.9-3

[rhel8]
TEST-RHEL-8.9-1

[rhel9]
ansible25.example.com

[nfs_servers]
TEST-RHEL-8.9-1
ansible25.example.com
```

### 3. Playbook Location and Structure

- **Path**: `02_AAP_Starter_Pack/02_Playbooks/Ansible救火热线系列之(15)NFS 服务器部署及配置自动化/deploy_nfs_server_site.yml`
- **Host group**: `nfs_servers`
- **Main steps**:
  1. Assert OS compatibility (RHEL/CentOS 7/8/9 only) and validate input variables.
  2. Install required NFS packages.
  3. Create and secure the shared directory.
  4. Write the export configuration under `/etc/exports.d/` with basic error handling (`block/rescue`).
  5. Start and enable the `nfs-server` service and open the firewall.
  6. Run `exportfs -rav` and show the active NFS exports for verification.

Each functional step is followed by a `debug` task to make troubleshooting and auditing easier.

### 4. Variables

The playbook uses a small set of variables so that you can adapt it quickly:

```yaml
nfs_shared_directory: /srv/myshare
nfs_export_entries:
  - "client1.example.com(rw,no_root_squash)"
nfs_exports_filename: ansible-share.exports
```

- **`nfs_shared_directory`**: Absolute path of the directory to export.
- **`nfs_export_entries`**: A list of client definitions in the form `host_or_network(options)`.
- **`nfs_exports_filename`**: Name of the file created under `/etc/exports.d/`.

Input validation ensures that:

- The OS is supported (RHEL/CentOS 7/8/9).
- `nfs_shared_directory` is an absolute path.
- At least one client entry is defined.

### 5. How to Run

From your Ansible control node, run:

```bash
ansible-playbook -i inventory deploy_nfs_server_site.yml
```

Or, if you are using Ansible Automation Platform, create a Job Template that points to this playbook and your inventory, then launch the job from the AAP web UI.

### 6. What You Should See

On a successful run, you should observe:

- `nfs-utils` installed (if not already present).
- The directory defined in `nfs_shared_directory` created (or confirmed to exist) with `0755` permissions.
- A configuration file such as `/etc/exports.d/ansible-share.exports` created or updated.
- `nfs-server` started and enabled at boot.
- Firewall updated to allow the `nfs` service (if `firewalld` is in use).
- Debug output showing the active exports from `exportfs -rav`.

If there is a failure while updating the exports configuration, the playbook uses a `block/rescue` structure to provide clear guidance for manual rollback using the backup file created by the `copy` module.


