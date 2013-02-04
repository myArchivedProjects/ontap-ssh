require 'rubygems'
require 'net/ssh'

module ONTAPfunctions
	def connection(filerargs, commands, results)
		#connects to the netapp cluster management interface using the resource definitions
		#and executes the arguments defined in the 'value' array
		#returning results
		#
		#

		Puppet.debug('ONTAPfunctions -> entering')
		ssh = Net::SSH.start( filerargs[0] , filerargs[1] , :password => filerargs[2] )
		Puppet.debug('ONTAPfunctions -> executing ' + commands.to_s)
		output_string = ssh.exec!(commands).to_s
		Puppet.debug('ONTAPfunctions -> value = ' + output_string)
		return output_string
	end

end

