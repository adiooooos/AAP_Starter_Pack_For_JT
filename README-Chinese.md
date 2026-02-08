# Red Hat Ansible Automation Platform

## AAP Starter Package User Guide V3.0

**所有截图请联系我 fzhang@redhat.com**

---

## 目录

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
    - **基础配置模块 (01-09)**
      - [3.3.1 Module Config: 01_OS_info_collection_and_report](#331-module-config-01_os_info_collection_and_report)
      - [3.3.2 Module Config: 02_DNS_unified_config](#332-module-config-02_dns_unified_config)
      - [3.3.3 Module Config: 03_Unified_SELinux_Configuration](#333-module-config-03_unified_selinux_configuration)
      - [3.3.4 Module Config: 04_YUM_config](#334-module-config-04_yum_config)
      - [3.3.5 Module Config: 05_firewall_management](#335-module-config-05_firewall_management)
      - [3.3.6 Module Config: 06_Automated_Inspection_of_Linux](#336-module-config-06_automated_inspection_of_linux)
      - [3.3.7 Module Config: 07_Linux_FS_Auto_Check](#337-module-config-07_linux_fs_auto_check)
      - [3.3.8 Module Config: 08_Kernel_Log_Error_Check](#338-module-config-08_kernel_log_error_check)
      - [3.3.9 Module Config: 09_NetworkManager_Auto_Manage](#339-module-config-09_networkmanager_auto_manage)
    - **服务配置模块 (10-15)**
      - [3.3.10 Module Config: 10_dns_config](#3310-module-config-10_dns_config)
      - [3.3.11 Module Config: 11_dhcp_config](#3311-module-config-11_dhcp_config)
      - [3.3.12 Module Config: 12_maria_db_config](#3312-module-config-12_maria_db_config)
      - [3.3.13 Module Config: 13_NFS_server_config](#3313-module-config-13_nfs_server_config)
      - [3.3.14 Module Config: 14_sshd_fix](#3314-module-config-14_sshd_fix)
      - [3.3.15 Module Config: 15_RHEL9_Standard_Config](#3315-module-config-15_rhel9_standard_config)
    - **故障诊断模块 (16-22)**
      - [3.3.16 Module Config: 16_Network_Fault_Diagnosis](#3316-module-config-16_network_fault_diagnosis)
      - [3.3.17 Module Config: 17_Httpd_Service_Fault_Auto_Analysis](#3317-module-config-17_httpd_service_fault_auto_analysis)
      - [3.3.18 Module Config: 18_Nginx_RCA](#3318-module-config-18_nginx_rca)
      - [3.3.19 Module Config: 19_Chronyd_RCA](#3319-module-config-19_chronyd_rca)
      - [3.3.20 Module Config: 20_Ftp_RCA](#3320-module-config-20_ftp_rca)
      - [3.3.21 Module Config: 21_MEM_HIGH_Util_RCA](#3321-module-config-21_mem_high_util_rca)
      - [3.3.22 Module Config: 22_MEM_OOM_RCA](#3322-module-config-22_mem_oom_rca)
    - **部署与监控模块 (23-28)**
      - [3.3.23 Module Config: 23_Postgresql_server_deploy](#3323-module-config-23_postgresql_server_deploy)
      - [3.3.24 Module Config: 24_os_PCP](#3324-module-config-24_os_pcp)
      - [3.3.25 Module Config: 25_vnc_config](#3325-module-config-25_vnc_config)
      - [3.3.26 Module Config: 26_kdump_config](#3326-module-config-26_kdump_config)
      - [3.3.27 Module Config: 27_cve_based_patching](#3327-module-config-27_cve_based_patching)
      - [3.3.28 Module Config: 28_xfs_check](#3328-module-config-28_xfs_check)
    - **高级诊断模块 (29-32)**
      - [3.3.29 Module Config: 29_Zombie_Process_RCA](#3329-module-config-29_zombie_process_rca)
      - [3.3.30 Module Config: 30_Disk_IO_Pressure_RCA](#3330-module-config-30_disk_io_pressure_rca)
      - [3.3.31 Module Config: 31_Systemd_Unit_Deep_Check](#3331-module-config-31_systemd_unit_deep_check)
      - [3.3.32 Module Config: 32_Privileged_Account_Audit](#3332-module-config-32_privileged_account_audit)
- [附录](#附录)

---

## 1. AAP Server Configuration

### 1.1.1 Activate AAP

参考文档：[Activate AAP](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/rpm_installation/assembly-platform-install-scenario#con-adding-subscription-manifest)

#### 打开 AAP UI 界面进行配置

1. 在浏览器中输入 `https://<AAP ServerFQDN>` 并按回车键进入 UI 界面
2. 输入管理员用户名和密码（redhat / 我们配置的密码）进入 UI 界面
3. 输入您的订阅用户名和凭据以激活产品

**备注：**

- 或者向我们的供应商索取 Manifest 文件进行激活
- 请参考下图了解激活方法

---

## 2. AAP Starter Package Configuration

### 2.1 Red Hat AAP Starter Package Configuration

#### 2.1.1 Configure AAP Target Server

如果使用 AAP UI 进行自动化，我们需要配置 Inventory 和 Credentials。

- **Inventory**：由 AAP Server 管理的受控机器列表。我们可以根据受控机器的服务器操作系统和版本灵活定义和分组它们
- **Credentials**：AAP Server 存储受管机器登录密钥的位置

假设我们需要管理 RHEL7、RHEL8 等 Linux 服务器，请参考以下步骤和截图。

**备注：**

同样的方法适用于 RHEL9、CentOS、SUSE、Kirin OS 和其他 Linux 发行版的自动化。

##### 2.1.1.1 Configure /etc/hosts on AAP Server

在 AAP Server 上配置 `/etc/hosts` 文件，将受管机器写入 hosts 文件（可选）

此步骤是为了便于在 AAP Server 上使用 CMD 进行自动化内容测试。

建议将受管服务器的主机名（最好使用 FQDN 格式）和 IP 写入 hosts 文件：

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

配置完成后，使用 ping 验证：

```bash
[root@ansible25 ~]# ping -c1 [Managed Server]
```

##### 2.1.1.2 Configure SSH trust for managed machines

配置过程如下：

```bash
[root@ansible25 ~]# ssh-copy-id Test-RHEL-7.9-1
# 之前已基于 root 创建，无需再次创建 ssh-keygen

[root@ansible25 ~]# ssh-copy-id TEST-RHEL-8.9-1

[root@ansible25 ~]# ssh-copy-id kylin01.example.com

[root@ansible25 ~]# su – admin
# 之前已基于 admin 用户创建，无需再次创建 ssh-keygen

[admin@ansible25 ~]# ssh-copy-id root@Test-RHEL-7.9-1

[admin@ansible25 ~]# ssh-copy-id root@TEST-RHEL-8.9-1

[admin@ansible25 ~]# ssh-copy-id root@kylin01.example.com
```

**备注：**

1. 请记住分别在 root 和 admin 下复制 ssh-id
2. 确认配置成功，ssh 登录无需密码：

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

Inventory 列出了由 Ansible Automation Platform 管理的主机集合的清单文件。组织被分配给清单，基于清单启动 playbook 的权限在用户或团队级别进行控制。

我们可以在 UI 中通过导航到 **Automation Execution → Infrastructure → Inventories** 找到 inventory。Inventories 窗口显示当前可用清单的列表。我们可以按名称对清单进行排序，并按清单类型、机构、描述、清单创建者或修改者或其他条件进行搜索。使用以下步骤创建新清单。

具体步骤和相关参考截图如下：

1. 在导航面板中，选择 **Automation Execution → Infrastructure → Inventories**。Inventories 视图显示当前可用清单的列表
2. 单击 **Create inventory** 并从列表菜单中选择要创建的清单类型
3. 在以下字段中输入相关信息：
   - **Name**：输入清单的名称
   - **(Optional) Description**：输入描述
   - **Organization**：从可用组织中选择
   - **Instance Group**：选择要运行此清单的实例组或组。如果列表太长，使用搜索来缩小选项范围。您可以选择多个实例组并根据要运行的顺序对它们进行排序
   - **(Optional) Tags**：添加描述此清单的标签，以便它们可用于分组和过滤清单和作业
4. 添加 Inventory 后，在 **Hosts** 页面添加特定的受管机器

相关参考截图如下：

**配置 YUM 场景的 inventory 组**

**备注：**

使用相同的方法包含 RHEL8、RHEL9、CentOS、SUSE、Kirin OS 和其他 Linux 发行版。

##### 2.1.1.4 Configuring Credentials on the AAP UI

AAP 需要自动化的托管机器，前提是可以通过 ssh 等方式登录到托管机器。因此我们需要设置 Credentials。

具体步骤和相关参考截图如下：

1. 在导航面板中，选择 **Automation Execution → Infrastructure → Credentials**
2. 单击 **Create Credentials** 并创建登录凭据

以 Inventory 中的 "rhel7" 为例，为从 AAP Server 到 rhel7_inventory 的登录表单中的每个主机创建相应的登录凭据 "credential for rhel7_inventory"。

相关参考截图如下：

##### 2.1.1.5 Confirm target machine is successfully managed

返回 **[Inventory]** 页面，单击我们刚创建的 Inventory，进入 **[host]** 页面，检查我们要测试的受管机器，单击 **[run command]** 执行测试。如果测试成功，则证明目标机器已成功管理。

参考截图如下：

您还可以对 Inventory 执行高级操作，例如设置子组，或使用源插件同步动态 CMDB。更多信息，请参考 Red Hat 官方文档：[https://docs.redhat.com/zh-cn/documentation/red_hat_ansible_automation_platform/2.5/](https://docs.redhat.com/zh-cn/documentation/red_hat_ansible_automation_platform/2.5/)

---

## 3. Starter Package adaptation guide based on actual scenarios

### 3.1 Download AAP Starter Package offline and configure

#### 3.1.1 Download AAP Starter Package Offline Package

#### 3.1.2 Upload the Package to correct directory of AAP

### 3.2 Configure Projects for AAP (offline)

#### 3.2.1 Configure Project "Starter_Pack_Offline"

如下图所示：

### 3.3 Configuring Job Template for Starter Pack

在 Ansible Automation Platform (AAP) 2.5 的 UI 中使用 **Job Template** 相比直接从命令行 (cmd) 执行 Playbook 具有以下主要优势：

- **图形化管理**：UI 提供直观的界面，无需手动编写命令，操作门槛低，适合团队协作和非专业用户
- **可重复性和一致性**：Job Template 将 Playbook、Inventory 和参数预配置为模板，可以一键重复运行，确保一致性并避免命令行输入错误
- **权限控制**：AAP 的 RBAC（基于角色的访问控制）允许您限制谁可以运行特定模板，增强安全性，而命令行依赖于手动用户权限管理
- **调度和自动化**：支持计划任务，实现无人值守的自动操作，命令行需要额外工具（如 cron）来实现
- **日志记录和监控**：UI 提供实时日志视图、历史记录和状态跟踪，用于调试和审计；命令行输出需要手动保存或依赖外部日志工具
- **执行环境集成**：Job Template 可以绑定到容器化执行环境 (EE) 以确保一致的依赖关系，而命令行需要手动管理环境

总之，AAP 2.5 的 Job Template 通过 UI 增强了易用性、安全性、可管理性和自动化能力，相比命令行执行方式更加灵活但繁琐。

#### 3.3.1 Module Config: 01_OS_info_collection_and_report

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示：

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

作业的最终报告（示例）如下所示：

#### 3.3.2 Module Config: 02_DNS_unified_config

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.3 Module Config: 03_Unified_SELinux_Configuration

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.4 Module Config: 04_YUM_config

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.5 Module Config: 05_firewall_management

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.6 Module Config: 06_Automated_Inspection_of_Linux

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

报告如下所示：

#### 3.3.7 Module Config: 07_Linux_FS_Auto_Check

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

最终报告如下所示：

#### 3.3.8 Module Config: 08_Kernel_Log_Error_Check

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

渲染效果如下图所示：

#### 3.3.9 Module Config: 09_NetworkManager_Auto_Manage

您可以根据下面的截图配置 Job Template 并执行它。

设置要为目标服务器设置的标签：查看或添加...

**注意：必须设置 Survey 才能继续。**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.10 Module Config: 10_dns_config

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

如果您想在 JT 中使用 `deploy_bind_secondary_site.yml` 或 `deploy_unbound_site.yml`，可以参考相同的配置。

#### 3.3.11 Module Config: 11_dhcp_config

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.12 Module Config: 12_maria_db_config

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.13 Module Config: 13_NFS_server_config

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.14 Module Config: 14_sshd_fix

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.15 Module Config: 15_RHEL9_Standard_Config

**先决条件设置** - RHEL9 的 inventory 和 RHEL9 的 Credentials

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.16 Module Config: 16_Network_Fault_Diagnosis

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.17 Module Config: 17_Httpd_Service_Fault_Auto_Analysis

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.18 Module Config: 18_Nginx_RCA

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.19 Module Config: 19_Chronyd_RCA

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.20 Module Config: 20_Ftp_RCA

**配置 inventory FTP 中的 ftp 服务器和 ftp 客户端**

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.21 Module Config: 21_MEM_HIGH_Util_RCA

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.22 Module Config: 22_MEM_OOM_RCA

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.23 Module Config: 23_Postgresql_server_deploy

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.24 Module Config: 24_os_PCP

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.25 Module Config: 25_vnc_config

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.26 Module Config: 26_kdump_config

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

#### 3.3.27 Module Config: 27_cve_based_patching

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.28 Module Config: 28_xfs_check

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.29 Module Config: 29_Zombie_Process_RCA

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.30 Module Config: 30_Disk_IO_Pressure_RCA

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

#### 3.3.31 Module Config: 31_Systemd_Unit_Deep_Check

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

配置完成后，单击 **Launch Template** 进行测试并等待任务完成：

#### 3.3.32 Module Config: 32_Privileged_Account_Audit

在 AAP Server 的 UI 界面中，相应的 Job Template 配置如下图所示。您可以自行参考：

**创建 Survey 以适应您的环境（自定义）**

---

## 附录

本文档提供了 Red Hat Ansible Automation Platform Starter Package 的完整配置和使用指南。如有问题，请参考 Red Hat 官方文档或联系技术支持。
