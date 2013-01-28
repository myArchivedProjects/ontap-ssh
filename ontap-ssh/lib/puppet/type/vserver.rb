Puppet::Type.newtype(:vserver) do
	desc 'vserver is a type for managing vservers'

	ensurable 

#properties or parameters always match the naming specified in the ONTAP API zoom tool
	newparam(:name, :namevar => true) do
		desc 'the name of the vserver'
	end
	newparam(:cuser) do
		desc 'the username used to login to the cluster'
	end
	newparam(:vuser) do
		desc 'the username used to login to the vserver'
	end
	newparam(:vpass) do
		desc 'the password for the username used to login to the vserver'
	end
	newparam(:cpass) do
		desc 'the password for the username used to login to the cluster'
	end
	newparam(:cmgmt) do
		desc 'the ip address for the management lif on the cluster'
	end
	newparam(:port) do
		desc '80 or 443'
		defaultto '80'
	end
	newparam(:servertype) do
		desc 'FILER '
		defaultto 'FILER'
	end
	newparam(:transporttype) do
		desc 'https or http '
		defaultto 'HTTP'
	end
	newparam(:root_volume) do
		desc 'the root volume of the vserver'
	end
	newparam(:root_volume_aggregate) do
		desc 'the aggregate containing the root volume  of the vserver'
	end
	newparam(:aggr_list) do
		desc 'the list of aggregates associated to this vserver'
	end
	newparam(:name_server_switch) do
		defaultto 'file'
	end
	newparam(:name_mapping_switch) do
		defaultto 'file'
	end
	newparam(:root_volume_security_style) do
		desc 'the security style for the root volume  of the vserver'
		defaultto  'unix'
	end
	newparam(:language) do
		desc 'the language for the root volume  of the vserver'
	end
	newparam(:snapshot_policy) do
	end
	newparam(:comment) do
		desc 'just a comment about the the vserver'
	end
	newparam(:antivirus_on_access_policy) do
	end
	newparam(:quota_policy) do
	end
	newparam(:interface_name_mgmt) do
		desc 'the lif name for managment of the vserver'
		defaultto  'mgmt1'
	end
	newparam(:interface_name_mgmt_ipaddress) do
		desc 'the ipaddress for managment of the vserver'
	end
	newparam(:interface_name_mgmt_netmask) do
		desc 'the netmask for managment of the vserver'
	end
	newparam(:interface_name_mgmt_fwpolicy) do
		desc 'the firewall policy, typically mgmt for managment of the vserver'
		defaultto 'mgmt'
	end

end
