require 'rubygems'
require 'net/ssh'

Puppet::Type.type(:volume).provide(:volume_provider) do
begin
	desc 'manages netapp volumes'

	def connection(value, results)
		#connects to the netapp cluster management interface using the resource definitions
		#and executes the arguments defined in the 'value' array
		#returning results

		Puppet.debug('initiating connection')
		ssh = Net::SSH.start( resource[:cmgmt] , resource[:cuser] , :password => resource[:cpass] )
		output = ssh.exec!(value)
		Puppet.debug('value = ' + value)
		return output
	end


	def exists?
		#exists? should return false 
		#if the defined parameters in the resource
		#do not match the current state
		#
		# checking if we can use our new class
		#

		#
		Puppet.debug('exists?')
			command = "volume show -vserver " + resource[:vserver_name] + " -volume " + resource[:volume] 
			results = ''
			output = connection(command, results)
			unless output.include? "Volume Name:"
				Puppet.debug('exists? = false, no volume with that name')
				false
			end#unless
			Puppet.debug('exists? = pending, there is a volume, lets find out if it needs changes')
			#lets find out if it needs fixing
			state = "nochanges"
			#check for size changes
			unless (resource[:size].upcase == output.scan(/.*Volume Size:.*(\d.*[MB|GB|TB]).*/).to_s)#re: Volume Size: 1GB
				Puppet.debug('size need changes')
				state = "need changes"
			end
			#check for group id changes
			unless (resource[:group_id] == output.scan(/.*Group ID:.*(\d.*).*/).to_s.chomp)#re: Group ID: 0
				Puppet.debug('group id need changes')
				state = "need changes"
			end
			#check for user id changes
			unless (resource[:user_id] == output.scan(/.*User ID:.*(\d.*).*/).to_s.chomp)#re: User ID: 0
				Puppet.debug('user id need changes')
				state = "need changes"
			end
			#check for unix permissions
			#
			#
			#
			#check for volume comment
			unless (resource[:volume_comment] == output.scan(/.*Comment:.(.*)/).to_s.chomp)#re: Comment: bla bal
				Puppet.debug('volume comment field need changes')
				state = "need changes"
			end
			#check for volume security style
			unless (resource[:volume_security_style] == output.scan(/.*Security Style:.(.*)/).to_s.chomp)#re: Comment: bla bal
				Puppet.debug('volume security style needs changes')
				state = "need changes"
			end
			#check for space guarantee
			unless (resource[:space_guarantee] == output.scan(/.*Space Guarantee Style:.(.*)/).to_s.chomp)#re: Comment: bla bal
				Puppet.debug('space guarantee needs changes')
				state = "need changes"
			end

			#set results			
			if state == "need changes"
				Puppet.debug('exist? = false: volume need changes')
				false
			else
				Puppet.debug('exist? = true: no changes needed')
				true
			end#ifstate
	end#def exists?



	def create
		#create, should create the volume if it doesn't exist
		#or modify it to the correct parameters if it exists
		Puppet.debug('create')
		command = "volume show -vserver " + resource[:vserver_name] + " -volume " + resource[:volume] 
		results = ''
		output = connection(command, results)
		if output.include? "Volume Name:"
			#there is a volume, lets find out if it needs fixing
			Puppet.debug('create: found a volume with that name, lets find out if it needs changes')
			state = "nochanges"
		        command = "volume modify -vserver " + resource[:vserver_name] + " -volume " + resource[:name]

			#check for size changes
			unless (resource[:size].upcase == output.scan(/.*Volume Size:.*(\d.*[MB|GB|TB]).*/).to_s)#re: Volume Size: 1GB
		        	command += " -size " + resource[:size]
				state = "need changes"
			end
			#check for group id changes
			unless (resource[:group_id] == output.scan(/.*Group ID:.*(\d.*).*/).to_s.chomp)#re: Group ID: 0
		        	command += " -group " + resource[:group_id]
				state = "need changes"
			end
			#check for user id changes
			unless (resource[:user_id] == output.scan(/.*User ID:.*(\d.*).*/).to_s.chomp)#re: User ID: 0
		        	command += " -user " + resource[:user_id]
				state = "need changes"
			end
			#check for volume comment
			unless (resource[:volume_comment] == output.scan(/.*Comment:.(.*)/).to_s.chomp)#re: Comment: bla bal
				command += " -comment \"" + resource[:volume_comment] + "\""
				state = "need changes"
			end
			#check for volume security style
			unless (resource[:volume_security_style] == output.scan(/.*Security Style:.(.*)/).to_s.chomp)#re:
				command += " -security-style " + resource[:volume_security_style] 
				state = "need changes"
			end
			#check for space guarantee
			unless (resource[:space_guarantee] == output.scan(/.*Space Guarantee Style:.(.*)/).to_s.chomp)#re: C
				Puppet.debug('space guarantee needs changes')
				command += " -space-guarantee " + resource[:space_guarantee] 
				state = "need changes"
			end
			#check for volume state
			unless (resource[:volume_state] == output.scan(/.*Volume State:.(.*)/).to_s.chomp)#re: C
				Puppet.debug(' volume state needs changes')
				command += " -state " + resource[:volume_state] 
				state = "need changes"
			end

			#apply changes if needed	
			if state == "no changes needed"
				puts "no changes needed"
				true
			else
				puts "changes needed"

				Puppet.debug('executing: ' + command)
				results = ''
				output = connection(command, results)
			end#ifstate

		else#create volume
			#no vol with that name, lets create a volume
			command = "volume create -vserver " + resource[:vserver_name] 
			command += " -volume " + resource[:volume]
			command += " -aggregate " + resource[:containing_aggr_name] 
			# the following are optional parameters
			#
			if defined? resource[:size]
				command += " -size " + resource[:size] 
				Puppet.debug('adding size')
			end
			if defined? resource[:group_id]
				command += " -group " + resource[:group_id] 
			end
			if defined? resource[:user_id]
				command += " -user " + resource[:user_id] 
			end
			if defined? resource[:unix_permissions]
				command += " -unix-permissions " + resource[:unix_permissions] 
			end
			if defined? resource[:volume_comment]
				command += " -comment \"" + resource[:volume_comment] + "\""
			end
			if defined? resource[:volume_security_style]
				command += " -security-style " + resource[:volume_security_style] 
			end
			if defined? resource[:space_guarantee]
				command += " -space-guarantee " + resource[:space_guarantee] 
			end
			if defined? resource[:snapshot_policy]
				command += " -snapshot-policy " + resource[:snapshot_policy] 
			end
			if defined? resource[:volume_state]
				command += " -state " + resource[:volume_state] 
			end
			if defined? resource[:volume_autosize]
				command += " -autosize " + resource[:volume_autosize] 
			end
			if defined? resource[:volume_max_autosize]
				command += " -max-autosize " + resource[:volume_max_autosize] 
			end
			if defined? resource[:volume_type]
				command += " -type " + resource[:volume_type] 
			end
			if defined? resource[:volume_autosize_increment]
				command += " -autosize-increment " + resource[:volume_autosize_increment] 
			end
			if defined? resource[:percent_snapshot_space]
				command += " -percent-snapshot-space " + resource[:percent_snapshot_space] 
			end
			if defined? resource[:is_nvfail_enabled]
				command += " -nvfail " + resource[:is_nvfail_enabled] 
			end
			if defined? resource[:junction_path]
				command += " -junction-path " + resource[:junction_path] 
			end

			Puppet.debug('executing: ' + command)
			results = ''
			output = connection(command, results)
			end#ifstate
			if output.include? "Sucessfull:"
				puts "we did well"
				true
			else
				puts "failed miserably"
				puts output
				false
			end
		end#if/else create volume
	end#create

	def destroy
		Puppet.debug('destroy')
		command = "volume unmount -vserver " + resource[:vserver_name] + " -volume " + resource[:volume] 
		results = ''
		output = connection(command, results) #not validating this yet

		command = "volume offline -vserver " + resource[:vserver_name] + " -volume " + resource[:volume] 
		results = ''
		output = connection(command, results) #not validating this yet

		command = "volume destroy -vserver " + resource[:vserver_name] + " -volume " + resource[:volume] + " -force"
		results = ''
		output = connection(command, results) #not validating this yet
		if output.include? "destroyed"
			puts "we did well"
			true
		else
			puts "failed miserably"
			false
		end
	end#def destroy
end#volume:provider

