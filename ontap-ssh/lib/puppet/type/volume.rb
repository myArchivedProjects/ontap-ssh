Puppet::Type.newtype(:volume) do
	desc 'volume is a type for managing volumes'

	ensurable 

	newparam(:volume, :namevar => true) do
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
	newparam(:port) do
		desc '80 or 443, defaults to 80'
		defaultto '80'
	end
	newparam(:servertype) do
		desc 'have no idea what its for, defaults to FILER'
		defaultto 'FILER'
	end
	newparam(:transporttype) do
		desc 'HTTP or HTTPS, defaults to HTTP'
		defaultto 'HTTP'
	end
	newparam(:comment) do
		desc 'just a comment about the the vserver'
	end
	newparam(:containing_aggr_name) do
		desc 'aggregate that contains the volume'
	end
	newparam(:size) do
		desc 'size of the flexvol as in: 1123k 123m 1g 1t'
	end	
	newparam(:antivirus_on_access_policy) do
		desc 'The name of the anti-virus on-access policy. defaults to default'
	end
	newparam(:flexcache_cache_policy) do
		desc 'The name of the flexcache cache policy. defaults to default'
	end
	newparam(:flexcache_fill_policy) do
		desc 'The name of the flexcache fill policy. defaults to default'
	end
	newparam(:flexcache_origin_volume) do
		desc 'The name of the volume that contains the authoritative data'
	end
	newparam(:group_id) do
		desc 'the UNIX group ID for the volume, defaults to 0'
		defaultto '0'
	end
	newparam(:index_dir_enabled) do
		desc 'true/false, enables or disables index directory format, default false'
	end
	newparam(:is_nvfail_enabled) do
		desc 'enabled NVFAIL for this volume, defaults to false'
		defaultto 'false'
	end
	newparam(:junction_path) do
		desc 'the juction path at which this volume is to be mounted'
	end
	newparam(:max_dir_size) do
		desc 'the maximum size in bytes to which any directory in this volume can grow'
	end
	newparam(:max_write_alloc_blocks) do
		desc 'the maximum number of blocks used for write allocation'
	end
	newparam(:unix_permissions) do
		desc 'Unix permission bits in octal string format'
	end
	newparam(:user_id) do
		desc 'Unix user id for the volume, default is 0'
		defaultto '0'
	end
	newparam(:volume_comment) do
		desc 'a description for the volume being created'
	end
	newparam(:volume_security_style) do
		desc 'mixed|ntfs|unix defaults to unix'
	end
	newparam(:volume_state) do
		desc 'desired state of the volume after it is created. online|restricted|offline'
	end
	newparam(:volume_type) do
		desc 'the type of volume to be created. rw|ls|dp|dc defaults to rw'
		defaultto 'rw'
	end
	newparam(:snapshot_policy) do
		desc 'the name of the snapshot policy, defaults to default'
		defaultto 'default'
	end
	newparam(:language_code) do
		desc 'the language to use for the volume, defaults to C'
	end
	newparam(:space_guarantee) do
		desc 'the type of volume guarantee, none|file|volume, defaults to volume'
		defaultto 'volume'
	end
	newparam(:volume_autosize) do
		desc 'volume autosize on or off'
	end
	newparam(:volume_max_autosize) do
		desc 'volume maximum autosize '
	end
	newparam(:volume_autosize_increment) do
		desc 'volume autosize increment'
	end
	newparam(:percent_snapshot_space) do
		desc 'volume snapshot space percentage'
	end






end
