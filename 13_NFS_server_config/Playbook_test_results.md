[root@aap25 13_NFS_server_config]# ansible-playbook -i inventory deploy_nfs_server_site.yml

PLAY [Deploy and configure NFS server] ********************************************************************************************************************************

TASK [Gathering Facts] ************************************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Assert supported operating system (RHEL/CentOS 7/8/9 only)] *****************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Assert NFS shared directory is an absolute path] ****************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Assert NFS export entries are defined] **************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Debug effective NFS input variables] ****************************************************************************************************************************
ok: [Test-RHEL-7.9-1] => {
    "msg": {
        "export_entries": [
            "client1.example.com(rw,no_root_squash)"
        ],
        "exports_file": "/etc/exports.d/ansible-share.exports",
        "shared_directory": "/srv/myshare"
    }
}

TASK [Ensure NFS utilities are installed] *****************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Show NFS package installation result] ***************************************************************************************************************************
ok: [Test-RHEL-7.9-1] => {
    "nfs_packages_result": {
        "changed": false,
        "failed": false,
        "msg": "",
        "rc": 0,
        "results": [
            "1:nfs-utils-1.3.0-0.68.el7.2.x86_64 providing nfs-utils is already installed"
        ]
    }
}

TASK [Ensure NFS shared directory exists with correct permissions] ****************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Show NFS shared directory status] *******************************************************************************************************************************
ok: [Test-RHEL-7.9-1] => {
    "nfs_directory_result": {
        "changed": false,
        "diff": {
            "after": {
                "path": "/srv/myshare"
            },
            "before": {
                "path": "/srv/myshare"
            }
        },
        "failed": false,
        "gid": 0,
        "group": "root",
        "mode": "0755",
        "owner": "root",
        "path": "/srv/myshare",
        "size": 6,
        "state": "directory",
        "uid": 0
    }
}

TASK [Render NFS exports configuration file] **************************************************************************************************************************
changed: [Test-RHEL-7.9-1]

TASK [Show NFS exports configuration change] **************************************************************************************************************************
ok: [Test-RHEL-7.9-1] => {
    "nfs_exports_copy_result": {
        "backup_file": "/etc/exports.d/ansible-share.exports.21452.2026-02-04@17:06:29~",
        "changed": true,
        "checksum": "2d9c735232e5af3242443c69fb79c1369e856056",
        "dest": "/etc/exports.d/ansible-share.exports",
        "diff": [],
        "failed": false,
        "gid": 0,
        "group": "root",
        "md5sum": "91fca82c8c69da5adffbbd9d3d994e61",
        "mode": "0644",
        "owner": "root",
        "size": 52,
        "src": "/root/.ansible/tmp/ansible-tmp-1770195983.2670043-467402-251697004896527/source",
        "state": "file",
        "uid": 0
    }
}

TASK [Ensure nfs-server service is started and enabled] ***************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Show nfs-server service status] *********************************************************************************************************************************
ok: [Test-RHEL-7.9-1] => {
    "nfs_service_result": {
        "changed": false,
        "enabled": true,
        "failed": false,
        "name": "nfs-server",
        "state": "started",
        "status": {
            "ActiveEnterTimestamp": "Wed 2026-02-04 17:03:25 CST",
            "ActiveEnterTimestampMonotonic": "18062688336117",
            "ActiveExitTimestampMonotonic": "0",
            "ActiveState": "active",
            "After": "rpcbind.socket system.slice gssproxy.service nfs-mountd.service -.mount nfs-config.service nfs-idmapd.service systemd-journald.socket rpc-gssd.service rpc-statd.service proc-fs-nfsd.mount network-online.target local-fs.target",
            "AllowIsolate": "no",
            "AmbientCapabilities": "0",
            "AssertResult": "yes",
            "AssertTimestamp": "Wed 2026-02-04 17:03:25 CST",
            "AssertTimestampMonotonic": "18062688292978",
            "Before": "rpc-statd-notify.service",
            "BlockIOAccounting": "no",
            "BlockIOWeight": "18446744073709551615",
            "BoundBy": "nfs-idmapd.service nfs-mountd.service",
            "CPUAccounting": "no",
            "CPUQuotaPerSecUSec": "infinity",
            "CPUSchedulingPolicy": "0",
            "CPUSchedulingPriority": "0",
            "CPUSchedulingResetOnFork": "no",
            "CPUShares": "18446744073709551615",
            "CanIsolate": "no",
            "CanReload": "yes",
            "CanStart": "yes",
            "CanStop": "yes",
            "CapabilityBoundingSet": "18446744073709551615",
            "CollectMode": "inactive",
            "ConditionResult": "yes",
            "ConditionTimestamp": "Wed 2026-02-04 17:03:25 CST",
            "ConditionTimestampMonotonic": "18062688292978",
            "ControlGroup": "/system.slice/nfs-server.service",
            "ControlPID": "0",
            "DefaultDependencies": "no",
            "Delegate": "no",
            "Description": "NFS server and services",
            "DevicePolicy": "auto",
            "DropInPaths": "/run/systemd/generator/nfs-server.service.d/order-with-mounts.conf",
            "EnvironmentFile": "/run/sysconfig/nfs-utils (ignore_errors=yes)",
            "ExecMainCode": "1",
            "ExecMainExitTimestamp": "Wed 2026-02-04 17:03:25 CST",
            "ExecMainExitTimestampMonotonic": "18062688318506",
            "ExecMainPID": "20923",
            "ExecMainStartTimestamp": "Wed 2026-02-04 17:03:25 CST",
            "ExecMainStartTimestampMonotonic": "18062688301471",
            "ExecMainStatus": "0",
            "ExecReload": "{ path=/usr/sbin/exportfs ; argv[]=/usr/sbin/exportfs -r ; ignore_errors=yes ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }",
            "ExecStart": "{ path=/usr/sbin/rpc.nfsd ; argv[]=/usr/sbin/rpc.nfsd $RPCNFSDARGS ; ignore_errors=no ; start_time=[Wed 2026-02-04 17:03:25 CST] ; stop_time=[Wed 2026-02-04 17:03:25 CST] ; pid=20923 ; code=exited ; status=0 }",
            "ExecStartPost": "{ path=/bin/sh ; argv[]=/bin/sh -c if systemctl -q is-active gssproxy; then systemctl reload gssproxy ; fi ; ignore_errors=yes ; start_time=[Wed 2026-02-04 17:03:25 CST] ; stop_time=[Wed 2026-02-04 17:03:25 CST] ; pid=20939 ; code=exited ; status=0 }",
            "ExecStartPre": "{ path=/usr/sbin/exportfs ; argv[]=/usr/sbin/exportfs -r ; ignore_errors=yes ; start_time=[Wed 2026-02-04 17:03:25 CST] ; stop_time=[Wed 2026-02-04 17:03:25 CST] ; pid=20921 ; code=exited ; status=0 }",
            "ExecStop": "{ path=/usr/sbin/rpc.nfsd ; argv[]=/usr/sbin/rpc.nfsd 0 ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }",
            "ExecStopPost": "{ path=/usr/sbin/exportfs ; argv[]=/usr/sbin/exportfs -f ; ignore_errors=no ; start_time=[n/a] ; stop_time=[n/a] ; pid=0 ; code=(null) ; status=0/0 }",
            "FailureAction": "none",
            "FileDescriptorStoreMax": "0",
            "FragmentPath": "/usr/lib/systemd/system/nfs-server.service",
            "GuessMainPID": "yes",
            "IOScheduling": "0",
            "Id": "nfs-server.service",
            "IgnoreOnIsolate": "no",
            "IgnoreOnSnapshot": "no",
            "IgnoreSIGPIPE": "yes",
            "InactiveEnterTimestampMonotonic": "0",
            "InactiveExitTimestamp": "Wed 2026-02-04 17:03:25 CST",
            "InactiveExitTimestampMonotonic": "18062688298027",
            "JobTimeoutAction": "none",
            "JobTimeoutUSec": "0",
            "KillMode": "control-group",
            "KillSignal": "15",
            "LimitAS": "18446744073709551615",
            "LimitCORE": "18446744073709551615",
            "LimitCPU": "18446744073709551615",
            "LimitDATA": "18446744073709551615",
            "LimitFSIZE": "18446744073709551615",
            "LimitLOCKS": "18446744073709551615",
            "LimitMEMLOCK": "65536",
            "LimitMSGQUEUE": "819200",
            "LimitNICE": "0",
            "LimitNOFILE": "4096",
            "LimitNPROC": "15065",
            "LimitRSS": "18446744073709551615",
            "LimitRTPRIO": "0",
            "LimitRTTIME": "18446744073709551615",
            "LimitSIGPENDING": "15065",
            "LimitSTACK": "18446744073709551615",
            "LoadState": "loaded",
            "MainPID": "0",
            "MemoryAccounting": "no",
            "MemoryCurrent": "0",
            "MemoryLimit": "18446744073709551615",
            "MountFlags": "0",
            "Names": "nfs-server.service",
            "NeedDaemonReload": "no",
            "Nice": "0",
            "NoNewPrivileges": "no",
            "NonBlocking": "no",
            "NotifyAccess": "none",
            "OOMScoreAdjust": "0",
            "OnFailureJobMode": "replace",
            "PermissionsStartOnly": "no",
            "PrivateDevices": "no",
            "PrivateNetwork": "no",
            "PrivateTmp": "no",
            "ProtectHome": "no",
            "ProtectSystem": "no",
            "RefuseManualStart": "no",
            "RefuseManualStop": "no",
            "RemainAfterExit": "yes",
            "Requires": "system.slice nfs-mountd.service -.mount network.target proc-fs-nfsd.mount",
            "RequiresMountsFor": "/srv/myshare",
            "Restart": "no",
            "RestartUSec": "100ms",
            "Result": "success",
            "RootDirectoryStartOnly": "no",
            "RuntimeDirectoryMode": "0755",
            "SameProcessGroup": "no",
            "SecureBits": "0",
            "SendSIGHUP": "no",
            "SendSIGKILL": "yes",
            "Slice": "system.slice",
            "StandardError": "inherit",
            "StandardInput": "null",
            "StandardOutput": "journal",
            "StartLimitAction": "none",
            "StartLimitBurst": "5",
            "StartLimitInterval": "10000000",
            "StartupBlockIOWeight": "18446744073709551615",
            "StartupCPUShares": "18446744073709551615",
            "StatusErrno": "0",
            "StopWhenUnneeded": "no",
            "SubState": "exited",
            "SyslogLevelPrefix": "yes",
            "SyslogPriority": "30",
            "SystemCallErrorNumber": "0",
            "TTYReset": "no",
            "TTYVHangup": "no",
            "TTYVTDisallocate": "no",
            "TasksAccounting": "no",
            "TasksCurrent": "0",
            "TasksMax": "18446744073709551615",
            "TimeoutStartUSec": "0",
            "TimeoutStopUSec": "1min 30s",
            "TimerSlackNSec": "50000",
            "Transient": "no",
            "Type": "oneshot",
            "UMask": "0022",
            "UnitFilePreset": "disabled",
            "UnitFileState": "enabled",
            "WantedBy": "multi-user.target",
            "Wants": "nfs-idmapd.service rpcbind.socket rpc-statd.service rpc-statd-notify.service network-online.target auth-rpcgss-module.service nfs-config.service",
            "WatchdogTimestampMonotonic": "0",
            "WatchdogUSec": "0"
        }
    }
}

TASK [Check if firewalld service is running] **************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Ensure firewall allows NFS service when firewalld is running] ***************************************************************************************************
skipping: [Test-RHEL-7.9-1]

TASK [Show firewall configuration result for NFS] *********************************************************************************************************************
ok: [Test-RHEL-7.9-1] => {
    "nfs_firewalld_result": {
        "changed": false,
        "false_condition": "firewalld_state.stdout is defined and firewalld_state.stdout == \"active\"",
        "skip_reason": "Conditional result was False",
        "skipped": true
    }
}

TASK [Warn when firewalld is not running and firewall changes are skipped] ********************************************************************************************
ok: [Test-RHEL-7.9-1] => {
    "msg": [
        "firewalld service is not running on this host.",
        "NFS service has NOT been explicitly opened in the firewall by this play.",
        "If host-based firewalling is required, please enable firewalld or manage rules by other means."
    ]
}

TASK [Refresh and list active NFS exports] ****************************************************************************************************************************
ok: [Test-RHEL-7.9-1]

TASK [Show active NFS exports] ****************************************************************************************************************************************
ok: [Test-RHEL-7.9-1] => {
    "exportfs_output.stdout_lines": []
}

RUNNING HANDLER [reload nfs exports] **********************************************************************************************************************************
changed: [Test-RHEL-7.9-1]

PLAY RECAP ************************************************************************************************************************************************************
Test-RHEL-7.9-1            : ok=19   changed=2    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
