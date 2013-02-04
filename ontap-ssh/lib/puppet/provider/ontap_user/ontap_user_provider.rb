require 'rubygems'
require 'net/ssh'
require File.dirname(__FILE__) + '/../ONTAPfunctions/ONTAPfunctions.rb'
include ONTAPfunctions

Puppet::Type.type(:ontap_user).provide(:ontap_user_provider) do
	desc 'manages netapp users'

	def exists?
		Puppet.debug('user exists? -> entering')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
	        command = "security login show -vserver " + resource[:vserver_name] + " -username " + resource[:name]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		if output.include? "UserName"
			Puppet.debug('user exists? -> true: found username match')
			return true
		else
			Puppet.debug('user exists? -> false: no username match')
			return false
		end
	end#def exists?


	def create
		Puppet.debug('user create -> entering')
		# creating a user requires a SSH session in order to specify the password
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
		Puppet.debug('user destroy -> entering')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		results = ''
		command = "security login delete -vserver " + resource[:vserver_name] 
		command += " -username " + resource[:name] 
		command += " -application " + resource[:application] 
		command += " -authmethod " + resource[:authmethod] 

		output = ONTAPfunctions::connection(filerargs, command, results)
		Puppet.debug('user destroy -> results :' + results.to_s )
	
	end#def destroy

end
