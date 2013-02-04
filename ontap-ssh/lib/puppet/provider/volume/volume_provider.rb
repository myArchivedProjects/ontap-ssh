require 'rubygems'
require 'net/ssh'
require File.dirname(__FILE__) + '/../ONTAPfunctions/ONTAPfunctions.rb'
include ONTAPfunctions

Puppet::Type.type(:volume).provide(:volume_provider) do
	desc 'manages netapp volumes'

	def exists?
		#exists? should return false 
		#if the defined parameters in the resource
		#do not match the current state
		#
		Puppet.debug('volume exists? -> entering')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "volume show -vserver " + resource[:vserver_name] + " -volume " + resource[:volume]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		unless output.include? "Volume Name:"
			Puppet.debug('volume exists> -> no volume with that name')
			return false
		end#unless
		Puppet.debug('volume exists? -> there is a volume, lets find out if it needs changes')
		#lets find out if it needs fixing
		state = "nochanges"
		#check for size changes
		unless (resource[:size].upcase == output.scan(/.*Volume Size:.*(\d.*[MB|GB|TB]).*/).to_s)#re: Volume Size: 1GB
			Puppet.debug('volume exists? -> size need changes')
			state = "need changes"
		end
		#check for group id changes
		unless (resource[:group_id] == output.scan(/.*Group ID:.*(\d.*).*/).to_s.chomp)#re: Group ID: 0
			Puppet.debug('volume exists? -> group id need changes')
			state = "need changes"
		end
		#check for user id changes
		unless (resource[:user_id] == output.scan(/.*User ID:.*(\d.*).*/).to_s.chomp)#re: User ID: 0
			Puppet.debug('volume exists? -> user id need changes')
			state = "need changes"
		end
		#check for unix permissions
		#
		#
		#
		#check for volume comment
		unless (resource[:volume_comment] == output.scan(/.*Comment:.(.*)/).to_s.chomp)#re: Comment: bla bal
			Puppet.debug('volume exists? -> volume comment field need changes')
			state = "need changes"
		end
		#check for volume security style
		unless (resource[:volume_security_style] == output.scan(/.*Security Style:.(.*)/).to_s.chomp)#re: Comment: bla bal
			Puppet.debug('volume exists? -> volume security style needs changes')
			state = "need changes"
		end
		#check for space guarantee
		unless (resource[:space_guarantee] == output.scan(/.*Space Guarantee Style:.(.*)/).to_s.chomp)#re: Comment: bla bal
			Puppet.debug('volume exists? -> space guarantee needs changes')
			state = "need changes"
		end

		#set results			
		if state == "need changes"
			Puppet.debug('volume exists? -> exist? = false: volume need changes')
			false
		else
			Puppet.debug('volume exists? -> exist? = true: no changes needed')
			true
		end#ifstate
	end#def exists?



	def create
		#create, should create the volume if it doesn't exist
		#or modify it to the correct parameters if it exists
		Puppet.debug('volume create -> entering')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "volume show -vserver " + resource[:vserver_name] + " -volume " + resource[:volume] 
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		if output.include? "Volume Name:"
			#there is a volume, lets find out if it needs fixing
			Puppet.debug('volume create -> found a volume with that name, lets find out if it needs changes')
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
				Puppet.debug('volume create -> space guarantee needs changes')
				command += " -space-guarantee " + resource[:space_guarantee] 
				state = "need changes"
			end
			#check for volume state
			unless (resource[:volume_state] == output.scan(/.*Volume State:.(.*)/).to_s.chomp)#re: C
				Puppet.debug('volume create ->  volume state needs changes')
				command += " -state " + resource[:volume_state] 
				state = "need changes"
			end

			#apply changes if needed	
			if state == "no changes needed"
				puts "no changes needed"
				Puppet.debug('volume create ->  true: no changes needed')
				return true
			else
				Puppet.debug('volume create -> : changes needed')
				results = ''
				output = ONTAPfunctions::connection(filerargs, command, results)
				#return true
				#check if the volume exists
                		if (self.exists?)
					Puppet.debug( "volume create -> volume modified sucessfully")
					return true
				else
					raise Puppet::ParseError, "Volume create -> Volume modify failed"
				end
			end##if state

		else#create volume
			#no vol with that name, lets create a volume
			command = "volume create -vserver " + resource[:vserver_name] 
			command += " -volume " + resource[:volume]
			command += " -aggregate " + resource[:containing_aggr_name] 
			# the following are optional parameters
			#
			if defined? resource[:size]
				command += " -size " + resource[:size] 
				Puppet.debug('volume create -> adding size')
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

			filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
			results = ''
			output = ONTAPfunctions::connection(filerargs, command, results)
			#check if the volume exists
                	if (self.exists?)
				Puppet.debug( "volume create -> volume created sucessfully")
				return true
			else
				raise Puppet::ParseError, "Volume create -> Volume create failed"
			end
		end#if/else
	end#create

	def destroy
		Puppet.debug('volume create -> destroy')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "volume unmount -vserver " + resource[:vserver_name] + " -volume " + resource[:volume] 
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)

		command = "volume offline -vserver " + resource[:vserver_name] + " -volume " + resource[:volume] 
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)

		command = "volume destroy -vserver " + resource[:vserver_name] + " -volume " + resource[:volume] + " -force"
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		#check if volume was deleted sucessfully
                if (self.exists?)
			raise Puppet::ParseError, "Volume destroy -> Volume destroy failed"
			return false
		else
			Puppet.debug( "volume destroy -> volume destroy sucessfully")
			return true
		end
	end#def destroy

end#volume:provider
