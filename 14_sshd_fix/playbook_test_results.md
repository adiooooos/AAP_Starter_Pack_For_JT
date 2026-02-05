[root@aap25 14_sshd_fix]# ansible-playbook -i inventory ssh_connection_auto_fix_site.yml  -C

PLAY [SSH connection troubleshooting and auto‑remediation] *******************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Validate OS compatibility (RHEL/CentOS 7/8/9 only)] ********************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Validate required variables are defined] *******************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Check hosts file path existence] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Check SSH host keys directory existence] *******************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Assert paths for hosts file and SSH host keys are valid] ***************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Show validated input parameters] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": [
        "Target hostname: Test-RHEL-7.9-2",
        "Short name: Test-RHEL-7.9-2",
        "Hosts file path: /etc/hosts",
        "SSH host keys directory: /etc/ssh",
        "Report directory (planned): /tmp/ssh_network_fix_20260204_172949",
        "SSH service: sshd, port: 22"
    ]
}

TASK [Gather basic networking and hardware facts] ****************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Debug collected IP and hostname] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": [
        "Detected hostname: test-rhel-7",
        "Primary IP address: 10.71.18.251"
    ]
}

TASK [Create report directory] ***********************************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Confirm report directory] **********************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": "Report directory created at /tmp/ssh_network_fix_20260204_172959"
}

TASK [Run initial DNS resolution test] ***************************************************************************************************************************
skipping: [Test-RHEL-7.9-2]

TASK [Show initial DNS resolution result] ************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": "Initial DNS resolution for Test-RHEL-7.9-2: SUCCESS\n"
}

TASK [Check existing hosts file entries for target hostname] *****************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Add DNS entry to hosts file when needed] *******************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Run DNS resolution test after hosts file adjustment] *******************************************************************************************************
skipping: [Test-RHEL-7.9-2]

TASK [Show post‑fix DNS resolution result] ***********************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": "Post‑fix DNS resolution for Test-RHEL-7.9-2: SUCCESS\n"
}

TASK [Collect service facts] *************************************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Ensure SSH service is running and enabled] *****************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Verify SSH listening port] *********************************************************************************************************************************
skipping: [Test-RHEL-7.9-2]

TASK [Debug SSH service and port status] *************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": [
        "SSH service state: running",
        "SSH port check output: "
    ]
}

TASK [Collect SSH host key fingerprints (SHA256)] ****************************************************************************************************************
skipping: [Test-RHEL-7.9-2]

TASK [Collect SSH host key fingerprints (MD5 – legacy clients)] **************************************************************************************************
skipping: [Test-RHEL-7.9-2]

TASK [Show collected SSH host key fingerprints] ******************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": [
        "SSH host key fingerprints (SHA256):",
        "",
        "SSH host key fingerprints (MD5):",
        ""
    ]
}

TASK [Inspect network interfaces status] *************************************************************************************************************************
skipping: [Test-RHEL-7.9-2]

TASK [Re‑collect service facts for firewall check] ***************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Inspect firewall port configuration (if firewalld is running)] *********************************************************************************************
skipping: [Test-RHEL-7.9-2]

TASK [Debug network connectivity and firewall information] *******************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": [
        "Network interfaces summary:",
        "",
        "Firewalld state: inactive",
        "Firewall ports:  no firewall port data (service stopped or command failed or firewalld not running) \n"
    ]
}

TASK [Generate DNS diagnostics report] ***************************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Generate SSH service status report] ************************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Generate network connectivity report] **********************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Generate client‑side remediation instructions] *************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Create SSH network monitoring script] **********************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Generate remediation summary report] ***********************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Display final remediation summary] *************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": "SSH network troubleshooting and remediation completed.\n\nResult summary:\n- DNS resolution: ✅ OK\n- SSH service: ✅ OK\n\nReport directory: /tmp/sshork_fix_20260204_172959\nImportant files:\n  - Remediation summary: /tmp/ssh_network_fix_20260204_172959/fix_summary.txt\n  - Client guidance: /tmp/ssh_network_fi60204_172959/client_fix_instructions.txt\n  - Monitoring script: /tmp/ssh_network_fix_20260204_172959/monitor_ssh_network.sh\n"
}

PLAY RECAP *******************************************************************************************************************************************************
Test-RHEL-7.9-2            : ok=28   changed=8    unreachable=0    failed=0    skipped=7    rescued=0    ignored=0

[root@aap25 14_sshd_fix]#
[root@aap25 14_sshd_fix]#
[root@aap25 14_sshd_fix]# ansible-playbook -i inventory ssh_connection_auto_fix_site.yml

PLAY [SSH connection troubleshooting and auto‑remediation] *******************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Validate OS compatibility (RHEL/CentOS 7/8/9 only)] ********************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Validate required variables are defined] *******************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Check hosts file path existence] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Check SSH host keys directory existence] *******************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Assert paths for hosts file and SSH host keys are valid] ***************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Show validated input parameters] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": [
        "Target hostname: Test-RHEL-7.9-2",
        "Short name: Test-RHEL-7.9-2",
        "Hosts file path: /etc/hosts",
        "SSH host keys directory: /etc/ssh",
        "Report directory (planned): /tmp/ssh_network_fix_20260204_173838",
        "SSH service: sshd, port: 22"
    ]
}

TASK [Gather basic networking and hardware facts] ****************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Debug collected IP and hostname] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": [
        "Detected hostname: test-rhel-7",
        "Primary IP address: 10.71.18.251"
    ]
}

TASK [Create report directory] ***********************************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Confirm report directory] **********************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": "Report directory created at /tmp/ssh_network_fix_20260204_173848"
}

TASK [Run initial DNS resolution test] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Show initial DNS resolution result] ************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": "Initial DNS resolution for Test-RHEL-7.9-2: FAILED\n"
}

TASK [Check existing hosts file entries for target hostname] *****************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Add DNS entry to hosts file when needed] *******************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Run DNS resolution test after hosts file adjustment] *******************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Show post‑fix DNS resolution result] ***********************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": "Post‑fix DNS resolution for Test-RHEL-7.9-2: FAILED\n"
}

TASK [Collect service facts] *************************************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Ensure SSH service is running and enabled] *****************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Verify SSH listening port] *********************************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Debug SSH service and port status] *************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": [
        "SSH service state: running",
        "SSH port check output: "
    ]
}

TASK [Collect SSH host key fingerprints (SHA256)] ****************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Collect SSH host key fingerprints (MD5 – legacy clients)] **************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Show collected SSH host key fingerprints] ******************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": [
        "SSH host key fingerprints (SHA256):",
        "ecdsa: 256 SHA256:02EkQRyE/k3zgU9SyWnnIiTB51bKbCvoso4CqSVgWz0 no comment (ECDSA)\ned25519: 256 SHA256:7WEcf+gYVmr6gBW0acuQWgmYI0NvHHy1qa+zgZRyd3M no comment (ED25519)\nrsa: 2048 SHA256:1V4wJH+LSqAe83Nmkm60FdNG5iFIc/fDMfHGAcX0dA8 no comment (RSA)",
        "SSH host key fingerprints (MD5):",
        "ecdsa: 256 MD5:ce:96:61:c0:dc:0a:0c:9c:1e:7c:9e:72:36:e1🇩🇪a6 no comment (ECDSA)\ned25519: 256 MD5:8b:a1:97:c9:79:aa:6f:65:d8:d6:94:4c:97:f3:ee:08 no comment (ED25519)\nrsa: 2048 MD5:23:c8:07:53:43:da:fa:d5:7d:be:ba:48:d2:f1:f7:8a no comment (RSA)"
    ]
}

TASK [Inspect network interfaces status] *************************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Re‑collect service facts for firewall check] ***************************************************************************************************************
ok: [Test-RHEL-7.9-2]

TASK [Inspect firewall port configuration (if firewalld is running)] *********************************************************************************************
skipping: [Test-RHEL-7.9-2]

TASK [Debug network connectivity and firewall information] *******************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": [
        "Network interfaces summary:",
        "    inet 10.71.18.251/23 brd 10.71.19.255 scope global noprefixroute ens192\n    inet6 2620:52:0:4712:90e:72ec:ed2a:f2e2/64 scope global noprefixroute dynamic ",
        "Firewalld state: inactive",
        "Firewall ports:  no firewall port data (service stopped or command failed or firewalld not running) \n"
    ]
}

TASK [Generate DNS diagnostics report] ***************************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Generate SSH service status report] ************************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Generate network connectivity report] **********************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Generate client‑side remediation instructions] *************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Create SSH network monitoring script] **********************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Generate remediation summary report] ***********************************************************************************************************************
changed: [Test-RHEL-7.9-2]

TASK [Display final remediation summary] *************************************************************************************************************************
ok: [Test-RHEL-7.9-2] => {
    "msg": "SSH network troubleshooting and remediation completed.\n\nResult summary:\n- DNS resolution: ⚠️ Needs investigation\n- SSH service: ✅ OK\n\nReport directory: /tmp/ssh_network_fix_20260204_173848\nImportant files:\n  - Remediation summary: /tmp/ssh_network_fix_20260204_173848/fix_summary.txt\n  - Client guidance: /tmp/ssh_network_fix_20260204_173848/client_fix_instructions.txt\n  - Monitoring script: /tmp/ssh_network_fix_20260204_173848/monitor_ssh_network.sh\n"
}

PLAY RECAP *******************************************************************************************************************************************************
Test-RHEL-7.9-2            : ok=34   changed=8    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
