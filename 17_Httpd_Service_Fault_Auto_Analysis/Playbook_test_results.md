[root@aap25 17_Httpd_Service_Fault_Auto_Analysis]# ansible-playbook httpd_diagnosis_site.yml -i inventory

[DEPRECATION WARNING]: community.general.yaml has been deprecated. The plugin has been superseded by the the option `result_format=yaml` in callback plugin
ansible.builtin.default from ansible-core 2.13 onwards. This feature will be removed from community.general in version 13.0.0. Deprecation warnings can be disabled by
setting deprecation_warnings=False in ansible.cfg.

PLAY [RHEL8/9 & CentOS8/9 Httpd Service Fault Diagnosis Automation] ****************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Check OS compatibility] ******************************************************************************************************************************************
ok: [Test-RHEL-7.9-3] => changed=false
  msg: 'OS compatibility check passed: RedHat 7.9'

TASK [Validate required variables] *************************************************************************************************************************************
ok: [Test-RHEL-7.9-3] => changed=false
  msg: All required variables are defined

TASK [Initialize diagnosis status variables] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Display diagnosis start information] *****************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg:

- ═══════════════════════════════════════════════════════════════
- "\U0001F50D Starting Httpd Service Diagnosis"
- ═══════════════════════════════════════════════════════════════
- 'Target Host: Test-RHEL-7.9-3'
- 'OS: RedHat 7.9'
- 'Kernel: 3.10.0-1160.el7.x86_64'
- 'Analysis Mode: Analysis Only (No Changes)'
- ═══════════════════════════════════════════════════════════════

TASK [Collect service facts] *******************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Query httpd package] *********************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Set package installation status] *********************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Display package check result] ************************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: 'Httpd package check: Installed (httpd-2.4.6-99.el7_9.1.x86_64)'

TASK [Check service active status] *************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Set service active status] ***************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Display service active status] ***********************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: 'Httpd service active status: unknown'

TASK [Check service enabled status] ************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Set service enabled status] **************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Display service enabled status] **********************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: 'Httpd service enabled status: disabled'

TASK [Run httpd syntax check] ******************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Set syntax check result] *****************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Display syntax check result] *************************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: 'Httpd syntax check: PASSED - Syntax OK'

TASK [Get listening ports] *********************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Parse listening ports for httpd] *********************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Display port listening check result] *****************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: Port listening check completed. Check report for details.

TASK [Get SELinux mode] ************************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Set SELinux mode] ************************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Display SELinux mode] ********************************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: 'SELinux mode: Disabled'

TASK [Get SELinux boolean values] **************************************************************************************************************************************
ok: [Test-RHEL-7.9-3] => (item=httpd_can_network_connect)
ok: [Test-RHEL-7.9-3] => (item=httpd_can_network_connect_db)
ok: [Test-RHEL-7.9-3] => (item=httpd_can_sendmail)
ok: [Test-RHEL-7.9-3] => (item=httpd_use_cifs)
ok: [Test-RHEL-7.9-3] => (item=httpd_use_nfs)

TASK [Parse SELinux boolean values] ************************************************************************************************************************************
ok: [Test-RHEL-7.9-3] => (item={'changed': False, 'end': '2026-02-05 21:58:15.654877', 'stdout': '', 'cmd': ['getsebool', 'httpd_can_network_connect'], 'rc': 1, 'failed': False, 'stderr': 'getsebool:  SELinux is disabled', 'delta': '0:00:00.004140', 'invocation': {'module_args': {'executable': None, '_uses_shell': False, 'expand_argument_vars': True, 'strip_empty_ends': True, '_raw_params': 'getsebool httpd_can_network_connect', 'removes': None, 'argv': None, 'creates': None, 'chdir': None, 'stdin_add_newline': True, 'stdin': None}}, 'start': '2026-02-05 21:58:15.650737', 'msg': 'non-zero return code', 'stdout_lines': [], 'stderr_lines': ['getsebool:  SELinux is disabled'], 'failed_when_result': False, 'item': 'httpd_can_network_connect', 'ansible_loop_var': 'item'})
ok: [Test-RHEL-7.9-3] => (item={'changed': False, 'end': '2026-02-05 21:58:16.225059', 'stdout': '', 'cmd': ['getsebool', 'httpd_can_network_connect_db'], 'rc': 1, 'failed': False, 'stderr': 'getsebool:  SELinux is disabled', 'delta': '0:00:00.004062', 'invocation': {'module_args': {'executable': None, '_uses_shell': False, 'expand_argument_vars': True, 'strip_empty_ends': True, '_raw_params': 'getsebool httpd_can_network_connect_db', 'removes': None, 'argv': None, 'creates': None, 'chdir': None, 'stdin_add_newline': True, 'stdin': None}}, 'start': '2026-02-05 21:58:16.220997', 'msg': 'non-zero return code', 'stdout_lines': [], 'stderr_lines': ['getsebool:  SELinux is disabled'], 'failed_when_result': False, 'item': 'httpd_can_network_connect_db', 'ansible_loop_var': 'item'})
ok: [Test-RHEL-7.9-3] => (item={'changed': False, 'end': '2026-02-05 21:58:16.788306', 'stdout': '', 'cmd': ['getsebool', 'httpd_can_sendmail'], 'rc': 1, 'failed': False, 'stderr': 'getsebool:  SELinux is disabled', 'delta': '0:00:00.004152', 'invocation': {'module_args': {'executable': None, '_uses_shell': False, 'expand_argument_vars': True, 'strip_empty_ends': True, '_raw_params': 'getsebool httpd_can_sendmail', 'removes': None, 'argv': None, 'creates': None, 'chdir': None, 'stdin_add_newline': True, 'stdin': None}}, 'start': '2026-02-05 21:58:16.784154', 'msg': 'non-zero return code', 'stdout_lines': [], 'stderr_lines': ['getsebool:  SELinux is disabled'], 'failed_when_result': False, 'item': 'httpd_can_sendmail', 'ansible_loop_var': 'item'})
ok: [Test-RHEL-7.9-3] => (item={'changed': False, 'end': '2026-02-05 21:58:17.352913', 'stdout': '', 'cmd': ['getsebool', 'httpd_use_cifs'], 'rc': 1, 'failed': False, 'stderr': 'getsebool:  SELinux is disabled', 'delta': '0:00:00.003477', 'invocation': {'module_args': {'executable': None, '_uses_shell': False, 'expand_argument_vars': True, 'strip_empty_ends': True, '_raw_params': 'getsebool httpd_use_cifs', 'removes': None, 'argv': None, 'creates': None, 'chdir': None, 'stdin_add_newline': True, 'stdin': None}}, 'start': '2026-02-05 21:58:17.349436', 'msg': 'non-zero return code', 'stdout_lines': [], 'stderr_lines': ['getsebool:  SELinux is disabled'], 'failed_when_result': False, 'item': 'httpd_use_cifs', 'ansible_loop_var': 'item'})
ok: [Test-RHEL-7.9-3] => (item={'changed': False, 'end': '2026-02-05 21:58:17.924958', 'stdout': '', 'cmd': ['getsebool', 'httpd_use_nfs'], 'rc': 1, 'failed': False, 'stderr': 'getsebool:  SELinux is disabled', 'delta': '0:00:00.004182', 'invocation': {'module_args': {'executable': None, '_uses_shell': False, 'expand_argument_vars': True, 'strip_empty_ends': True, '_raw_params': 'getsebool httpd_use_nfs', 'removes': None, 'argv': None, 'creates': None, 'chdir': None, 'stdin_add_newline': True, 'stdin': None}}, 'start': '2026-02-05 21:58:17.920776', 'msg': 'non-zero return code', 'stdout_lines': [], 'stderr_lines': ['getsebool:  SELinux is disabled'], 'failed_when_result': False, 'item': 'httpd_use_nfs', 'ansible_loop_var': 'item'})

TASK [Display SELinux boolean check result] ****************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: SELinux boolean check completed. Check report for details.

TASK [Check firewalld state] *******************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Set firewalld running status] ************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Display firewalld status] ****************************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: 'Firewalld status: not running'

TASK [Get firewalld enabled services] **********************************************************************************************************************************
skipping: [Test-RHEL-7.9-3]

TASK [Set firewalld services] ******************************************************************************************************************************************
skipping: [Test-RHEL-7.9-3]

TASK [Display firewalld services] **************************************************************************************************************************************
skipping: [Test-RHEL-7.9-3]

TASK [Get firewalld enabled ports] *************************************************************************************************************************************
skipping: [Test-RHEL-7.9-3]

TASK [Set firewalld ports] *********************************************************************************************************************************************
skipping: [Test-RHEL-7.9-3]

TASK [Display firewalld ports] *****************************************************************************************************************************************
skipping: [Test-RHEL-7.9-3]

TASK [Check httpd.conf exists] *****************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Set httpd.conf existence] ****************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Display httpd.conf check result] *********************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: 'Httpd.conf exists: True'

TASK [Check error log file exists] *************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Read error log tail] *********************************************************************************************************************************************
skipping: [Test-RHEL-7.9-3]

TASK [Set error log content] *******************************************************************************************************************************************
skipping: [Test-RHEL-7.9-3]

TASK [Display error log check result] **********************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: Error log check completed. Check report for details.

TASK [Get journalctl logs for httpd] ***********************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Set journalctl content] ******************************************************************************************************************************************
ok: [Test-RHEL-7.9-3]

TASK [Display journalctl check result] *********************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: Journalctl check completed. Check report for details.

TASK [Attempt to start httpd service] **********************************************************************************************************************************
skipping: [Test-RHEL-7.9-3]

TASK [Display service start attempt result] ****************************************************************************************************************************
skipping: [Test-RHEL-7.9-3]

TASK [Generate diagnostic report] **************************************************************************************************************************************
changed: [Test-RHEL-7.9-3]

TASK [Display report generation success] *******************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg: '✅ Diagnostic report generated successfully: /root/httpd_diagnosis_report.txt'

TASK [Display diagnosis summary] ***************************************************************************************************************************************
ok: [Test-RHEL-7.9-3] =>
  msg:

- ═══════════════════════════════════════════════════════════════
- "\U0001F3AF HTTPD SERVICE DIAGNOSIS SUMMARY"
- ═══════════════════════════════════════════════════════════════
- "\U0001F4CB Diagnosis Status:"
- '   • Package Installed: ✅ Yes'
- '   • Service Active: unknown'
- '   • Service Enabled: disabled'
- '   • Syntax Check: ✅ PASSED'
- '   • SELinux Mode: Disabled'
- '   • Firewalld Running: ❌ No'
- ''
- ✅ No critical errors
- ✅ No warnings
- ''
- "\U0001F4DD Report Location: /root/httpd_diagnosis_report.txt"
- ''
- "\U0001F4DD Next Steps:"
- '   • Review the generated diagnostic report'
- '   • Address any identified issues based on recommendations'
- '   • Check service logs for detailed error information'
- ═══════════════════════════════════════════════════════════════

PLAY RECAP *************************************************************************************************************************************************************
Test-RHEL-7.9-3            : ok=41   changed=1    unreachable=0    failed=0    skipped=10   rescued=0    ignored=0
