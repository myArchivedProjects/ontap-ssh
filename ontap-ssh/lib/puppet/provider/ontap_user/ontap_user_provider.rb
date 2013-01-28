require 'rubygems'
require 'net/ssh'

Puppet::Type.type(:ontap_user).provide(:ontap_user_provider) do
	desc 'manages netapp users'

	def exists?
		Puppet.debug('exists?')
		Net::SSH.start( resource[:cmgmt] , resource[:cuser] , :password => resource[:cpass] ) do |ssh|
			        output = ssh.exec!("security login show -vserver " + resource[:vserver_name] \
						  + " -username " + resource[:name] )
				if output.include? "UserName"
					puts "found username"
					true
				else
					puts "no matching username found"
					false
				end
		end
	end


	def create
		Puppet.debug('create')
		Net::SSH.start( resource[:cmgmt] , resource[:cuser], :password => resource[:cpass] ) do |ssh|
			         ssh.exec!("security login create -vserver " + resource[:vserver_name] \
					+ " -username " + resource[:name] \
				        + " -application " + resource[:application] \
				        + " -authmethod " + resource[:authmethod] ) do |channel,stream,data|
						case data 
							when /Please enter a password for user/
								channel.send_data resource[:password] + "\n"
								puts "**********"
							when /Please enter it again:/
								channel.send_data resource[:password] + "\n"
								puts "**********"
							end
					end

		end
	end


	def destroy
		Puppet.debug('destroy')
		Net::SSH.start( resource[:cmgmt] , resource[:cuser], :password => resource[:cpass] ) do |ssh|
			        output = ssh.exec!("security login delete -vserver " + resource[:vserver_name] \
					+ " -username " + resource[:name] \
				        + " -application " + resource[:application] \
				        + " -authmethod " + resource[:authmethod] )
		end

	
	end#def destroy

end
