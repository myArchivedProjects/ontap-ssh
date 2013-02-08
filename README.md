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



