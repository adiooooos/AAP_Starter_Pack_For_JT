[root@aap25 04_YUM_config]# more inventory
[server]
TEST-RHEL-8.9-1

[client]
10.66.208.248

[root@aap25 04_YUM_config]# ansible-playbook yum_repo_deployment.yml -i inventory

PLAY [Setup the remote yum repo server] *******************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************
ok: [TEST-RHEL-8.9-1]

TASK [Validate OS compatibility (RHEL 8/9 only)] **********************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "changed": false,
    "msg": "OS compatibility check passed: RedHat 8"
}

TASK [Display OS information for debugging] ***************************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": [
        "Distribution: RedHat",
        "Version: 8.7",
        "Major Version: 8",
        "Architecture: x86_64"
    ]
}

TASK [Include server deployment tasks] ********************************************************************************************************************************
included: /home/admin/aap/controller/data/projects/starter_pack/04_YUM_config/yum_repo_server_tasks.yml for TEST-RHEL-8.9-1

TASK [Gathering the package facts] ************************************************************************************************************************************
ok: [TEST-RHEL-8.9-1]

TASK [Display package facts status for debugging] *********************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": "Package facts gathered successfully"
}

TASK [Verify httpd existing] ******************************************************************************************************************************************
fatal: [TEST-RHEL-8.9-1]: FAILED! => {
    "msg": "Failure the task when httpd package not installed (with protocol = http(s)), please install httpd and re-run the playbook."
}

PLAY RECAP ************************************************************************************************************************************************************
TEST-RHEL-8.9-1            : ok=6    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0

[root@aap25 04_YUM_config]# ansible-playbook yum_repo_deployment.yml -i inventory

PLAY [Setup the remote yum repo server] *******************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************
ok: [TEST-RHEL-8.9-1]

TASK [Validate OS compatibility (RHEL 8/9 only)] **********************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "changed": false,
    "msg": "OS compatibility check passed: RedHat 8"
}

TASK [Display OS information for debugging] ***************************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": [
        "Distribution: RedHat",
        "Version: 8.7",
        "Major Version: 8",
        "Architecture: x86_64"
    ]
}

TASK [Include server deployment tasks] ********************************************************************************************************************************
included: /home/admin/aap/controller/data/projects/starter_pack/04_YUM_config/yum_repo_server_tasks.yml for TEST-RHEL-8.9-1

TASK [Gathering the package facts] ************************************************************************************************************************************
ok: [TEST-RHEL-8.9-1]

TASK [Display package facts status for debugging] *********************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": "Package facts gathered successfully"
}

TASK [Verify httpd existing] ******************************************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": "Failure the task when httpd package not installed (with protocol = http(s)), please install httpd and re-run the playbook."
}

TASK [Verify vsftpd existing] *****************************************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": "Failure the task when vsftpd package not installed (with protocol = ftp), please install vsftpd and re-run the playbook."
}

TASK [Display prerequisite verification result for debugging] *********************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": [
        "Protocol: http",
        "HTTPD installed: True",
        "VSFTPD installed: False"
    ]
}

TASK [Make sure document root existing] *******************************************************************************************************************************
ok: [TEST-RHEL-8.9-1]

TASK [Display document root status for debugging] *********************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": "Document root directory: /var/www/html/"
}

TASK [Make sure mountPath existing] ***********************************************************************************************************************************
changed: [TEST-RHEL-8.9-1]

TASK [Display mount path status for debugging] ************************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": "Mount path directory: /mnt/RHEL-8.10/RedHatEnterpriseLinux/x86_64"
}

TASK [Mount ISO read-only] ********************************************************************************************************************************************
changed: [TEST-RHEL-8.9-1]

TASK [Display mount result for debugging] *****************************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": [
        "ISO mounted: True",
        "Mount point: /mnt/RHEL-8.10/RedHatEnterpriseLinux/x86_64",
        "ISO source: /data/rhel-8.10-x86_64-dvd.iso"
    ]
}

TASK [Create subfolder under http root path] **************************************************************************************************************************
changed: [TEST-RHEL-8.9-1]

TASK [Display repository path for debugging] **************************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": "Repository path: /var/www/html//RHEL-8.10/RedHatEnterpriseLinux/x86_64"
}

TASK [Copy repo files] ************************************************************************************************************************************************
changed: [TEST-RHEL-8.9-1]

TASK [Display synchronization result for debugging] *******************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": [
        "Synchronization completed: True",
        "Source: /mnt/RHEL-8.10/RedHatEnterpriseLinux/x86_64/",
        "Destination: /var/www/html//RHEL-8.10/RedHatEnterpriseLinux/x86_64"
    ]
}

TASK [Unmount ISO] ****************************************************************************************************************************************************
changed: [TEST-RHEL-8.9-1]

TASK [Display unmount status for debugging] ***************************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": "ISO unmounted: True"
}

TASK [Restart service httpd, in all cases] ****************************************************************************************************************************
changed: [TEST-RHEL-8.9-1]

TASK [Display httpd service status for debugging] *********************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": [
        "HTTPD service restarted: True",
        "HTTPD service state: N/A"
    ]
}

TASK [Restart service vsftpd, in all cases] ***************************************************************************************************************************
skipping: [TEST-RHEL-8.9-1]

TASK [Display vsftpd service status for debugging] ********************************************************************************************************************
skipping: [TEST-RHEL-8.9-1]

TASK [Apply httpd SELinux file context to filesystem] *****************************************************************************************************************
changed: [TEST-RHEL-8.9-1]

TASK [Display SELinux context result for debugging] *******************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": "SELinux context applied for httpd: /var/www/html//RHEL-8.10/RedHatEnterpriseLinux/x86_64"
}

TASK [Apply vsftpd SELinux file context to filesystem] ****************************************************************************************************************
skipping: [TEST-RHEL-8.9-1]

TASK [Display SELinux FTP context result for debugging] ***************************************************************************************************************
skipping: [TEST-RHEL-8.9-1]

TASK [Display completion summary] *************************************************************************************************************************************
ok: [TEST-RHEL-8.9-1] => {
    "msg": [
        "YUM repository server setup completed",
        "Repository URL: http://TEST-RHEL-8.9-1/RHEL-8.10/RedHatEnterpriseLinux/x86_64",
        "Document Root: /var/www/html//RHEL-8.10/RedHatEnterpriseLinux/x86_64"
    ]
}

PLAY [Setup the remote yum repo client] *******************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************
ok: [10.66.208.248]

TASK [Validate OS compatibility (RHEL 8/9 only)] **********************************************************************************************************************
ok: [10.66.208.248] => {
    "changed": false,
    "msg": "OS compatibility check passed: RedHat 8"
}

TASK [Display OS information for debugging] ***************************************************************************************************************************
ok: [10.66.208.248] => {
    "msg": [
        "Distribution: RedHat",
        "Version: 8.10",
        "Major Version: 8",
        "Architecture: x86_64"
    ]
}

TASK [Include client configuration tasks] *****************************************************************************************************************************
included: /home/admin/aap/controller/data/projects/starter_pack/04_YUM_config/yum_repo_client_tasks.yml for 10.66.208.248

TASK [Add repositories for release >= RHEL-8.0] ***********************************************************************************************************************
changed: [10.66.208.248] => (item={'name': 'remote-repo-baseos-8.1', 'baseurl': 'http://TEST-RHEL-8.9-1/RHEL-8.10/RedHatEnterpriseLinux/x86_64/BaseOS', 'description': 'Remote Repository BaseOS 8.1'})
changed: [10.66.208.248] => (item={'name': 'remote-repo-appstream-8.1', 'baseurl': 'http://TEST-RHEL-8.9-1/RHEL-8.10/RedHatEnterpriseLinux/x86_64/AppStream', 'description': 'Remote Repository AppStream 8.1'})

TASK [Display repository configuration result for debugging] **********************************************************************************************************
ok: [10.66.208.248] => {
    "msg": [
        "Repositories configured: 2",
        "Repository file: /etc/yum.repos.d/remote_repo_8.1-http.repo",
        "Repository server: TEST-RHEL-8.9-1",
        "Protocol: http"
    ]
}

TASK [Clean YUM cache] ************************************************************************************************************************************************
changed: [10.66.208.248]

TASK [Display YUM cache clean result for debugging] *******************************************************************************************************************
ok: [10.66.208.248] => {
    "msg": "YUM cache cleaned successfully"
}

TASK [Verify repository accessibility] ********************************************************************************************************************************
ok: [10.66.208.248]

TASK [Display repository list for debugging] **************************************************************************************************************************
ok: [10.66.208.248] => {
    "msg": [
        "Updating Subscription Management repositories.",
        "Unable to read consumer identity",
        "",
        "This system is not registered with an entitlement server. You can use subscription-manager to register.",
        "",
        "repo id                              repo name",
        "remote-repo-appstream-8.1            Remote Repository AppStream 8.1",
        "remote-repo-baseos-8.1               Remote Repository BaseOS 8.1"
    ]
}

TASK [Display completion summary] *************************************************************************************************************************************
ok: [10.66.208.248] => {
    "msg": [
        "YUM repository client configuration completed",
        "Repository file: /etc/yum.repos.d/remote_repo_8.1-http.repo",
        "Repository server: TEST-RHEL-8.9-1",
        "Protocol: http",
        "Release: 8.1"
    ]
}

PLAY RECAP ************************************************************************************************************************************************************
10.66.208.248              : ok=11   changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
TEST-RHEL-8.9-1            : ok=26   changed=7    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0

##yum client test results


[root@unused yum.repos.d]# yum repolist
Updating Subscription Management repositories.
Unable to read consumer identity

This system is not registered with an entitlement server. You can use subscription-manager to register.

repo id                                                                          repo name
remote-repo-appstream-8.1                                                        Remote Repository AppStream 8.1
remote-repo-baseos-8.1                                                           Remote Repository BaseOS 8.1
[root@unused yum.repos.d]#
[root@unused yum.repos.d]#
[root@unused yum.repos.d]# yum search vim
Updating Subscription Management repositories.
Unable to read consumer identity

This system is not registered with an entitlement server. You can use subscription-manager to register.

Remote Repository BaseOS 8.1                                                                                                           1.8 MB/s | 2.4 MB     00:01
Remote Repository AppStream 8.1                                                                                                        3.9 MB/s | 7.5 MB     00:01
Last metadata expiration check: 0:00:01 ago on Tue 03 Feb 2026 06:45:49 PM CST.
===================================================================== Name & Summary Matched: vim =====================================================================
vim-X11.x86_64 : The VIM version of the vi editor for the X Window System - GVim
vim-common.x86_64 : The common files needed by any version of the VIM editor
vim-enhanced.x86_64 : A version of the VIM editor which includes recent enhancements
vim-filesystem.noarch : VIM filesystem layout
vim-minimal.x86_64 : A minimal version of the VIM editor
