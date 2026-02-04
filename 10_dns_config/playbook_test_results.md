PLAY [Deploy and configure Unbound caching DNS servers] ***************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Validate OS compatibility (RHEL/CentOS 7/8/9)] ******************************************************************************************************************
ok: [Test-RHEL-7.9-1] => changed=false
  msg: 'OS compatibility check passed: RedHat 7'

TASK [Show host facts for debugging] **********************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- 'Host: Test-RHEL-7.9-1'
- 'OS: RedHat 7.9'

TASK [unbound_caching_dns : Validate required variables] **************************************************************************************************************
ok: [Test-RHEL-7.9-1] => changed=false
  msg: All assertions passed

TASK [unbound_caching_dns : Display Unbound role configuration for debugging] *****************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- 'unbound_packages: [''unbound'']'
- 'unbound_config_dest: /etc/unbound/conf.d/ansible_generated.conf'
- 'unbound_allowed_networks: [''172.25.0.0/6'', ''192.168.62.0/24'']'
- 'unbound_insecure_domain: pvt.example.com'
- 'unbound_forwarder_ip: 172.25.254.254'

TASK [unbound_caching_dns : Ensure Unbound packages are installed (bulk)] *********************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [unbound_caching_dns : Ensure Unbound configuration is present from template] ************************************************************************************
changed: [Test-RHEL-7.9-1]

TASK [unbound_caching_dns : Verify Unbound configuration file exists] *************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [unbound_caching_dns : Display Unbound configuration file status for debugging] **********************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- 'Config file exists: False'
- 'Config file size: n/a'

TASK [unbound_caching_dns : Ensure Unbound service is enabled and started] ********************************************************************************************
changed: [Test-RHEL-7.9-1]

TASK [unbound_caching_dns : Ensure firewalld allows DNS service] ******************************************************************************************************
fatal: [Test-RHEL-7.9-1]: FAILED! => changed=false
  msg: firewall is not currently running, unable to perform immediate actions without a running firewall daemon

TASK [unbound_caching_dns : Report firewalld configuration warning] ***************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- 'Warning: firewalld configuration failed.'
- If firewalld is not installed/enabled, you can set unbound_manage_firewall=false.

RUNNING HANDLER [unbound_caching_dns : Restart unbound] ***************************************************************************************************************
changed: [Test-RHEL-7.9-1]

PLAY RECAP ************************************************************************************************************************************************************
Test-RHEL-7.9-1            : ok=12   changed=3    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
