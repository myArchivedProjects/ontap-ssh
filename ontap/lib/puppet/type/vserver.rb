Puppet::Type.newtype(:vserver) do
	desc 'vserver is a type for managing vservers'

	ensurable 

#properties or parameters always match the naming specified in the ONTAP API zoom tool
	newparam(:name, :namevar => true) do
		desc 'the name of the vserver'
	end

	newparam(:vuser) do
		desc 'the username used to login to the vserver'
	end

	newparam(:vpass) do
		desc 'the password for the username used to login to the vserver'
	end

	newparam(:cmgmt) do
		desc 'the ip address for the management lif on the cluster'
	end


	newparam(:port) do
		desc '80 or 443'
	end

	newparam(:servertype) do
		desc 'FILER '
	end

	newparam(:transporttype) do
		desc 'https or http '
	end

	newproperty(:root_volume) do
		desc 'the root volume of the vserver'
		validate do |value|
			fail("Invalid root_volume #{value}") unless
				value =~ /^[0-9A-Za-z\.-]/
		end
	end


	newproperty(:root_volume_aggregate) do
		desc 'the aggregate containing the root volume  of the vserver'
	end

	newproperty(:name_server_switch) do
	end

	newproperty(:name_mapping_switch) do
	end

	newproperty(:root_volume_security_style) do
		desc 'the security style for the root volume  of the vserver'
	end

	newproperty(:language) do
		desc 'the language for the root volume  of the vserver'
	end

	newproperty(:snapshot_policy) do
	end

	newproperty(:comment) do
		desc 'just a comment about the the vserver'
	end

	newproperty(:antivirus_on_access_policy) do
	end

	newproperty(:quota_policy) do
	end

end
