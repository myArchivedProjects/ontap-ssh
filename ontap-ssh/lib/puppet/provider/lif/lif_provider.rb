require 'rubygems'
require 'net/ssh'

Puppet::Type.type(:lif).provide(:lif_provider) do
	desc 'manages netapp LIFs'

	def exists?
		Puppet.debug('exists?')
		Net::SSH.start( resource[:cmgmt] , resource[:cuser] , :password => resource[:cpass] ) do |ssh|
			        output = ssh.exec!("network interface show -vserver " + resource[:vserver_name] \
						  + " -lif " + resource[:name] )
				if output.include? "Logical Interface Name:"
					puts "found lif"
					true
				else
					puts "no matching lif found"
					false
				end
		end
	end


	def create
		Puppet.debug('create')
		Net::SSH.start( resource[:cmgmt] , resource[:cuser], :password => resource[:cpass] ) do |ssh|
			        output = ssh.exec!("network interface create -vserver " + resource[:vserver_name] \
					+ " -lif " + resource[:name] \
				        + " -role " + resource[:role] \
				        + " -address " + resource[:address] \
				        + " -netmask " + resource[:netmask] \
				        + " -data-protocol " + resource[:data_protocol] \
				        + " -home-node " + resource[:home_node] \
				        + " -home-port " + resource[:home_port] \
				        + " -firewall-policy " + resource[:firewall_policy] )

				if output.include? "successfully"
					puts "we did well"
					puts output
					true
				else
					puts "failed miserably"
					puts output
					false
				end
		end
	end


	def destroy
		Net::SSH.start( resource[:cmgmt] , resource[:cuser], :password => resource[:cpass] ) do |ssh|
			        output = ssh.exec!("network interface delete -vserver " + resource[:vserver_name] \
					+ " -lif " + resource[:name] )

		end
	
	end#def destroy

end
