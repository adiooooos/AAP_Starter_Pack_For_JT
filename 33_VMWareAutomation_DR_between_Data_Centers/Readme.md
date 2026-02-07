# Ansible AAP Integrates with VMware vCenter for VM DR between Data Centers

## Overview

This article introduces how to use Ansible AAP to unregister specified VM from primary VMware data center and register to target data center as DR site. This scenario is also used for VM disaster recovery.

We will design an automation workflow to perform the following operations:

1. Check capacity of DR site data store
2. Send result by email to notify admin and wait for approval
3. Once get approval, automatically power off VM on primary data center
4. Unregister VM from primary site data center and register to DR site data center
5. Power on VM on DR site data center and assign new IP, gateway, DNS as demand, then auto startup application (httpd)
6. Email notify admin if above done

## Prerequisites

- **Ansible Automation Platform 2.5+** installed
- **EE for VMware integration** has been created

### VMware vCenter Configuration

On VMware vCenter UI:

- **Primary site data center**: `Beijing_dc02`
- **DR site data center**: `Shenzhen_dc01` and a cluster with name `Cluster01` is under the data center
- **VM name**: `RHEL8.10-DR-Test`, which is in directory `VMware-Lab` and `Beijing_dc02`

**Important Note:**

Theoretically, primary and DR site data center are using same data store which is usually shared storage, or primary and DR site data store can keep data sync all the time. For POC or testing purpose, we will copy VM config file (with .vmx suffix) and disk image file (with .vmdk suffix) of `RHEL8.10-DR-Test` to DR site data store for simulation.

## The Environment for VM DR between Data Center

### Preparation

#### Check VM at Primary Site

Check VM `RHEL8.10-DR-Test` at first, it's original running on primary site data center `Beijing_dc02`, under `VMware_Lab` directory.

#### Verify VM Requirements

In VM, make sure vmware-tools and perl are installed:

```bash
# Check VMware Tools
vmware-toolbox-cmd -v

# Check Perl
perl -v
```

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

### Step 1: Create the First Playbook - linux_dr_check.yml

Create the first playbook `linux_dr_check.yml` with the following content:

```yaml
---
- name: VMware Disaster Recovery Info Check
  hosts: localhost
  gather_facts: false
  vars:
    datacenter_primary: ""
    datacenter_dr: ""
    cluster_primary: ""
    cluster_dr: ""
    esxi_host_primary: ""
    esxi_host_dr: ""
    target_data_store: ""
    vm_name: ""
    validate_certs: false
    mail_host: smtp.gmail.com
    mail_port: 465
    mail_username: jerrywjl@gmail.com
    mail_password: YOUR_EMAIL_PASSWORD
    mail_to: jewang@redhat.com
  tasks:
    - name: Check datastore info in DR site
      community.vmware.vmware_datastore_info:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        datacenter: "{{ datacenter_dr }}"
        name: "{{ target_data_store }}"
        validate_certs: "{{ validate_certs }}"
      delegate_to: localhost
      register: datastore_info
    - name: Query content in specified datastore
      community.vmware.vsphere_file:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        datacenter: "{{ datacenter_dr }}"
        datastore: "{{ target_data_store }}"
        path: "{{ vm_name }}"
        state: directory
        validate_certs: "{{ validate_certs }}"
      delegate_to: localhost
      register: vm_folder_check
      ignore_errors: true
    - name: Print datastore info
      ansible.builtin.debug:
        var: datastore_info
    - name: Print datastore content list
      ansible.builtin.debug:
        var: vm_folder_check
    - name: Send DR Check Report via Email
      community.general.mail:
        host: "{{ mail_host }}"
        port: "{{ mail_port }}"
        username: "{{ mail_username }}"
        password: "{{ mail_password }}"
        to: "{{ mail_to }}"
        subject: "[Ansible Report] VMware DR Site Check for {{ vm_name }}"
        body: |
          VMware DR Check Results
          === Datastore Info ===
          {{ datastore_info | to_nice_json }}
          === VM Folder Check ===
          {{ vm_folder_check | to_nice_json }}
      delegate_to: localhost
```

### Step 2: Create the First Job Template - VM_DR_Datastore_Check

Create the first job template with name **"VM_DR_Datastore_Check"** based on the playbook `linux_dr_check.yml`.

**Job Template Configuration:**

- **Name**: VM_DR_Datastore_Check
- **Job Type**: Run
- **Inventory**: Demo Inventory (localhost)
- **Project**: Your project
- **Playbook**: linux_dr_check.yml
- **Credentials**:
  - Add `vc_credential` (VMware vCenter credential)
- **Execution Environment**: Your EE with VMware collections
- **Options**:
  - Enable **Enable Fact Storage** (to pass variables between jobs)

### Step 3: Create the Second Playbook - linux_dr.yml

Create the second playbook `linux_dr.yml` with the following content:

```yaml
---
- name: VMware Disaster Recovery Failover
  hosts: localhost
  gather_facts: false
  vars:
    datacenter_primary: ""
    datacenter_dr: ""
    cluster_primary: ""
    cluster_dr: ""
    esxi_host_primary: ""
    esxi_host_dr: ""
    target_data_store: ""
    vm_name: ""
    validate_certs: false
  tasks:
    - name: Step 1 - Power off the VM on primary site
      community.vmware.vmware_guest_powerstate:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: "{{ validate_certs }}"
        datacenter: "{{ datacenter_primary }}"
        name: "{{ vm_name }}"
        folder: "/vm"
        state: powered-off
      delegate_to: localhost
      ignore_errors: true  
    - name: Step 2 - Unregister VM from primary site esxi server
      community.vmware.vmware_guest_register_operation:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: "{{ validate_certs }}"
        datacenter: "{{ datacenter_primary }}"
        esxi_hostname: "{{ esxi_host_primary }}"
        folder: "/vm"
        name: "{{ vm_name }}"
        state: absent
      delegate_to: localhost
      ignore_errors: true  
    - name: Step 2 - Register VM to dr site esxi server
      community.vmware.vmware_guest_register_operation:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: "{{ validate_certs }}"
        datacenter: "{{ datacenter_dr }}"
        cluster: "{{ cluster_dr }}"
        folder: "{{ datacenter_dr }}/vm"
        name: "{{ vm_name }}"
        # esxi_hostname: "{{ esxi_host_dr }}"
        path: "[{{ target_data_store }}] {{ vm_name }}/{{ vm_name }}.vmx"
        template: false 
        state: present
      delegate_to: localhost
    - name: Step 3 - Power on the recovered VM
      community.vmware.vmware_guest_powerstate:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: "{{ validate_certs }}"
        datacenter: "{{ datacenter_dr }}"
        name: "{{ vm_name }}"
        folder: "/vm"
        state: powered-on
      delegate_to: localhost
```

### Step 4: Create the Second Job Template - VM_DR_Operation

Create the second job template with name **"VM_DR_Operation"** based on the playbook `linux_dr.yml`.

**Job Template Configuration:**

- **Name**: VM_DR_Operation
- **Job Type**: Run
- **Inventory**: Demo Inventory (localhost)
- **Project**: Your project
- **Playbook**: linux_dr.yml
- **Credentials**:
  - Add `vc_credential` (VMware vCenter credential)
- **Execution Environment**: Your EE with VMware collections
- **Options**:
  - Enable **Enable Fact Storage**

### Step 5: Create the Third Playbook - linux_post_dr_setup_vm.yml

Create the third playbook `linux_post_dr_setup_vm.yml` with the following content:

```yaml
---
- name: Configure recovered VM network after DR switch
  hosts: localhost
  become: yes
  vars:
    datacenter_dr: ""
    vm_name: ""
    network_interface: ""
    vm_ip: ""
    vm_netmask: ""    
    vm_gateway: ""
    vm_dns:
      - ""
      - ""
    vm_root_password: cmVkaGF0  # base64 encoded password
  pre_tasks:
    - name: Decode VM root password
      ansible.builtin.set_fact:
        decoded_vm_root_password: "{{ vm_root_password | b64decode }}"
  tasks:
    - name: Wait until VMware Tools are running
      community.vmware.vmware_guest_tools_wait:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: false
        datacenter: "{{ datacenter_dr }}"
        name: "{{ vm_name }}"
        timeout: 300
    - name: Run command inside a virtual machine with wait and timeout
      community.vmware.vmware_vm_shell:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: false
        datacenter: "{{ datacenter_dr }}"
        vm_id: "{{ vm_name }}"
        vm_username: root
        vm_password: "{{ decoded_vm_root_password }}"
        vm_shell: /usr/bin/nmcli
        vm_shell_args: >
          connection modify {{ network_interface }}
          ipv4.addresses {{ vm_ip }}/{{ vm_netmask }}
          ipv4.gateway {{ vm_gateway }}
          ipv4.dns {{ vm_dns | join(',') }}
          ipv4.method manual
          connection.autoconnect on
          ipv6.method disabled
          > /tmp/set_{{ network_interface }}.txt 2>&1
        wait_for_process: true
        timeout: 300
      register: shell_command_with_wait_timeout
    - name: Debug nmcli config output
      debug:
        var: shell_command_with_wait_timeout.stdout
    - name: Apply and enable network
      community.vmware.vmware_vm_shell:
        hostname: "{{ lookup('env', 'VMWARE_HOST') }}"
        username: "{{ lookup('env', 'VMWARE_USER') }}"
        password: "{{ lookup('env', 'VMWARE_PASSWORD') }}"
        validate_certs: false
        datacenter: "{{ datacenter_dr }}"
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
    - name: Debug nmcli apply output
      debug:
        var: apply_network.stdout
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

### Step 6: Create the Third Job Template - VM_DR_Post_Config_VM

Create the third job template with name **"VM_DR_Post_Config_VM"** based on the playbook `linux_post_dr_setup_vm.yml`.

**Job Template Configuration:**

- **Name**: VM_DR_Post_Config_VM
- **Job Type**: Run
- **Inventory**: Demo Inventory (localhost)
- **Project**: Your project
- **Playbook**: linux_post_dr_setup_vm.yml
- **Credentials**:
  - Add `vc_credential` (VMware vCenter credential)
- **Execution Environment**: Your EE with VMware collections
- **Options**:
  - Enable **Enable Fact Storage**

### Step 7: Create the Fourth Playbook - linux_post_dr_setup_app.yml

Create the fourth playbook `linux_post_dr_setup_app.yml` with the following content:

```yaml
---
- name: Add dynamic host from previous playbook
  hosts: localhost
  gather_facts: false
  tasks:
    - name: Add VM to dynamic inventory
      ansible.builtin.add_host:
        name: "{{ vm_ip }}"
        groups: provisioned
- name: Verify VM after DR - update hosts, start httpd, test service
  hosts: provisioned 
  become: yes
  tasks:
    - name: Set hostname fact
      ansible.builtin.set_fact:
        hostname: "{{ ansible_hostname }}"
    - name: Update existing entry in /etc/hosts with new IP
      ansible.builtin.replace:
        path: /etc/hosts
        regexp: '^\d+\.\d+\.\d+\.\d+\s+.*\b{{ hostname }}\b'
        replace: '{{ vm_ip }} {{ hostname }}'
        backup: yes
    - name: Ensure vm_ip and hostname are present in /etc/hosts if not matched above
      ansible.builtin.lineinfile:
        path: /etc/hosts
        line: "{{ vm_ip }} {{ hostname }}"
        state: present
        create: yes
        backup: no
    - name: Start httpd service
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: yes
    - name: Wait for HTTP service on port 80 to be available
      ansible.builtin.wait_for:
        host: "{{ vm_ip }}"
        port: 80
        timeout: 30
        state: started
    - name: Check if httpd is responding on port 80
      ansible.builtin.uri:
        url: "http://{{ vm_ip }}"
        return_content: no
        status_code: 200
```

### Step 8: Create the Fourth Job Template - VM_DR_Post_Config_App

Create the fourth job template with name **"VM_DR_Post_Config_App"** based on the playbook `linux_post_dr_setup_app.yml`.

**Job Template Configuration:**

- **Name**: VM_DR_Post_Config_App
- **Job Type**: Run
- **Inventory**: `custom_inventory` (empty inventory, placeholder only)
- **Project**: Your project
- **Playbook**: linux_post_dr_setup_app.yml
- **Credentials**:
  - Add `rhel_credential` (root password of the provisioned VM)
- **Execution Environment**: Your EE
- **Options**:
  - Enable **Enable Fact Storage**

**Important Note:**

`custom_inventory` is only a placeholder without any host, the host IP is passed as variables from previous playbook.

### Step 9: Create the Workflow Job Template

Create the workflow job template with name **"Demo2-Linux_DR_with_New_Config_Setup"**, which consists of the four Job templates just created.

**Workflow Configuration:**

1. Navigate to **Templates** → **Add** → **Add workflow template**
2. Configure:
   - **Name**: Demo2-Linux_DR_with_New_Config_Setup
   - **Organization**: Your organization
3. **Add workflow nodes**:
   - **Start** → **VM_DR_Datastore_Check** → **Approval** → **VM_DR_Operation** → **VM_DR_Post_Config_VM** → **VM_DR_Post_Config_App** → **Success**
4. Configure node relationships:
   - VM_DR_Datastore_Check runs on **Start**
   - **Approval** node runs **On Success** of VM_DR_Datastore_Check
   - VM_DR_Operation runs **On Approval** of Approval node
   - VM_DR_Post_Config_VM runs **On Success** of VM_DR_Operation
   - VM_DR_Post_Config_App runs **On Success** of VM_DR_Post_Config_VM

**Workflow Visual Representation:**

```
Start → VM_DR_Datastore_Check → Approval → VM_DR_Operation → VM_DR_Post_Config_VM → VM_DR_Post_Config_App → Success
```

### Step 10: Create Survey on the Workflow Job Template

Create a survey on the workflow job template based on your lab environment.

**Survey Variables:**

Based on the example lab environment, create survey questions for the following variables:

| Variable Name          | Question                          | Answer Type | Required | Default              |
| ---------------------- | --------------------------------- | ----------- | -------- | -------------------- |
| `datacenter_primary` | Primary Data Center Name          | Text        | Yes      | `Beijing_dc02`     |
| `datacenter_dr`      | DR Data Center Name               | Text        | Yes      | `Shenzhen_dc01`    |
| `cluster_primary`    | Primary Cluster Name              | Text        | No       | -                    |
| `cluster_dr`         | DR Cluster Name                   | Text        | Yes      | `Cluster01`        |
| `esxi_host_primary`  | Primary ESXi Hostname             | Text        | Yes      | -                    |
| `esxi_host_dr`       | DR ESXi Hostname                  | Text        | No       | -                    |
| `target_data_store`  | Target Data Store Name            | Text        | Yes      | -                    |
| `vm_name`            | VM Name                           | Text        | Yes      | `RHEL8.10-DR-Test` |
| `validate_certs`     | Validate SSL Certificates         | Boolean     | No       | `false`            |
| `network_interface`  | Network Interface Name            | Text        | Yes      | `ens192`           |
| `vm_ip`              | VM IP Address                     | Text        | Yes      | -                    |
| `vm_netmask`         | VM Netmask (CIDR notation)        | Text        | Yes      | `24`               |
| `vm_gateway`         | VM Gateway                        | Text        | Yes      | -                    |
| `vm_dns`             | DNS Servers (comma-separated)     | Text        | Yes      | -                    |
| `vm_root_password`   | VM Root Password (base64 encoded) | Password    | Yes      | -                    |
| `mail_host`          | SMTP Host                         | Text        | Yes      | `smtp.gmail.com`   |
| `mail_port`          | SMTP Port                         | Text        | Yes      | `465`              |
| `mail_username`      | SMTP Username                     | Text        | Yes      | -                    |
| `mail_password`      | SMTP Password                     | Password    | Yes      | -                    |
| `mail_to`            | Email Recipient                   | Text        | Yes      | -                    |

**Steps to Create Survey:**

1. Edit the workflow template: `Demo2-Linux_DR_with_New_Config_Setup`
2. Navigate to **Survey** tab
3. Click **Add** to create survey questions
4. Add each variable as a survey question
5. Enable **Enable Survey**
6. Click **Save**

**Note:** Passwords should be base64 encoded. To encode a password:

```bash
echo -n "your_password" | base64
```

### Step 11: Add Approval Node

Add an approval node between the first and the second job template.

**Steps to Add Approval:**

1. Edit the workflow template: `Demo2-Linux_DR_with_New_Config_Setup`
2. In the workflow visual editor, click on the connection between **VM_DR_Datastore_Check** and **VM_DR_Operation**
3. Click **+** to add a node
4. Select **Approval** node type
5. Configure approval settings:
   - **Name**: DR Approval (or your preferred name)
   - **Description**: Review DR site datastore check results and approve DR operation
   - **Timeout**: Set timeout if needed (optional)
   - **Approvers**: Add approver users or teams
6. Configure node relationships:
   - Approval node runs **On Success** of VM_DR_Datastore_Check
   - VM_DR_Operation runs **On Approval** of Approval node
7. Click **Save**

### Step 12: Enable Email Notification on the Workflow

Enable email notification on the workflow job template.

**Steps to Enable Notifier:**

1. Edit the workflow template: `Demo2-Linux_DR_with_New_Config_Setup`
2. Navigate to **Notifications** tab
3. Select the email notifier created earlier
4. Configure notification triggers:
   - **On Success**: Send email when workflow completes successfully
   - **On Failure**: Send email when workflow fails (optional)
   - **On Start**: Send email when workflow starts (optional)
5. Click **Save**

## Steps for Testing the Workflow

### Workflow Execution Time

The whole workflow needs to run about 10-15 minutes.

### Step 1: Launch the Workflow

1. Navigate to **Templates**
2. Find and click on `Demo2-Linux_DR_with_New_Config_Setup`
3. Click **Launch**
4. Fill in the survey form with your values
5. Click **Launch**

### Step 2: Monitor Workflow Execution

1. The workflow will execute the first job template: **VM_DR_Datastore_Check**
2. When the first job template completes, admin will get an email notification about target data store check on DR site

**Example Email Notification (DR Check Report):**

```
Subject: [Ansible Report] VMware DR Site Check for RHEL8.10-DR-Test

VMware DR Check Results
=== Datastore Info ===
{
  "datastore_info": {
    ...
  }
}
=== VM Folder Check ===
{
  "vm_folder_check": {
    ...
  }
}
```

### Step 3: Approval Process

1. After the first job completes, the workflow will pause at the **Approval** node
2. Another email will automatically be sent to admin for approval

**Example Approval Email:**

The approval email will contain information about the pending approval and link to approve/reject the workflow.

3. Admin needs to approve the workflow to continue

### Step 4: Continue Workflow Execution

1. After approval, the workflow will continue with:

   - **VM_DR_Operation**: Power off VM, unregister from primary site, register to DR site, power on
   - **VM_DR_Post_Config_VM**: Configure network settings
   - **VM_DR_Post_Config_App**: Update /etc/hosts, start httpd service, verify service
2. Monitor the execution in the **Jobs** view

### Step 5: Verify Results

1. **Check VM in vCenter**:

   - Log in to VMware vCenter
   - Verify the VM is now running on DR site data center (`Shenzhen_dc01`)
   - Verify the VM is in the correct cluster (`Cluster01`)
2. **Check Email Notification**:

   - Check your email inbox for the completion notification
   - Email should contain information about successful DR operation
3. **Verify VM Configuration**:

   - SSH to the recovered VM using the new IP address
   - Verify network configuration: `ip addr show`
   - Verify httpd service is running: `systemctl status httpd`
   - Verify httpd is accessible: `curl http://localhost`
4. **Verify Application**:

   - Access the application via browser: `http://<vm_ip>`
   - Verify the application is responding correctly

## Important Notes

1. **Password Encoding**: All passwords in the workflow should be base64 encoded for security.
2. **Environment Variables**: The playbook uses environment variables for vCenter credentials:

   - `VMWARE_HOST`
   - `VMWARE_USER`
   - `VMWARE_PASSWORD`

   These should be set in the Execution Environment or passed through credentials.
3. **Fact Storage**: Enable fact storage in job templates to pass variables (like `vm_ip`) between jobs in the workflow.
4. **Dynamic Inventory**: The provisioned VM is added to a dynamic inventory group `provisioned` during workflow execution.
5. **Network Configuration**: The playbook uses `nmcli` to configure network settings. Ensure NetworkManager is installed on the VM.
6. **VM Requirements**: The VM must have:

   - VMware Tools installed and running
   - Perl installed
   - NetworkManager installed
   - Root password set
   - httpd service available (for application verification)
7. **Data Store Requirements**:

   - For production: Primary and DR site should use shared storage or keep data sync
   - For POC/testing: Copy VM config file (.vmx) and disk image file (.vmdk) to DR site data store
8. **Approval Process**: The approval node allows administrators to review DR site check results before proceeding with the actual DR operation.

## Troubleshooting

### DR Check Issues

- Verify vCenter credentials are correct
- Check DR site data center and data store names are correct
- Verify data store is accessible
- Check VM folder exists in DR site data store

### VM Power Off Issues

- Verify VM is accessible on primary site
- Check VM is not locked by other operations
- Verify vCenter permissions are sufficient

### VM Registration Issues

- Verify VM files (.vmx and .vmdk) exist in DR site data store
- Check data store path is correct: `[{{ target_data_store }}] {{ vm_name }}/{{ vm_name }}.vmx`
- Verify cluster name is correct
- Check ESXi host has sufficient resources

### Network Configuration Issues

- Verify network interface name is correct
- Check IP address is not already in use
- Verify gateway and DNS servers are reachable
- Check NetworkManager is installed and running

### Application Startup Issues

- Verify httpd service is installed
- Check /etc/hosts file is updated correctly
- Verify firewall allows port 80
- Check httpd service logs: `journalctl -u httpd`

### Approval Issues

- Verify approver users/teams are configured correctly
- Check approval timeout settings
- Verify email notifications are working

### Workflow Execution Issues

- Check individual job template logs
- Verify all survey variables are provided
- Check fact storage is enabled in job templates
- Verify credentials are correctly assigned
- Review workflow visual representation for errors

## Workflow Summary

This automation workflow provides a complete solution for VM disaster recovery between data centers:

1. **Pre-DR Check**: Validates DR site data store capacity and availability
2. **Approval**: Requires manual approval before proceeding with DR operation
3. **DR Operation**: Automatically performs VM failover from primary to DR site
4. **Post-DR Configuration**: Configures network settings on recovered VM
5. **Application Verification**: Verifies and starts application services

The workflow ensures safe and controlled DR operations with proper validation, approval, and verification steps.
