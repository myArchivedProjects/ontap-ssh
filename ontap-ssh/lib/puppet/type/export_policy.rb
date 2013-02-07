Puppet::Type.newtype(:export_policy) do
	desc 'export_policy is a type for managing NetApp NFS export_policies'

	ensurable 

	newparam(:export_policy_name, :namevar => true) do
		desc 'the name of the volume'
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






end
