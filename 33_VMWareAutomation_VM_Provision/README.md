# Ansible AAP Integrates with VMware vCenter for VM Provision Automatically

## Overview

This article introduces the steps and playbooks/job templates for VM automatic provisioning by Ansible AAP and VMware integration.

We will design an automation workflow to perform the following operations:

1. Automatically clone Linux (RHEL) VM from existing VM template on VMware
2. Cloned VM auto power on and apply network setting as demand
3. Apply security baseline on provisioned VM
4. Email notify administrator when above job done

## Prerequisites

- **Ansible Automation Platform 2.5+** installed
- **EE for VMware integration** has been created
- **VM template (RHEL 8.x)** already existed on VMware ESXi server with vmware-tools installed
- **Admin or privileged user** with username & password on VMware vCenter
- **Email setting parameters** is ready (including mail server, port, sender username & password and recipient list)
- **Organization, Project** has been created on AAP UI

## The Environment for VM Provision Automatically

### Preparation

#### Check VM Template on VMware

Make sure vmware-tools and perl are installed on the VM template.

**Note:**

Below is the more detail information about the VM template used in this example:

- **Name**: RHEL8.10-VM-Template
- **Location**: In VMware folder `VMware_Lab`, and VMware datacenter `Beijing_dc02`

#### Create vCenter Credential

Based on vCenter admin username and password, create a credential on AAP.

**Example Lab Environment:**

- **vCenter IP**: 10.71.18.138
- **Admin Username**: administrator@vsphere.local
- **Admin Password**: Your_password

**Steps to Create Credential:**

1. Navigate to **Credentials** → **Add** on AAP Web UI
2. Create a credential with:
   - **Name**: `vc_credential`
   - **Type**: `VMware vCenter`
   - **vCenter Host**: 10.71.18.138
   - **Username**: administrator@vsphere.local
   - **Password**: Your_password

**Important Note:**

Since calling vCenter to execute VMware modules and collections is generally done on AAP, playbook tasks are usually executed locally on AAP via `delegate_to: localhost` or `aap`. Therefore, there is no need to create an inventory for VMware on the AAP UI.

Ensure that the AAP controller's project directory contains a complete `ansible.cfg` file (encapsulated within a custom EE), an inventory file, and a complete collection (for local testing).

**Example ansible.cfg:**

```ini
[defaults]
inventory = ./inventory
remote_user = admin

[privilege_escalation]
become = true
become_method = sudo
become_user = root
become_ask_pass = false
```

#### Setup Notifier on AAP

Create an email notifier on AAP Web UI.

**Steps to Create Notifier:**

1. Navigate to **Notifications** → **Add** on AAP Web UI
2. Configure email notifier with:
   - **Name**: Your preferred name
   - **Notification Type**: Email
   - **SMTP Host**: Your SMTP server (e.g., smtp.gmail.com)
   - **SMTP Port**: Your SMTP port (e.g., 465)
   - **Username**: Your email username
   - **Password**: Your email password
   - **Sender Email**: Your sender email address
   - **Recipient List**: Comma-separated list of recipient email addresses

## Steps for Create the Automation Workflow

### Step 1: Create the First Playbook - linux_vm_deploy.yml

Create the first playbook `linux_vm_deploy.yml` with the following content:

```yaml
---
- name: Deploy and configure RHEL VM on VMware
  hosts: localhost
  collections:
    - community.vmware
  vars:
    vcenter_hostname: ""
    vcenter_username: ""
    vcenter_password: ""
    data_center: ""
    virtual_network: ""
    vm_template: ""
    vm_name: ""
    vm_folder: ""
    network_interface: ""
    vm_ip: ""
    vm_netmask: ""
    vm_gateway: ""
    vm_dns:
      - ""
      - ""
    vm_root_password: cmVkaGF0  # base64 encoded password
  tasks:
    - name: Decode vcenter and virtual machine password
      ansible.builtin.set_fact:
        decoded_vcenter_password: "{{ vcenter_password | b64decode }}"
        decoded_vm_root_password: "{{ vm_root_password | b64decode }}"
    - name: Deploy VM from template
      vmware_guest:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: false
        name: "{{ vm_name }}"
        template: "{{ vm_template }}"
        folder: "{{ vm_folder }}"
        datacenter: "{{ data_center }}"
        state: powered-on
        networks:
          - name: "{{ virtual_network }}"
            ip: "{{ vm_ip }}"
            netmask: "{{ vm_netmask }}"
            gateway: "{{ vm_gateway }}"
            dns_servers: "{{ vm_dns }}"
            type: static
            device_type: vmxnet3
            connected: true
            start_connected: true
            wait_for_ip_address: true
            wait_for_ip_address_timeout: 60
      register: vm_deploy
    - name: Wait until VMware Tools are running
      community.vmware.vmware_guest_tools_wait:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: false
        datacenter: "{{ data_center }}"
        name: "{{ vm_name }}"
        folder: "{{ vm_folder }}"
        timeout: 300
    - name: Run command inside a virtual machine with wait and timeout
      vmware_vm_shell:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: false
        datacenter: "{{ data_center }}"
        folder: "{{ vm_folder }}"
        vm_id: "{{ vm_name }}"
        vm_username: root
        vm_password: "{{ decoded_vm_root_password }}"
        vm_shell: /usr/bin/nmcli
        vm_shell_args: >
          connection modify {{ network_interface }}
          ipv4.addresses {{ vm_ip }}/24
          ipv4.gateway {{ vm_gateway }}
          ipv4.dns {{ vm_dns | join(',') }}
          ipv4.method manual
          connection.autoconnect on
          ipv6.method disabled
          > /tmp/set_{{ network_interface }}.txt 2>&1
        wait_for_process: true
        timeout: 300
      register: shell_command_with_wait_timeout
    - name: Apply and enable network
      vmware_vm_shell:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: false
        datacenter: "{{ data_center }}"
        folder: "{{ vm_folder }}"
        vm_id: "{{ vm_name }}"
        vm_username: root
        vm_password: "{{ decoded_vm_root_password }}"
        vm_shell: /usr/bin/nmcli
        vm_shell_args: >
          connection up {{ network_interface }}
          > /tmp/apply_{{ network_interface }}.txt 2>&1
        wait_for_process: true
        timeout: 60
      register: apply_network
    - name: Set vm_ip as a fact for workflow usage
      ansible.builtin.set_stats:
        data:
          vm_ip: "{{ vm_ip }}"
        per_host: false
    - name: Add deployed VM to inventory
      ansible.builtin.add_host:
        name: "{{ vm_ip }}"
        groups: provisioned
```

### Step 2: Create the First Job Template - T1 / Create_VMs_from_Template

Create the first job template with name **"T1 / Create_VMs_from_Template"** based on the playbook `linux_vm_deploy.yml`.

**Job Template Configuration:**

- **Name**: T1 / Create_VMs_from_Template
- **Job Type**: Run
- **Inventory**: Demo Inventory (localhost)
- **Project**: Your project
- **Playbook**: linux_vm_deploy.yml
- **Credentials**:
  - Add `vc_credential` (VMware vCenter credential)
- **Execution Environment**: Your EE with VMware collections
- **Options**:
  - Enable **Enable Fact Storage** (to pass variables between jobs)

### Step 3: Create the Second Playbook - linux_baseline_apply.yml

Create the second playbook `linux_baseline_apply.yml` with the following content:

```yaml
- name: Add dynamic host from previous playbook
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Add VM to dynamic inventory
      ansible.builtin.add_host:
        name: "{{ vm_ip }}"
        groups: provisioned
- name: Apply baseline configuration
  hosts: provisioned
  gather_facts: true
  become: true
  tasks:
    - name: Ensure pwquality minimum length
      lineinfile:
        path: /etc/security/pwquality.conf
        line: 'minlen = 14'
        create: yes
    - name: Set PASS_MAX_DAYS to 30
      replace:
        path: /etc/login.defs
        regexp: '^PASS_MAX_DAYS\s+\d+'
        replace: 'PASS_MAX_DAYS   30'
    - name: Set PASS_MIN_DAYS to 1
      replace:
        path: /etc/login.defs
        regexp: '^PASS_MIN_DAYS\s+\d+'
        replace: 'PASS_MIN_DAYS   1'
    - name: Update system-auth pwquality line
      replace:
        path: /etc/pam.d/system-auth
        regexp: '^password\s+requisite\s+pam_pwquality\.so.*'
        replace: 'password    requisite     pam_pwquality.so local_users_only'
    - name: Add pwhistory to system-auth
      lineinfile:
        path: /etc/pam.d/system-auth
        line: 'password    requisite     pam_pwhistory.so remember=13 use_authtok'
        insertafter: '^password\s+requisite\s+pam_pwquality\.so.*'
    - name: Update password-auth pwquality line
      replace:
        path: /etc/pam.d/password-auth
        regexp: '^password\s+requisite\s+pam_pwquality\.so.*'
        replace: 'password    requisite     pam_pwquality.so local_users_only'
    - name: Add pwhistory to password-auth
      lineinfile:
        path: /etc/pam.d/password-auth
        line: 'password    requisite     pam_pwhistory.so remember=13 use_authtok'
        insertafter: '^password\s+requisite\s+pam_pwquality\.so.*'
    - name: Set faillock deny = 3
      replace:
        path: /etc/security/faillock.conf
        regexp: '^#?\s*deny\s*=.*'
        replace: 'deny = 3'
    - name: Force root to change password on next login
      command: chage -d 0 root
    - name: Set journald storage to persistent
      replace:
        path: /etc/systemd/journald.conf
        regexp: '^#?Storage=.*'
        replace: 'Storage=persistent'
    - name: Restart systemd-journald
      service:
        name: systemd-journald
        state: restarted
    - name: Ensure authpriv logging is configured
      lineinfile:
        path: /etc/rsyslog.conf
        regexp: '^authpriv\.\*'
        line: 'authpriv.*    /var/log/secure'
    - name: Ensure /var/log/secure exists with correct permissions
      file:
        path: /var/log/secure
        state: touch
        owner: root
        group: root
        mode: '0600'
    - name: Ensure audit is installed
      package:
        name: audit
        state: present
    - name: Ensure auditd service is running and enabled
      service:
        name: auditd
        state: started
        enabled: yes
    - name: Ensure /var/log/audit/audit.log exists
      file:
        path: /var/log/audit/audit.log
        state: touch
        owner: root
        group: root
    - name: Ensure /var/log/cron exists
      file:
        path: /var/log/cron
        state: touch
        owner: root
        group: root
        mode: '0600'
    - name: Ensure /var/log/boot exists
      file:
        path: /var/log/boot
        state: touch
        owner: root
        group: root
        mode: '0600'
    - name: Download and place yum repo file
      get_url:
        url: http://10.66.208.245/rhel810.repo
        dest: /etc/yum.repos.d/rhel810.repo
    - name: Validate yum repo
      command: yum repolist
      register: yum_output
      changed_when: false
    - name: Ensure chrony is installed and enabled
      package:
        name: chrony
        state: present
    - name: Ensure chronyd is running and enabled
      service:
        name: chronyd
        state: started
        enabled: yes
    - name: Add cron job for secure log backup
      cron:
        name: Backup secure log
        minute: 0
        hour: 3
        job: 'cp /var/log/secure /backup/secure.$(date +\%Y\%m\%d)'
    - name: Add cron job for messages log backup
      cron:
        name: Backup messages log
        minute: 0
        hour: 3
        job: 'cp /var/log/messages /backup/messages.$(date +\%Y\%m\%d)'
    - name: Restart cron service
      service:
        name: crond
        state: restarted
```

### Step 4: Create the Second Job Template - T2 / Apply_baseline_for_provisioned

Create the second job template with name **"T2 / Apply_baseline_for_provisioned"** based on the playbook `linux_baseline_apply.yml`.

**Job Template Configuration:**

- **Name**: T2 / Apply_baseline_for_provisioned
- **Job Type**: Run
- **Inventory**: `custom_inventory` (empty inventory, placeholder only)
- **Project**: Your project
- **Playbook**: linux_baseline_apply.yml
- **Credentials**:
  - Add `rhel_credential` (root password of the provisioned VM or VM template)
- **Execution Environment**: Your EE
- **Options**:
  - Enable **Enable Fact Storage**

**Important Note:**

The inventory `custom_inventory` is actually an empty inventory, containing no hosts and serving only as a placeholder.

The credential `rhel_credential` is root password of the provisioned VM or VM template.

### Step 5: Create the Third Playbook - linux_provision_notification.yml

Create the third playbook `linux_provision_notification.yml` with the following content:

```yaml
---
- name: Email Notification for VM provision result
  hosts: localhost
  vars:
    data_center: ""
    virtual_network: ""
    vm_template: ""
    vm_name: ""
    vm_folder: ""
    network_interface: ""
    vm_ip: ""
    vm_netmask: ""
    vm_gateway: ""
    vm_dns:
      - ""
      - ""
  tasks:
    - name: Send Email notification for provision result
      delegate_to: localhost
      community.general.mail:
        host: smtp.gmail.com
        port: 465
        username: jerrywjl@gmail.com
        password: YOUR_EMAIL_PASSWORD
        to: jewang@redhat.com
        subject: "VM Provision Complete Notification from Ansible Automation Platform"
        body: |
          VM Provisioning Complete!
          Details:
          - Data Center        : {{ data_center }}
          - Virtual Network    : {{ virtual_network }}
          - VM Template        : {{ vm_template }}
          - VM Name            : {{ vm_name }}
          - VM Folder          : {{ vm_folder }}
          - Network Interface  : {{ network_interface }}
          - IP Address         : {{ vm_ip }}
          - Netmask            : {{ vm_netmask }}
          - Gateway            : {{ vm_gateway }}
          - DNS Servers        : {{ vm_dns | join(', ') }}
          This message was generated automatically by Ansible Automation Platform.
        subtype: plain
```

### Step 6: Create the Third Job Template - T3 / Provision_result_notification

Create the third job template with name **"T3 / Provision_result_notification"** based on the playbook `linux_provision_notification.yml`.

**Job Template Configuration:**

- **Name**: T3 / Provision_result_notification
- **Job Type**: Run
- **Inventory**: `Demo Inventory` (localhost, AAP controller itself)
- **Project**: Your project
- **Playbook**: linux_provision_notification.yml
- **Credentials**:
  - Add `aap_local` (localhost, AAP controller itself)
- **Execution Environment**: Your EE with email collection

**Important Note:**

The inventory `Demo Inventory` is localhost, AAP controller itself.

The credential `aap_local` is also localhost, AAP controller itself.

### Step 7: Create the Workflow Job Template

Create the workflow job template with name **"Linux_VM_Provision_with_Baseline_apply"**, which consists of Job template T1-T3 we just created.

**Workflow Configuration:**

1. Navigate to **Templates** → **Add** → **Add workflow template**
2. Configure:
   - **Name**: Linux_VM_Provision_with_Baseline_apply
   - **Organization**: Your organization
3. **Add workflow nodes**:
   - **Start** → **T1 / Create_VMs_from_Template** → **T2 / Apply_baseline_for_provisioned** → **T3 / Provision_result_notification** → **Success**
4. Configure node relationships:
   - T1 runs on **Start**
   - T2 runs **On Success** of T1
   - T3 runs **On Success** of T2

**Workflow Visual Representation:**

```
Start → T1 (Create_VMs_from_Template) → T2 (Apply_baseline_for_provisioned) → T3 (Provision_result_notification) → Success
```

### Step 8: Create Survey on the Workflow Job Template

Create a survey on the workflow job template based on your lab environment.

**Survey Variables:**

Based on the example lab environment, create survey questions for the following variables:

| Variable Name         | Question                          | Answer Type | Required | Default                  |
| --------------------- | --------------------------------- | ----------- | -------- | ------------------------ |
| `vcenter_hostname`  | vCenter Hostname/IP               | Text        | Yes      | -                        |
| `vcenter_username`  | vCenter Username                  | Text        | Yes      | -                        |
| `vcenter_password`  | vCenter Password (base64 encoded) | Password    | Yes      | -                        |
| `data_center`       | Data Center Name                  | Text        | Yes      | `Beijing_dc02`         |
| `virtual_network`   | Virtual Network Name              | Text        | Yes      | -                        |
| `vm_template`       | VM Template Name                  | Text        | Yes      | `RHEL8.10-VM-Template` |
| `vm_name`           | VM Name                           | Text        | Yes      | -                        |
| `vm_folder`         | VM Folder                         | Text        | Yes      | `VMware_Lab`           |
| `network_interface` | Network Interface Name            | Text        | Yes      | `ens192`               |
| `vm_ip`             | VM IP Address                     | Text        | Yes      | -                        |
| `vm_netmask`        | VM Netmask                        | Text        | Yes      | `255.255.255.0`        |
| `vm_gateway`        | VM Gateway                        | Text        | Yes      | -                        |
| `vm_dns`            | DNS Servers (comma-separated)     | Text        | Yes      | -                        |
| `vm_root_password`  | VM Root Password (base64 encoded) | Password    | Yes      | -                        |

**Steps to Create Survey:**

1. Edit the workflow template: `Linux_VM_Provision_with_Baseline_apply`
2. Navigate to **Survey** tab
3. Click **Add** to create survey questions
4. Add each variable as a survey question
5. Enable **Enable Survey**
6. Click **Save**

**Note:** Passwords should be base64 encoded. To encode a password:

```bash
echo -n "your_password" | base64
```

### Step 9: Enable Notifier on the Workflow

Enable notifier on the workflow job template.

**Steps to Enable Notifier:**

1. Edit the workflow template: `Linux_VM_Provision_with_Baseline_apply`
2. Navigate to **Notifications** tab
3. Select the email notifier created earlier
4. Configure notification triggers:
   - **On Success**: Send email when workflow completes successfully
   - **On Failure**: Send email when workflow fails (optional)
5. Click **Save**

### Step 10: Launch the Workflow

When you launch the workflow, you will need to input variables with the survey created above.

**Steps to Launch:**

1. Navigate to **Templates**
2. Find and click on `Linux_VM_Provision_with_Baseline_apply`
3. Click **Launch**
4. Fill in the survey form with your values
5. Click **Launch**

**Example Survey Values (Based on Lab Environment):**

- **vCenter Hostname**: 10.71.18.138
- **vCenter Username**: administrator@vsphere.local
- **vCenter Password**: (base64 encoded password)
- **Data Center**: Beijing_dc02
- **Virtual Network**: (your network name)
- **VM Template**: RHEL8.10-VM-Template
- **VM Name**: (your VM name)
- **VM Folder**: VMware_Lab
- **Network Interface**: ens192
- **VM IP Address**: (your VM IP)
- **VM Netmask**: 255.255.255.0
- **VM Gateway**: (your gateway)
- **DNS Servers**: (comma-separated DNS servers)
- **VM Root Password**: (base64 encoded password)

## Workflow Execution Result

After the workflow runs successfully, you will get an email notification about the result.

**Email Notification Content:**

The email will contain the following information:

- Data Center
- Virtual Network
- VM Template
- VM Name
- VM Folder
- Network Interface
- IP Address
- Netmask
- Gateway
- DNS Servers

**Example Email:**

```
VM Provisioning Complete!
Details:
- Data Center        : Beijing_dc02
- Virtual Network    : <your_network>
- VM Template        : RHEL8.10-VM-Template
- VM Name            : <your_vm_name>
- VM Folder          : VMware_Lab
- Network Interface  : ens192
- IP Address         : <your_vm_ip>
- Netmask            : 255.255.255.0
- Gateway            : <your_gateway>
- DNS Servers        : <your_dns_servers>
This message was generated automatically by Ansible Automation Platform.
```

## Important Notes

1. **Password Encoding**: All passwords in the workflow should be base64 encoded for security.
2. **Environment Variables**: The playbook uses environment variables for vCenter credentials:

   - `VMWARE_HOST`
   - `VMWARE_USER`
   - `VMWARE_PASSWORD`

   These should be set in the Execution Environment or passed through credentials.
3. **Fact Storage**: Enable fact storage in job templates to pass variables (like `vm_ip`) between jobs in the workflow.
4. **Dynamic Inventory**: The provisioned VM is added to a dynamic inventory group `provisioned` during workflow execution.
5. **Network Configuration**: The playbook uses `nmcli` to configure network settings. Ensure NetworkManager is installed on the VM template.
6. **VM Template Requirements**: The VM template must have:

   - VMware Tools installed and running
   - Perl installed
   - NetworkManager installed
   - Root password set

## Troubleshooting

### VM Deployment Issues

- Verify vCenter credentials are correct
- Check VM template exists and is accessible
- Verify data center and folder names are correct
- Check VMware Tools is installed on template

### Network Configuration Issues

- Verify network interface name is correct
- Check IP address is not already in use
- Verify gateway and DNS servers are reachable
- Check NetworkManager is installed and running

### Email Notification Issues

- Verify SMTP server settings are correct
- Check SMTP port is not blocked by firewall
- Verify email credentials are correct

### Workflow Execution Issues

- Check individual job template logs
- Verify all survey variables are provided
- Check fact storage is enabled in job templates
- Verify credentials are correctly assigned
