# ontap-ssh
# Provides NetApp Cluster-Mode configuration management support for the following modules
#  * vservers: creates, deletes and modifies vservers
#  * volumes: creates, deletes and modifies some parameters
#  * lifs: creates, deletes  lifs
#  * ontap_users: creates, deletes users

# This modules uses ssh to connect to the netapp controllers
# it requires rubygems and net-ssh to be installed 


vserver { 'test2':
        ensure => "present",
        cmgmt => "172.16.1.83",
        cuser => "admin",
        cpass => "netapp123",
        root_volume => "rootvol", #immutable
        root_volume_aggregate => "aggr1", #immutable
        root_volume_security_style => "unix", #immutable
        aggr_list => "aggr1",
        language => "C", #immutable
        snapshot_policy => "default",
        comment => "test1",
        antivirus_on_access_policy => "default",
        quota_policy => "default",
        name_server_switch => "file",
        #interface_name_mgmt => "mgmt1", # is this being used ?
        #interface_name_mgmt_ipaddress => "172.16.1.202", #is this being used?
        #interface_name_mgmt_netmask => "255.255.255.0", #is this being used?
        #interface_name_mgmt_fwpolicy => "mgmt" #is this being used ?
}        


volume { 'datatest1':
        ensure => "absent",
        cmgmt => "172.16.1.83",
        cuser => "admin",  
        cpass => "netapp123",
        vserver_name => "test2", ##immutable
        containing_aggr_name => "aggr1", #required, immutable
        size => "2GB", #required,immutable
        group_id => "0", #optional
        user_id => "0", #optional
        unix_permissions => "0000", #optional, missing modify support
        volume_comment => "datatest1 created by puppet1", #optional
        volume_security_style => "unix", #optional
        space_guarantee => "none", #optional
        snapshot_policy => "default", #optional, missing modify support
        volume_state => "online", #optional, needs additional testing and modify support
        volume_autosize => "true", #optional, missing modify support
        volume_max_autosize => "1g", #optional. missing modify support
        volume_autosize_increment => "1g", #optional, missing modify support
        volume_type => "rw", #optional, immutable 
        percent_snapshot_space => "10", #optional, missing modify support
        is_nvfail_enabled => "off", #optional, missing modify support
        junction_path => "/datatest1", #optional, missing modify support
        require => Vserver['test2']
}
lif { 'mgmt1':
        ensure => "absent",
        cmgmt => "172.16.1.83",
        cuser => "admin",
        cpass => "netapp123",
        vserver_name => "test2", #immutable
        address => "172.16.1.202", #required, missing modify support
        netmask => "255.255.255.0", #required, missing modify support
        role => "data", #required, immutable
        firewall_policy => "mgmt", #required
        home_node => "cmode82-puppetmodule-01", #required
        home_port => "e0c", #required
        data_protocol => "nfs,cifs", #required, immutable? or missing modify support
        require => Vserver['test2']
}

ontap_user { 'admin2':
        ensure => "absent",
        cmgmt => "172.16.1.83",
        cuser => "admin",
        cpass => "netapp123",
        vserver_name => "test2", #required, immutable
        application => "ssh", #required, missing modify support
        authmethod => "password", #required, missing modify support
        password => "netapp123", #required, missing modify support
        require => Vserver['test2']
}

export_policy { 'nfsexportA':
        ensure => "present",
        cmgmt => "172.16.1.83",
        cuser => "admin",
        cpass => "netapp123",
        vserver_name => "test2", #required, immutable
        require => Vserver['test2']
}

export_policy_rule { 'rule1':
        ensure => "present",
        cmgmt => "172.16.1.83",
        cuser => "admin",
        cpass => "netapp123",
        vserver_name => "test2", #required, immutable
        export_policy_name => "nfsexportA", #required, immutable
        ruleindex => "1", #required, immutable
        clientmatch => "172.16.1.0/24", #required
        rorule => "any", #required, immutable
        rwrule => "any", #required, immutable
        protocol => "nfs", #required
        allow_suid => "true", #required
        allow_dev => "true", #required
        anon => "0", #required
        superuser => "any", #required
        require => [ Vserver['test2'], Export_policy['nfsexportA'] ]
}

export_policy_rule { 'rule2':
        ensure => "present",
        cmgmt => "172.16.1.83",
        cuser => "admin",
        cpass => "netapp123",
        vserver_name => "test2", #required, immutable
        export_policy_name => "nfsexportA", #required, immutable
        ruleindex => "2", #required, immutable
        clientmatch => "172.16.2.0/24", #required
        rorule => "any", #required, immutable
        rwrule => "any", #required, immutable
        protocol => "nfs", #required
        allow_suid => "true", #required
        allow_dev => "true", #required
        anon => "0", #required
        superuser => "any", #required
        require => [ Vserver['test2'], Export_policy['nfsexportA'] ]
}




