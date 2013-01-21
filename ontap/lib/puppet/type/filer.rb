Puppet::Type.newtype(:filer) do
	#ensurable #disabled as we can't create filers
	newparam(:name, :namevar => true) do
	end

	newproperty(:ipaddress) do
	end

end
