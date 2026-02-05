[root@aap25 16_Network_Fault_Diagnosis]# ansible-playbook network_diagnosis_site.yml -i inventory
[DEPRECATION WARNING]: community.general.yaml has been deprecated. The plugin has been superseded by the the option `result_format=yaml` in callback plugin
ansible.builtin.default from ansible-core 2.13 onwards. This feature will be removed from community.general in version 13.0.0. Deprecation warnings can be disabled by
setting deprecation_warnings=False in ansible.cfg.

PLAY [RHEL Network Latency Diagnosis Automation] ***********************************************************************************************************************

TASK [Check OS compatibility] ******************************************************************************************************************************************
ok: [Test-RHEL-7.9-1] => changed=false
  msg: 'OS compatibility check passed: RedHat 7.9'

TASK [Record analysis start time] **************************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Display analysis start information] ******************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- 'Starting network latency diagnosis for: Test-RHEL-7.9-1'
- 'OS: RedHat 7.9'
- 'Hostname: test-rhel-7'
- 'Analysis started at: 2026-02-05T03:51:31Z'

TASK [Validate required variables] *************************************************************************************************************************************
ok: [Test-RHEL-7.9-1] => changed=false
  msg: All required variables are defined

TASK [network_interface : Initialize network interface check status] ***************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [network_interface : Check network interface status] **************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [network_interface : Parse interface status information] **********************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [network_interface : Display interface status check result] *******************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: Network interface ens192 status check succeeded

TASK [network_interface : Get interface statistics] ********************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [network_interface : Parse error packet statistics] ***************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [network_interface : Display statistics check result] *************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: Interface statistics check succeeded

TASK [network_interface : Get IP address information] ******************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [network_interface : Parse IP address] ****************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [network_interface : Display IP address check result] *************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: IP address check succeeded

TASK [network_interface : Report network interface check summary] ******************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- === Network Interface Check Summary ===
- 'Interface: ens192'
- '✅ Interface Status: UP'
- 'MTU: 1500'
- 'IP Address: 10.71.19.192'
- 'Receive Errors: 0'
- 'Transmit Errors: 0'
- 'Receive Dropped: 0'
- 'Transmit Dropped: 0'
- ✅ All network interface checks completed

TASK [system_diagnosis : Initialize system diagnosis status] ***********************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [system_diagnosis : Check TCP connection statistics] **************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [system_diagnosis : Parse TCP retransmit statistics] **************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [system_diagnosis : Display TCP stats check result] ***************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: TCP statistics check succeeded

TASK [system_diagnosis : Check system logs for network-related keywords] ***********************************************************************************************
ok: [Test-RHEL-7.9-1] => (item=bnx2x)
ok: [Test-RHEL-7.9-1] => (item=e1000)
ok: [Test-RHEL-7.9-1] => (item=igb)
ok: [Test-RHEL-7.9-1] => (item=ixgbe)
ok: [Test-RHEL-7.9-1] => (item=network)
ok: [Test-RHEL-7.9-1] => (item=ethtool)
ok: [Test-RHEL-7.9-1] => (item=link)
ok: [Test-RHEL-7.9-1] => (item=carrier)

TASK [system_diagnosis : Aggregate system log information] *************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [system_diagnosis : Display system logs check result] *************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: System logs check completed

TASK [system_diagnosis : Check system load] ****************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [system_diagnosis : Store system load output] *********************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [system_diagnosis : Display system load check result] *************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: System load check succeeded

TASK [system_diagnosis : Check memory usage] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [system_diagnosis : Store memory usage output] ********************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [system_diagnosis : Display memory usage check result] ************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: Memory usage check succeeded

TASK [system_diagnosis : Report system diagnosis summary] **************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- === System Diagnosis Summary ===
- 'TCP Retransmit: 0'
- 'System Load:  12:32:36 up 209 days, 20:53,  2 users,  load average: 0.00, 0.01, 0.05'
- 'Memory Usage: Mem:           3.7G        222M        1.8G        184M        1.6G        3.0G'
- 'Network Log Entries Found: Yes'
- ✅ All system diagnosis checks completed

TASK [traffic_capture : Initialize traffic capture status] *************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [traffic_capture : Check if tcpdump is available] *****************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [traffic_capture : Install tcpdump if not installed] **************************************************************************************************************
skipping: [Test-RHEL-7.9-1]

TASK [traffic_capture : Update tcpdump installation status] ************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [traffic_capture : Display tcpdump installation result] ***********************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: tcpdump already installed

TASK [traffic_capture : Create traffic capture directory] **************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [traffic_capture : Display directory creation result] *************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: Traffic capture directory created

TASK [traffic_capture : Start traffic capture] *************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [traffic_capture : Store capture file path] ***********************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [traffic_capture : Wait for traffic capture to complete] **********************************************************************************************************
FAILED - RETRYING: [Test-RHEL-7.9-1]: Wait for traffic capture to complete (3 retries left).
FAILED - RETRYING: [Test-RHEL-7.9-1]: Wait for traffic capture to complete (2 retries left).
FAILED - RETRYING: [Test-RHEL-7.9-1]: Wait for traffic capture to complete (1 retries left).
ok: [Test-RHEL-7.9-1]

TASK [traffic_capture : Display traffic capture result] ****************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: Traffic capture started

TASK [traffic_capture : Report traffic capture summary] ****************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- === Traffic Capture Summary ===
- 'Traffic Capture: Enabled'
- ✅ tcpdump installed
- 'Capture File: /var/tmp/packet_capture_Test-RHEL-7.9-1_1770263491.pcap'
- ✅ Traffic capture tasks completed

TASK [report_generation : Initialize report generation status] *********************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [report_generation : Create report directory] *********************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [report_generation : Display directory creation result] ***********************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: Report directory created

TASK [report_generation : Generate network latency analysis report] ****************************************************************************************************
changed: [Test-RHEL-7.9-1]

TASK [report_generation : Update report creation status] ***************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [report_generation : Display report generation result] ************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: Report generation succeeded

TASK [report_generation : Display report location] *********************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg: 'Network latency analysis report generated: /tmp/network_analysis_reports/network_analysis_Test-RHEL-7.9-1_1770263491.txt'

TASK [report_generation : Display report content preview] **************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [report_generation : Output report preview] ***********************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- ========================================
- RHEL Network Latency Diagnosis Report
- ========================================
- 'Analysis Time: 2026-02-05T03:51:31Z'
- 'Hostname: Test-RHEL-7.9-1'
- 'Network Interface: ens192'
- 'Analysis Duration: N/A seconds'
- ''
- 1. Network Interface Status Check
- ========================================
- 'Interface Name: ens192'
- 'Interface Status: UP'
- 'MTU Setting: 1500'
- 'IP Address: 10.71.19.192'
- ''
- 2. Hardware Statistics
- ========================================
- 'Receive Error Packets: 0'
- 'Transmit Error Packets: 0'
- 'Receive Dropped Packets: 0'

TASK [report_generation : Report generation summary] *******************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- === Report Generation Summary ===
- ✅ Report generated successfully
- 'Report Location: /tmp/network_analysis_reports/network_analysis_Test-RHEL-7.9-1_1770263491.txt'
- ✅ Report generation tasks completed

TASK [Record analysis end time] ****************************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Calculate analysis duration] *************************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Display analysis completion information] *************************************************************************************************************************
ok: [Test-RHEL-7.9-1] =>
  msg:

- ═══════════════════════════════════════════════════════════════
- "\U0001F3AF NETWORK LATENCY DIAGNOSIS SUMMARY"
- ═══════════════════════════════════════════════════════════════
- "\U0001F4CB Analysis Status:"
- '   • Network Interface Check: Check network_interface role summary above'
- '   • System Diagnosis: Check system_diagnosis role summary above'
- '   • Traffic Capture: Check traffic_capture role summary above'
- '   • Report Generation: Check report_generation role summary above'
- ''
- '⏱️  Analysis Duration: 0 seconds'
- "\U0001F4DD Report Location: /tmp/network_analysis_reports/network_analysis_Test-RHEL-7.9-1_1770263491.txt"
- ''
- "\U0001F4DD Next Steps:"
- '   • Review the generated diagnostic report'
- '   • Analyze captured traffic files if enabled'
- '   • Address any identified issues based on recommendations'
- ═══════════════════════════════════════════════════════════════

PLAY RECAP *************************************************************************************************************************************************************
Test-RHEL-7.9-1            : ok=53   changed=1    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
