<img width="1016" height="534" alt="image" src="https://github.com/user-attachments/assets/d9cca519-0c3e-4f67-a038-754590b23439" /># Red Hat Ansible Automation Platform

## AAP Starter Package User Guide V3.0

---

## Table of Contents

- [1. AAP Server Configuration](#1-aap-server-configuration)
  - [1.1.1 Activate AAP](#111-activate-aap)
- [2. AAP Starter Package Configuration](#2-aap-starter-package-configuration)
  - [2.1 Red Hat AAP Starter Package Configuration](#21-red-hat-aap-starter-package-configuration)
    - [2.1.1 Configure AAP Target Server](#211-configure-aap-target-server)
      - [2.1.1.1 Configure /etc/hosts on AAP Server](#2111-configure-etchosts-on-aap-server)
      - [2.1.1.2 Configure SSH trust for managed machines](#2112-configure-ssh-trust-for-managed-machines)
      - [2.1.1.3 Configure Inventory on the AAP UI](#2113-configure-inventory-on-the-aap-ui)
      - [2.1.1.4 Configuring Credentials on the AAP UI](#2114-configuring-credentials-on-the-aap-ui)
      - [2.1.1.5 Confirm target machine is successfully managed](#2115-confirm-target-machine-is-successfully-managed)
- [3. Starter Package adaptation guide based on actual scenarios](#3-starter-package-adaptation-guide-based-on-actual-scenarios)
  - [3.1 Download AAP Starter Package offline and configure](#31-download-aap-starter-package-offline-and-configure)
    - [3.1.1 Download AAP Starter Package Offline Package](#311-download-aap-starter-package-offline-package)
    - [3.1.2 Upload the Package to correct directory of AAP](#312-upload-the-package-to-correct-directory-of-aap)
  - [3.2 Configure Projects for AAP (offline)](#32-configure-projects-for-aap-offline)
    - [3.2.1 Configure Project &#34;Starter_Pack_Offline&#34;](#321-configure-project-starter_pack_offline)
  - [3.3 Configuring Job Template for Starter Pack](#33-configuring-job-template-for-starter-pack)
    - **Basic Modules (01-09)**
      - [3.3.1 Module Config: 01_OS_info_collection_and_report](#331-module-config-01_os_info_collection_and_report)
      - [3.3.2 Module Config: 02_DNS_unified_config](#332-module-config-02_dns_unified_config)
      - [3.3.3 Module Config: 03_Unified_SELinux_Configuration](#333-module-config-03_unified_selinux_configuration)
      - [3.3.4 Module Config: 04_YUM_config](#334-module-config-04_yum_config)
      - [3.3.5 Module Config: 05_firewall_management](#335-module-config-05_firewall_management)
      - [3.3.6 Module Config: 06_Automated_Inspection_of_Linux](#336-module-config-06_automated_inspection_of_linux)
      - [3.3.7 Module Config: 07_Linux_FS_Auto_Check](#337-module-config-07_linux_fs_auto_check)
      - [3.3.8 Module Config: 08_Kernel_Log_Error_Check](#338-module-config-08_kernel_log_error_check)
      - [3.3.9 Module Config: 09_NetworkManager_Auto_Manage](#339-module-config-09_networkmanager_auto_manage)
    - **Service Configuration Modules (10-15)**
      - [3.3.10 Module Config: 10_dns_config](#3310-module-config-10_dns_config)
      - [3.3.11 Module Config: 11_dhcp_config](#3311-module-config-11_dhcp_config)
      - [3.3.12 Module Config: 12_maria_db_config](#3312-module-config-12_maria_db_config)
      - [3.3.13 Module Config: 13_NFS_server_config](#3313-module-config-13_nfs_server_config)
      - [3.3.14 Module Config: 14_sshd_fix](#3314-module-config-14_sshd_fix)
      - [3.3.15 Module Config: 15_RHEL9_Standard_Config](#3315-module-config-15_rhel9_standard_config)
    - **Fault Diagnosis Modules (16-22)**
      - [3.3.16 Module Config: 16_Network_Fault_Diagnosis](#3316-module-config-16_network_fault_diagnosis)
      - [3.3.17 Module Config: 17_Httpd_Service_Fault_Auto_Analysis](#3317-module-config-17_httpd_service_fault_auto_analysis)
      - [3.3.18 Module Config: 18_Nginx_RCA](#3318-module-config-18_nginx_rca)
      - [3.3.19 Module Config: 19_Chronyd_RCA](#3319-module-config-19_chronyd_rca)
      - [3.3.20 Module Config: 20_Ftp_RCA](#3320-module-config-20_ftp_rca)
      - [3.3.21 Module Config: 21_MEM_HIGH_Util_RCA](#3321-module-config-21_mem_high_util_rca)
      - [3.3.22 Module Config: 22_MEM_OOM_RCA](#3322-module-config-22_mem_oom_rca)
    - **Deployment and Monitoring Modules (23-28)**
      - [3.3.23 Module Config: 23_Postgresql_server_deploy](#3323-module-config-23_postgresql_server_deploy)
      - [3.3.24 Module Config: 24_os_PCP](#3324-module-config-24_os_pcp)
      - [3.3.25 Module Config: 25_vnc_config](#3325-module-config-25_vnc_config)
      - [3.3.26 Module Config: 26_kdump_config](#3326-module-config-26_kdump_config)
      - [3.3.27 Module Config: 27_cve_based_patching](#3327-module-config-27_cve_based_patching)
      - [3.3.28 Module Config: 28_xfs_check](#3328-module-config-28_xfs_check)
    - **Advanced Diagnosis Modules (29-32)**
      - [3.3.29 Module Config: 29_Zombie_Process_RCA](#3329-module-config-29_zombie_process_rca)
      - [3.3.30 Module Config: 30_Disk_IO_Pressure_RCA](#3330-module-config-30_disk_io_pressure_rca)
      - [3.3.31 Module Config: 31_Systemd_Unit_Deep_Check](#3331-module-config-31_systemd_unit_deep_check)
      - [3.3.32 Module Config: 32_Privileged_Account_Audit](#3332-module-config-32_privileged_account_audit)
- [Appendix](#appendix)

---

## 1. AAP Server Configuration

### 1.1.1 Activate AAP

Reference documentation: [Activate AAP](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/rpm_installation/assembly-platform-install-scenario#con-adding-subscription-manifest)

#### Access AAP UI for Configuration

1. Enter `https://<AAP ServerFQDN>` in your browser and press Enter to access the UI interface<img width="1016" height="534" alt="image" src="https://github.com/user-attachments/assets/82dac3fe-2010-44e2-a74f-913a22f4b3f4" />

2. Enter the administrator username and password (redhat / the password we configured) to access the UI interface
3. Enter your subscription username and credentials to activate the product

**Note:**

- Alternatively, request a Manifest file from your vendor for activation
- Please refer to the following figure for the activation method

---

## 2. AAP Starter Package Configuration

### 2.1 Red Hat AAP Starter Package Configuration

#### 2.1.1 Configure AAP Target Server

If we are using the AAP UI for automation, we need to configure Inventory and Credentials.

- **Inventory**: A list of controlled machines managed by the AAP Server. We can flexibly define and group them according to the server OS and version of the controlled machines
- **Credentials**: The location where the AAP Server stores the login keys for managed machines

Assuming we need to manage RHEL7, RHEL8, and other Linux servers, please refer to the following steps and screenshots.

**Note:**

The same approach applies to RHEL9, CentOS, SUSE, Kirin OS, and other Linux distributions for automation.

##### 2.1.1.1 Configure /etc/hosts on AAP Server

Configure the `/etc/hosts` file on the AAP Server to add managed machines to the hosts file (optional)

This step is added to facilitate automated content testing on the AAP Server using the command line.

It is recommended to write the hostname (preferably in FQDN format) and IP of the managed server into the hosts file:

```bash
[root@ansible25 ~]# sudo vi /etc/hosts
```

```bash
[root@ansible25 ~]# more /etc/hosts
```

```text
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.71.18.156  ansible25.example.com   ansible25 //native
10.71.19.149  TEST-RHEL-8.9-1   //RHEL8
10.71.18.188    kylin01.example.com kylin01
10.71.19.234    kylin02.example.com kylin02
10.71.19.192    Test-RHEL-7.9-1   //RHEL7.9
10.71.18.251    Test-RHEL-7.9-2   //RHEL7.9
10.71.18.208    Test-RHEL-7.9-3   //RHEL7.9
10.71.18.103    win2019
```

Once configured, verify with ping:

```bash
[root@ansible25 ~]# ping -c1 [Managed Server]
```

##### 2.1.1.2 Configure SSH trust for managed machines

The configuration process is as follows:

```bash
[root@ansible25 ~]# ssh-copy-id Test-RHEL-7.9-1
# Created previously based on root, no need to create ssh-keygen again

[root@ansible25 ~]# ssh-copy-id TEST-RHEL-8.9-1

[root@ansible25 ~]# ssh-copy-id kylin01.example.com

[root@ansible25 ~]# su – admin
# Created previously based on admin user, no need to create ssh-keygen again

[admin@ansible25 ~]# ssh-copy-id root@Test-RHEL-7.9-1

[admin@ansible25 ~]# ssh-copy-id root@TEST-RHEL-8.9-1

[admin@ansible25 ~]# ssh-copy-id root@kylin01.example.com
```

**Note:**

1. Please remember to copy ssh-id under root and admin respectively
2. Confirm configuration success, SSH login without password required:

```bash
[root@aap25 ~]# ssh root@Test-RHEL-7.9-1
```

```text
Activate the web console with: systemctl enable --now cockpit.socket
Last login: Tue Mar 25 15:11:58 2025 from 10.71.18.156
[root@test-rhel-7 ~]# exit
Connection to aap25 closed.
[root@ansible25 ~]#
```

```bash
[admin@ansible25 ~]$ ssh root@Test-RHEL-7.9-1
```

```text
Activate the web console with: systemctl enable --now cockpit.socket
Last login: Tue Mar 25 13:57:10 2025 from 10.72.112.226
[root@test-rhel-7 ~]# exit
```

##### 2.1.1.3 Configure Inventory on the AAP UI

An Inventory is a collection of hosts managed by Ansible Automation Platform. Organizations are assigned to inventories, and permissions to launch playbooks based on inventories are controlled at the user or team level.

We can find the inventory in the UI by navigating to **Automation Execution → Infrastructure → Inventories**. The Inventories window displays a list of currently available inventories. We can sort inventories by name and search by inventory type, organization, description, inventory creator or modifier, or other criteria. Use the following steps to create a new inventory.

The specific steps and related reference screenshots are shown below:

1. In the navigation panel, select **Automation Execution → Infrastructure → Inventories**. The Inventories view displays a list of currently available inventories
2. Click **Create inventory** and select the type of inventory you want to create from the list menu
3. Enter relevant information in the following fields:
   - **Name**: Enter the name of the inventory
   - **(Optional) Description**: Enter a description
   - **Organization**: Select from the available organizations
   - **Instance Group**: Select the instance group or groups to run this inventory on. If the list is too long, use Search to narrow down the options. You can select multiple instance groups and sort them according to the order in which you want them to run
   - **(Optional) Tags**: Add tags that describe this inventory so they can be used to group and filter inventories and jobs
4. After adding Inventory, add specific managed machines to the **Hosts** page

The relevant reference screenshots are shown below:

**Configure inventory groups for YUM scenario**

**Note:**

Use the same method to include RHEL8, RHEL9, CentOS, SUSE, Kirin OS, and other Linux distributions.

##### 2.1.1.4 Configuring Credentials on the AAP UI

AAP requires automated managed machines, provided that they can be logged into via SSH, etc. Therefore, we need to set up Credentials.

The specific steps and related reference screenshots are shown below:

1. In the navigation panel, select **Automation Execution → Infrastructure → Credentials**
2. Click **Create Credentials** and create login credentials

Taking "rhel7" in Inventory as an example, create corresponding login credentials "credential for rhel7_inventory" for each host in the login form from AAP Server to rhel7_inventory.

The relevant reference screenshot is shown as follows:

##### 2.1.1.5 Confirm target machine is successfully managed

Return to the **[Inventory]** page, click the Inventory we just created, enter the **[host]** page, check the managed machine we want to test, click **[run command]** to execute the test. If the test is successful, it proves that the target machine has been successfully managed.

The reference screenshots are shown below:

You can also perform advanced operations for Inventory, such as setting up child groups, or using source plugins to synchronize dynamic CMDB. For more information, please refer to the Red Hat official documentation: [https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/)

---

## 3. Starter Package adaptation guide based on actual scenarios

### 3.1 Download AAP Starter Package offline and configure

#### 3.1.1 Download AAP Starter Package Offline Package

#### 3.1.2 Upload the Package to correct directory of AAP

### 3.2 Configure Projects for AAP (offline)

#### 3.2.1 Configure Project "Starter_Pack_Offline"

As shown in the following figure:

### 3.3 Configuring Job Template for Starter Pack

Using **Job Template** in the UI of Ansible Automation Platform (AAP) 2.5 has the following main benefits compared to executing Playbooks directly from the command line (cmd):

- **Graphical Management**: The UI provides an intuitive interface, no manual command writing required, low barriers to action, suitable for team collaboration and non-expert users
- **Repeatability and Consistency**: Job Template pre-configures Playbook, Inventory, and parameters as templates that can be run repeatedly with one click to ensure consistency and avoid command line input errors
- **Permission Control**: AAP's RBAC (Role-Based Access Control) allows you to restrict who can run specific templates, enhancing security, while the command line relies on manual user permission management
- **Scheduling and Automation**: Supports scheduled tasks, enabling unattended automatic operations. The command line requires additional tools (such as cron) to achieve this
- **Logging and Monitoring**: The UI provides real-time log views, history, and status tracking for debugging and auditing. Command line output needs to be saved manually or rely on external log tools
- **Execution Environment Integration**: Job Template can be bound to containerized Execution Environments (EE) to ensure consistent dependencies, while the command line needs to manually manage the environment

In summary, AAP 2.5's Job Template enhances ease of use, security, manageability, and automation capabilities through the UI compared to the flexible but cumbersome command line execution method.

#### 3.3.1 Module Config: 01_OS_info_collection_and_report

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below:

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

The final report (example) for the job looks like this:

#### 3.3.2 Module Config: 02_DNS_unified_config

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.3 Module Config: 03_Unified_SELinux_Configuration

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.4 Module Config: 04_YUM_config

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.5 Module Config: 05_firewall_management

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.6 Module Config: 06_Automated_Inspection_of_Linux

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

The reports are also shown below:

#### 3.3.7 Module Config: 07_Linux_FS_Auto_Check

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

The final report is also shown below:

#### 3.3.8 Module Config: 08_Kernel_Log_Error_Check

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

The rendering effect is shown in the following figure:

#### 3.3.9 Module Config: 09_NetworkManager_Auto_Manage

You can configure the Job Template and execute it according to the screenshot below.

Set the tag you want to set for the target server: view or add...

**Note: Survey must be set to proceed.**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.10 Module Config: 10_dns_config

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

You may refer to the same configuration if you want to use `deploy_bind_secondary_site.yml` or `deploy_unbound_site.yml` in the Job Template.

#### 3.3.11 Module Config: 11_dhcp_config

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.12 Module Config: 12_maria_db_config

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.13 Module Config: 13_NFS_server_config

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.14 Module Config: 14_sshd_fix

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.15 Module Config: 15_RHEL9_Standard_Config

**Prerequisite setting** - Inventory for RHEL9 & Credentials for RHEL9

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.16 Module Config: 16_Network_Fault_Diagnosis

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.17 Module Config: 17_Httpd_Service_Fault_Auto_Analysis

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.18 Module Config: 18_Nginx_RCA

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.19 Module Config: 19_Chronyd_RCA

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.20 Module Config: 20_Ftp_RCA

**Configure FTP server & FTP client in inventory FTP**

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.21 Module Config: 21_MEM_HIGH_Util_RCA

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.22 Module Config: 22_MEM_OOM_RCA

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.23 Module Config: 23_Postgresql_server_deploy

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.24 Module Config: 24_os_PCP

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.25 Module Config: 25_vnc_config

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.26 Module Config: 26_kdump_config

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

#### 3.3.27 Module Config: 27_cve_based_patching

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.28 Module Config: 28_xfs_check

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.29 Module Config: 29_Zombie_Process_RCA

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.30 Module Config: 30_Disk_IO_Pressure_RCA

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

#### 3.3.31 Module Config: 31_Systemd_Unit_Deep_Check

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

After the configuration is complete, click **Launch Template** to test and wait for the job to complete:

#### 3.3.32 Module Config: 32_Privileged_Account_Audit

In the UI interface of the AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:

**Creating a Survey to adapt to your environment (customization)**

---

## Appendix

This document provides a complete configuration and usage guide for the Red Hat Ansible Automation Platform Starter Package. For questions, please refer to the Red Hat official documentation or contact technical support.
