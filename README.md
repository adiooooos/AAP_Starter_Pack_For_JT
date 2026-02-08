# AAP_Starter_Pack_User_Guide






Red Hat Ansible Automation Platform -AAP Starter Package User Guide V3. 0 (offline deploy mode)

 
1	AAP Server Configuration
1.1.1	Activate AAP 
Open the UI interface of AAP to configure:
Enter https:/< AAP ServerFQDN>in the browser and click Enter to enter the UI interface. Enter admin username and password (redhat /password we configured) to enter UI interface
 
Enter your subscription username and credentials to activate the product.
 
REMARK:
1.	OR ASK OUR VENDOR FOR THE MANIFEST FILE TO ACTIVATE;
2.	PLEASE REFER TO THE FOLLOWING FIGURE FOR ACTIVATION METHOD

 
 
 
 
 

2	AAP Starter Package Configuration
2.1	Red Hat AAP Starter Package Configuration
2.1.1	Configure AAP Target Server
If we are using the AAP UI for automation, we need to configure Inventory and Credentials.
Inventory is a list of controlled machines managed by AAP Server. We can flexibly define and group them according to the Server OS and version of the controlled machines;
Credentials is where the AAP Server stores the login key for the managed machine.
Suppose we need to mamage RHEL7, RHEL8, etc. Linux servers. Please refer to the following steps and screenshots.
REMARK:
1.	THE SAME APPROACH APPLIES TO RHEL9,CENTOS, SUSE, KIRIN OS, AND OTHER LINUX DISTRIBUTIONS FOR AUTOMATION.


2.1.1.1	Configure/etc/hosts on AAP Server to write managed machines to hosts file (optional)
This step is added to facilitate automated content testing on AAP Server using CMD.
It is recommended to write the hostname (preferably in FQDNformat) and IP of the managed server into the hosts file:
[root@ansible25 ~]# sudo vi /etc/hosts
[root@ansible25 ~]# more /etc/hosts
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
Once configured, verify with ping

[root@ansible25 ~]#ping -c1 [Managed Server]

2.1.1.2	Configure SSH trust for managed machines
The configuration process is as follows:
[root@ansible25 ~]# ssh-copy-id Test-RHEL-7.9-1 //created previously based on root, no need to create ssh-keygen again
[root@ansible25 ~]# ssh-copy-id TEST-RHEL-8.9-1
[root@ansible25 ~]# ssh-copy-id kylin01.example.com
[root@ansible25 ~]# su – admin //created previously based on admin user, no need to create ssh-keygen again
[admin@ansible25 ~]# ssh-copy-id root@Test-RHEL-7.9-1 
[admin@ansible25 ~]# ssh-copy-id root@TEST-RHEL-8.9-1
[admin@ansible25 ~]# ssh-copy-id root@kylin01.example.com
REMARK:
1.	PLEASE REMEMBER TO COPY SSH-ID UNDER ROOT AND ADMIN RESPECTIVELY;
Confirm configuration success, ssh login No password required Login:
[root@aap25 ~]# ssh root@Test-RHEL-7.9-1
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Tue Mar 25 15:11:58 2025 from 10.71.18.156
[root@test-rhel-7 ~]# exit
write off
Connection to aap25 closed.
[root@ansible25 ~]# 
[admin@nsible25 ~]$ ssh root@Test-RHEL-7.9-1
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Tue Mar 25 13:57:10 2025 from 10.72.112.226
[root@test-rhel-7 ~]# exit

2.1.1.3	Configure Inventory on the AAP UI
Inventory lists files for the host collections managed by Ansible Automation Platform. Organizations are assigned to lists, and permissions to launch playbooks based on lists are controlled at the user or team level.
We can find the inventory in the UI by navigating to Automation Execution → Infrastructure → Inventories. The Inventories window displays a list of currently available inventories. We can sort lists of manifests by name and search by manifest type, institution, description, manifest creator or modifier, or other criteria. Use the following steps to create a new inventory.
The specific steps and related reference screenshots are shown below:
1.	In the navigation panel, select Automation Execution → Infrastructure → Inventories. Inventories view displays a list of currently available inventories.
2.	Click Create inventory and select the type of inventory you want to create from the list menu;
3.	Enter relevant information in the following fields:
a)	Name: Enter the name of the manifest.
b)	(Optional) Description: Enter a description.
c)	Organization: Select from the available organizations.
d)	Instance Group: Select the instance group or group to run this manifest on. If the list is too long, use Search to narrow down the options. You can select multiple instance groups and sort them according to the order in which you want them to run.
e)	(Optional) Tags: Add tags that describe this manifest so they can be used to group and filter manifests and jobs.
4.	After adding Inventory, add specific managed machines to the Hosts page;

The relevant reference screenshots are shown below:
 
 
 
 
 
Config groups of inventory for YUM scenario
 
 
 
REMARK:
1.	USE THE SAME METHOD TO INCLUDE RHEL8, RHEL9,CENTOS, SUSE, KIRIN OS, AND OTHER LINUX DISTRIBUTIONS.

2.1.1.4	Configuring Credentials on the AAP UI
AAP requires automated hosted machines, provided that they can be logged in to hosted machines via ssh, etc. So we need to set up Credentials.
The specific steps and related reference screenshots are shown below:
1.	In the navigation panel, select Automation Execution → Infrastructure → Credentials.
2.	Click Create Credentials and create login credentials;

Take "rhel7 " in Inventory as an example, create correspondinglogin credentials "credential for rhel7_inventory" for each host in the login formfrom AAP Server torhel7_inventory. The relevant reference screenshot is shown as follows:
 
 

2.1.1.1	Confirm target machine is successfully managed
Go back to [Inventory] page, click the Inventory we just created, enter [host] page, check the managed machine we want to test, click [run command] to execute the test. If the test is successful, it proves that the target machine has been successfully managed.
The reference screenshots are shown below:
 
 
 
 
 
 
 
You can also perform advanced operations for Inventory, such as setting up child groups, or using the source plug-in to synchronize dynamic CMDB. For more information, please refer to Red Hat official documentationhttps://docs.redhat.com/zh-cn/documentation/red_hat_ansible_automation_platform/2.5/


3	Starter Package adaptation guide based on actual scenarios
3.1	Download AAP Starter Package offline and configure
1.1	Download AAP Starter Package Offline Package
 
1.2	Upload the Package to correct directory of AAP
 
3.2	Configure Projects for AAP (offline)
3.2.1	Configure Project "Starter_Pack_Offline"
As shown in the following figure:
 
 
3.3	Configuring Job Template for Starter Pack
Using Job Template in the UI of Ansible Automation Platform (AAP) 2.5 has the following main benefits compared to executing Playbook directly from the command line (cmd):
	Graphical management: 
UI provides intuitive interface, no manual command writing, low barriers to action, suitable for team collaboration and non-expert users.
	Repeatability and consistency: 
Job Template pre-configures Playbook, Inventory and parameters as templates that can be run repeatedly with one click to ensure consistency and avoid command line input errors.
	Permission Control: 
RBAC (Role Access Control) for AAP allows you to restrict who can run specific templates, enhancing security, while the command line relies on manual user permission management.
	Scheduling and automation: 
Support scheduled tasks, realize unattended automatic operation, command line needs additional tools (such as cron) to achieve.
	Logging and monitoring: 
UI provides real-time log view, history, and status tracking for debugging and auditing; command line output needs to be saved manually or rely on external log tools. 
	Execution environment integration: 
Job Template can be bound to containerized execution environment (EE) to ensure consistent dependencies, and the command line needs to manually manage the environment.
In short, AAP 2.5 's Job Template enhances ease of use, security, manageability, and automation capabilities through the UI over the flexible but cumbersome way command line execution works.

3.3.1	Module Config: 01_OS_info_collectoin_and_report
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below:
 
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
The final report (example) for the job looks like this:
 

3.3.2	Module Config: 02_DNS_unified_config
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 

3.3.3	Module Config: 03_Unified_SELinux_Configuration
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
 
 
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
 
 

3.3.4	Module Config: 04_YUM_config
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 

 
 
 
 

After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
 
 


3.3.5	Module Config: 05_firewall_management
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
 

3.3.6	Module Config: 06_Automated_Inspection_of_Linux
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
 
The reports are also shown in below:
 

3.3.7	Module Config: 07_Linux_FS_Auto_Check
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 

Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
 
 
The final report is also shown in the below:
 


3.3.8	Module Config: 08_Kernel_Log_Error_Check
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
The rendering effect is shown in the following figure:
 


3.3.9	Module Config: 09_NetworkManager_Auto_Manage
You can configure the job Template and execute it according to the screenshot below.
Set the tag you want to set for the target server: view or add…
 
 
Note that Survey must be set to proceed.
 
 
 
 
 
 
 

After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
 

3.3.10	Module Config: 10_dns_config
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
The same configuration you may refer to if you want to use deploy_bind_secondary_site.yml or deploy_unbound_site.yml to in JT.

3.3.11	Module Config: 11_dhcp_config
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:


3.3.12	Module Config: 12_maria_db_config
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 

3.3.13	Module Config: 13_NFS_server_config
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
 
 
 
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
 

3.3.14	Module Config: 14_sshd_fix
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 

3.3.15	Module Config: 15_RHEL9_Standard_Config
Prerequisite setting- inventory for rhel9 & Credentials for rhel9
 
 
 
 
 
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 

3.3.16	Module Config: 16_Network_Fault_Diagnosis
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
 

3.3.17	Module Config: 17_Httpd_Service_Fault_Auto_Analysi
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 

3.3.18	Module Config: 18_Nginx_RCA
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 

After the configuration is complete, click Launch Template to test and wait for the mission to complete:

3.3.19	Module Config: 19_Chronyd_RCA
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 

After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 
 

3.3.20	Module Config: 20_Ftp_RCA
Config ftp server & ftp client in inventoy FTP
 
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 

3.3.21	Module Config: 21_MEM_HIGH_Util_RCA
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 

After the configuration is complete, click Launch Template to test and wait for the mission to complete:

3.3.22	Module Config: 22_MEM_OOM_RCA
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:

3.3.23	Module Config: 23_Postgresql_server_deploy
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:

3.3.24	Module Config: 24_os_PCP
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 

After the configuration is complete, click Launch Template to test and wait for the mission to complete:

3.3.25	Module Config: 25_vnc_config
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 

3.3.26	Module Config: 26_kdump_config
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 

3.3.27	Module Config: 27_cve_based_patching
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
 
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:
 

3.3.28	Module Config: 28_xfs_check
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
After the configuration is complete, click Launch Template to test and wait for the mission to complete:

3.3.29	Module Config: 29_Zombie_Process_RCA
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 

After the configuration is complete, click Launch Template to test and wait for the mission to complete:

3.3.30	Module Config: 30_Disk_IO_Pressure_RCA
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 
3.3.31	Module Config: 31_Systemd_Unit_Deep_Check
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 

After the configuration is complete, click Launch Template to test and wait for the mission to complete:

3.3.32	Module Config: 32_Privileged_Account_Audit
In the UI interface of AAP Server, the corresponding Job Template configuration is shown in the screenshot below. You can refer to it yourself:
 
Creating a Survey to adapt to your environment（customization）
 





