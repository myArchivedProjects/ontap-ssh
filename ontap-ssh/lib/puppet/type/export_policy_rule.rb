Puppet::Type.newtype(:export_policy_rule) do
	desc 'export_policy_rule is a type for managing NetApp NFS export_policy rules'

	ensurable 

	newparam(:export_policy_rule, :namevar => true) do
		desc 'the name of the rule'
	end
	newparam(:export_policy_name) do
		desc 'the name of the parent policy rule'
	end
	newparam(:vserver_name) do
		desc 'the name of the vserver'
	end
	newparam(:cuser) do
		desc 'the username used to login to the cluster, defaults to admin'
	end
	newparam(:cpass) do
		desc 'the password for the username used to login to the cluster'
	end
	newparam(:cmgmt) do
		desc 'the ip address for the management lif on the cluster'
	end
	newparam(:clientmatch) do
		desc 'the network/mask'
	end
	newparam(:rorule) do
		desc 'the read only bit'
	end
	newparam(:rwrule) do
		desc 'the read write bit'
	end
	newparam(:allow_suid) do
		desc 'the allow_suid bit'
	end
	newparam(:allow_dev) do
		desc 'the allow_dev bit'
	end
	newparam(:protocol) do
		desc 'the protocol bit'
	end
	newparam(:anon) do
		desc 'the anon bit'
	end
	newparam(:superuser) do
		desc 'the superuser bit'
	end
	newparam(:ruleindex) do
		desc 'the rule index number'
	end

end
