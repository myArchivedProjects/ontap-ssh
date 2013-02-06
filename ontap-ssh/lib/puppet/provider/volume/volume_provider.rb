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


		#volume exists, check if it needs changes
		Puppet.debug( "Volume exists? -> There is a volume, lets find out if it needs changes")
		if self.modify?("all")
		then
			Puppet.debug('volume exists? -> exist? = false: volume need changes')
			return false
		else
			Puppet.debug('volume exists? -> exist? = true: no changes needed')
			return true
		end#self.modify
	end#def exists?


	def modify?(property)
                # checks if a particular property of the resource matches the manifest file
		## or if any property requires change
		## invoke with property= the property specified in the manifest: ex: volume_max_autosize
		## or invoke with property=all to check for all properties
		## returns true if a change is needed
		
		Puppet.debug('volume modify? -> entering')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "volume show -vserver " + resource[:vserver_name] + " -volume " + resource[:volume]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		unless output.include? "Volume Name:"
			Puppet.debug('volume modify> -> no volume with that name')
			return false
		end#unless

		Puppet.debug('volume modify? -> there is a volume, lets find out if it needs changes')
                #match volume properties with definitions in the manifest
		state = "nochanges"

		if (  [ "size","all" ].include?(property) )
			#check for size changes
			unless (resource[:size].upcase == output.scan(/.*Volume Size:.*(\d.*[MB|GB|TB]).*/).to_s)#re: Volume Size: 1GB
				Puppet.debug('volume exists? -> size need changes')
				state = "need changes"
			end
		end
		if (  [ "group_id","all" ].include?(property) )
			#check for group id changes
			unless (resource[:group_id] == output.scan(/.*Group ID:.*(\d.*).*/).to_s.chomp)#re: Group ID: 0
				Puppet.debug('volume exists? -> group id need changes')
				state = "need changes"
			end
		end
		if (  [ "user_id","all" ].include?(property) )
			#check for user id changes
			unless (resource[:user_id] == output.scan(/.*User ID:.*(\d.*).*/).to_s.chomp)#re: User ID: 0
				Puppet.debug('volume exists? -> user id need changes')
				state = "need changes"
			end
		end
		if (  [ "volume_comment","all" ].include?(property) )
			#check for volume comment
			unless (resource[:volume_comment] == output.scan(/.*Comment:.(.*)/).to_s.chomp)#re: Comment: bla bal
				Puppet.debug('volume exists? -> volume comment field need changes')
				state = "need changes"
			end
		end
		if (  [ "volume_security_style","all" ].include?(property) )
			#check for volume security style
			unless (resource[:volume_security_style] == output.scan(/.*Security Style:.(.*)/).to_s.chomp)#re: Comment: bla bal
				Puppet.debug('volume exists? -> volume security style needs changes')
				state = "need changes"
			end
		end
		if (  [ "space_guarantee","all" ].include?(property) )
			#check for space guarantee
			unless (resource[:space_guarantee] == output.scan(/.*Space Guarantee Style:.(.*)/).to_s.chomp)#re: Comment: bla bal
				Puppet.debug('volume exists? -> space guarantee needs changes')
				state = "need changes"
			end
		end
		if (  [ "volume_state","all" ].include?(property) )
			#check for volume state
			unless (resource[:volume_state] == output.scan(/.*Volume State:.(.*)/).to_s.chomp)#re: C
				Puppet.debug('volume exists? ->  volume state needs changes')
				state = "need changes"
			end
		end

		if state == "need changes"
			Puppet.debug('lif modify? -> exist? = true: lif need changes')
			return true
		else
			Puppet.debug('lif modify? -> exist? = false: no changes needed')
			return false
		end#ifstate
	end#modify?

	
	def create
		#create, should create the volume if it doesn't exist
		#or modify it to the correct parameters if it exists
		Puppet.debug('volume create -> entering')


                case
			when ( self.exists? == false && self.modify?("all") )
				Puppet.debug('volume create -> there is a volume, and it needs changes')
				#there is volume, and it needs changes
				filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		        	command = "volume modify -vserver " + resource[:vserver_name] + " -volume " + resource[:name]
				results = ''
				#check for size changes
				if self.modify?("size")
					Puppet.debug('volume create -> size need changes')
		        		command += " -size " + resource[:size]
				end
				#check for group id changes
				if self.modify?("group_id")
					Puppet.debug('volume create -> group_id need changes')
		        		command += " -group " + resource[:group_id]
				end
				#check for user id changes
				if self.modify?("user_id")
					Puppet.debug('volume create -> user_id need changes')
		        		command += " -user " + resource[:user_id]
				end
				#check for volume comment
				if self.modify?("volume_comment")
					Puppet.debug('volume create -> volume_comment need changes')
					command += " -comment \"" + resource[:volume_comment] + "\""
				end
				#check for security_style
				if self.modify?("volume_security_style")
					Puppet.debug('volume create -> volume_security_style need changes')
					command += " -security-style " + resource[:volume_security_style] 
				end
				#check for space_guarantee
				if self.modify?("space_guarantee")
					Puppet.debug('volume create -> space guarantee need changes')
					command += " -space-guarantee " + resource[:space_guarantee] 
				end
				#check for volume state
				if self.modify?("volume_state")
					Puppet.debug('volume create -> volume stateneed changes')
					command += " -state " + resource[:volume_state] 
				end

		                #execute
				Puppet.debug('volume create -> modifying volume')
		                output = ONTAPfunctions::connection(filerargs, command, results)


                        when ( self.exists? && ( self.modify?(all) == false ) )
				# there is volume, it doesn't require changes
				Puppet.debug('volume create -> there is a volume, it does not require changes')

			when ( self.exists? == false )
				# there's no volume, lets create one
				Puppet.debug('volume create -> no volume, lets create one')
				#
				filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
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
				results = ''
				output = ONTAPfunctions::connection(filerargs, command, results)
		end#case

		#check if the volume exists
               	if (self.exists?)
			Puppet.debug( "volume create -> volume created sucessfully")
				return true
		else
			raise Puppet::ParseError, "Volume create -> Volume create failed"
		end
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
