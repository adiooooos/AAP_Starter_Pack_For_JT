[root@aap25 18_Nginx_RCA]# ansible-playbook nginx_diagnosis_site.yml -i inventory
[DEPRECATION WARNING]: community.general.yaml has been deprecated. The plugin has been superseded by the the option `result_format=yaml` in callback plugin
ansible.builtin.default from ansible-core 2.13 onwards. This feature will be removed from community.general in version 13.0.0. Deprecation warnings can be disabled by
setting deprecation_warnings=False in ansible.cfg.

PLAY [RHEL7/8/9 & CentOS7/8/9 Nginx Service Fault Automatic Diagnosis] *************************************************************************************************

TASK [Assert supported operating system (RHEL/CentOS 7/8/9 only)] ******************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Assert required variables are defined] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Debug OS and baseline variables] *********************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:
    http_ports:
    - 80
    https_ports:
    - 443
    nginx_package: nginx
    nginx_service: nginx
    os_distribution: RedHat
    os_version: '7.9'
    report_output_path: /root/nginx_diagnosis_report.txt

TASK [Collect SELinux mode (non-fatal)] ********************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Collect SELinux booleans (non-fatal)] ****************************************************************************************************************************
ok: [Test-RHEL-7.9-1] => (item=httpd_can_network_connect)
ok: [Test-RHEL-7.9-1] => (item=httpd_can_network_connect_db)
ok: [Test-RHEL-7.9-1] => (item=httpd_can_sendmail)
ok: [Test-RHEL-7.9-1] => (item=httpd_use_cifs)
ok: [Test-RHEL-7.9-1] => (item=httpd_use_nfs)

TASK [Debug SELinux information] ***************************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:
    selinux_booleans_raw:
    - ansible_loop_var: item
      changed: false
      cmd:
      - getsebool
      - httpd_can_network_connect
      delta: '0:00:00.004280'
      end: '2026-02-05 16:54:56.124301'
      failed: false
      failed_when_result: false
      invocation:
        module_args:
          _raw_params: getsebool httpd_can_network_connect
          _uses_shell: false
          argv: null
          chdir: null
          creates: null
          executable: null
          expand_argument_vars: true
          removes: null
          stdin: null
          stdin_add_newline: true
          strip_empty_ends: true
      item: httpd_can_network_connect
      msg: non-zero return code
      rc: 1
      start: '2026-02-05 16:54:56.120021'
      stderr: 'getsebool:  SELinux is disabled'
      stderr_lines:
      - 'getsebool:  SELinux is disabled'
      stdout: ''
      stdout_lines: []
    - ansible_loop_var: item
      changed: false
      cmd:
      - getsebool
      - httpd_can_network_connect_db
      delta: '0:00:00.004330'
      end: '2026-02-05 16:54:56.672088'
      failed: false
      failed_when_result: false
      invocation:
        module_args:
          _raw_params: getsebool httpd_can_network_connect_db
          _uses_shell: false
          argv: null
          chdir: null
          creates: null
          executable: null
          expand_argument_vars: true
          removes: null
          stdin: null
          stdin_add_newline: true
          strip_empty_ends: true
      item: httpd_can_network_connect_db
      msg: non-zero return code
      rc: 1
      start: '2026-02-05 16:54:56.667758'
      stderr: 'getsebool:  SELinux is disabled'
      stderr_lines:
      - 'getsebool:  SELinux is disabled'
      stdout: ''
      stdout_lines: []
    - ansible_loop_var: item
      changed: false
      cmd:
      - getsebool
      - httpd_can_sendmail
      delta: '0:00:00.004551'
      end: '2026-02-05 16:54:57.206983'
      failed: false
      failed_when_result: false
      invocation:
        module_args:
          _raw_params: getsebool httpd_can_sendmail
          _uses_shell: false
          argv: null
          chdir: null
          creates: null
          executable: null
          expand_argument_vars: true
          removes: null
          stdin: null
          stdin_add_newline: true
          strip_empty_ends: true
      item: httpd_can_sendmail
      msg: non-zero return code
      rc: 1
      start: '2026-02-05 16:54:57.202432'
      stderr: 'getsebool:  SELinux is disabled'
      stderr_lines:
      - 'getsebool:  SELinux is disabled'
      stdout: ''
      stdout_lines: []
    - ansible_loop_var: item
      changed: false
      cmd:
      - getsebool
      - httpd_use_cifs
      delta: '0:00:00.004035'
      end: '2026-02-05 16:54:57.747207'
      failed: false
      failed_when_result: false
      invocation:
        module_args:
          _raw_params: getsebool httpd_use_cifs
          _uses_shell: false
          argv: null
          chdir: null
          creates: null
          executable: null
          expand_argument_vars: true
          removes: null
          stdin: null
          stdin_add_newline: true
          strip_empty_ends: true
      item: httpd_use_cifs
      msg: non-zero return code
      rc: 1
      start: '2026-02-05 16:54:57.743172'
      stderr: 'getsebool:  SELinux is disabled'
      stderr_lines:
      - 'getsebool:  SELinux is disabled'
      stdout: ''
      stdout_lines: []
    - ansible_loop_var: item
      changed: false
      cmd:
      - getsebool
      - httpd_use_nfs
      delta: '0:00:00.004056'
      end: '2026-02-05 16:54:58.287725'
      failed: false
      failed_when_result: false
      invocation:
        module_args:
          _raw_params: getsebool httpd_use_nfs
          _uses_shell: false
          argv: null
          chdir: null
          creates: null
          executable: null
          expand_argument_vars: true
          removes: null
          stdin: null
          stdin_add_newline: true
          strip_empty_ends: true
      item: httpd_use_nfs
      msg: non-zero return code
      rc: 1
      start: '2026-02-05 16:54:58.283669'
      stderr: 'getsebool:  SELinux is disabled'
      stderr_lines:
      - 'getsebool:  SELinux is disabled'
      stdout: ''
      stdout_lines: []
    selinux_mode: Disabled
    selinux_rc: '0'

TASK [Gather service facts (non-fatal)] ********************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Check if nginx package is installed (rpm -q)] ********************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Check nginx active state (systemctl is-active)] ******************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Check nginx enabled state (systemctl is-enabled)] ****************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Debug package and service status] ********************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:
    nginx_package_installed: 'yes'
    nginx_service_active: active
    nginx_service_enabled: enabled
    rpm_query_rc: '0'
    svc_active_rc: '0'
    svc_enabled_rc: '0'

TASK [Validate nginx configuration syntax (nginx -t)] ******************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Check nginx.conf existence] **************************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Check nginx config directory permissions] ************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Check nginx work directory permissions] **************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Check nginx website directory permissions] ***********************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Debug configuration and directory checks] ************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:
    nginx_conf_dir_mode: '0755'
    nginx_conf_exists: true
    nginx_t_output: |-
      nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
      nginx: configuration file /etc/nginx/nginx.conf test is successful
    nginx_t_rc: '0'
    nginx_website_dir_mode: '0755'
    nginx_work_dir_mode: '0770'

TASK [Build expected nginx ports list] *********************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Collect listening sockets (ss -lntp)] ****************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Check firewalld state (if present)] ******************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [List firewalld allowed services (non-fatal)] *********************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [List firewalld open ports (non-fatal)] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Debug ports and firewall state] **********************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:
    expected_ports:
    - 80
    - 443
    firewalld_ports: ''
    firewalld_services: ''
    firewalld_state: unknown
    ss_rc: '0'

TASK [Optionally attempt to start nginx service (non-fatal)] ***********************************************************************************************************
skipping: [Test-RHEL-7.9-1]

TASK [Debug nginx start attempt result] ********************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:
    attempt_service_start: false
    nginx_start_changed: false
    nginx_start_failed: false

TASK [Collect nginx error log tail (if path is defined)] ***************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Collect nginx access log tail (if path is defined)] **************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Collect recent journal entries for nginx service] ****************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Debug log and journal collection status] *************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:
    access_log_collected: true
    error_log_collected: true
    journal_rc: '0'

TASK [Render consolidated Nginx diagnosis report] **********************************************************************************************************************
changed: [Test-RHEL-7.9-1]

TASK [Debug final report path] *****************************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: 'Nginx diagnosis report has been generated at: /root/nginx_diagnosis_report.txt'

PLAY RECAP *************************************************************************************************************************************************************
Test-RHEL-7.9-1            : ok=30   changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
