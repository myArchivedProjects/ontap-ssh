Puppet::Type.newtype(:ontap_user) do

	ensurable 

	newparam(:username, :namevar => true) do
		desc 'the username'
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
		desc 'the ip address for the management security on the cluster'
	end
	newparam(:comment) do
		desc 'just a comment about the user'
	end
	newparam(:application) do
		defaultto 'ssh'
	end
	newparam(:authmethod) do
		defaultto 'password'
	end
	newparam(:password) do
	end



end
