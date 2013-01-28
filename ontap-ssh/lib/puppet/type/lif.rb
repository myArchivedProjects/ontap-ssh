Puppet::Type.newtype(:lif) do
	desc 'lif is a type for managing lifss'

	ensurable 

	newparam(:lif, :namevar => true) do
		desc 'the name of the lif'
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
	newparam(:comment) do
		desc 'just a comment about the the lif'
	end
	newparam(:role) do
		desc 'role for the lif'
	end
	newparam(:address) do
		desc 'ipaddress for the lif'
	end
	newparam(:netmask) do
		desc 'netmask for the lif'
	end
	newparam(:data_protocol) do
		desc 'data protocols for the lif'
	end
	newparam(:home_node) do
		desc 'home node for the lif'
	end
	newparam(:home_port) do
		desc 'home port for the lif'
	end
	newparam(:firewall_policy) do
		desc 'firewall policy for the lif'
	end


end
