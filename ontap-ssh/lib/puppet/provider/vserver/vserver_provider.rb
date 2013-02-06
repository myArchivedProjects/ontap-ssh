require 'rubygems'
require 'net/ssh'
require File.dirname(__FILE__) + '/../ONTAPfunctions/ONTAPfunctions.rb'
include ONTAPfunctions


Puppet::Type.type(:vserver).provide(:vserver_provider) do
	desc 'manages netapp vservers'

	def exists?
		Puppet.debug('vserver exists? -> entering')
                filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "vserver show -vserver " + resource[:vserver_name] 
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		unless output.include? "Vserver:"
			Puppet.debug('vserver exists? -> false: no vserver match')
			return false
		end#unless
		Puppet.debug('vserver exists? -> true: there is a vserver, lets find out if it needs changes')
		state = "nochanges"

		#vserver exists, check if it needs changes
		if self.modify?("all")
			Puppet.debug('vserver exists? -> exist? = false: vserver need changes')
			return false
		else
			Puppet.debug('vserver exists? -> exist? = true: no changes needed')
			return true
		end#self.modify
	end#def exists?
			



       def modify?(property)
	       # checks if a particular property of the resource matches the manifest file
	       # or if any property requires change
	       # 
	       # invoke with property= the property specified in the manifest: ex: comments
	       # or invoke with property=all to check for all properties
	       # returns true if a change is needed
	       #
	       #
                Puppet.debug('vserver modify? -> entering with args: ' + property)
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "vserver show -vserver " + resource[:vserver_name] 
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		unless output.include? "Vserver:"
			Puppet.debug('vserver modify> -> no vserver with that name')
			return false
		end#unless

                Puppet.debug('vserver modify? -> there is a vserver, lets find out if it needs changes')
		#match vserver properties with definitions in the manifest
		state = "nochanges"

		if (  [ "aggr_list","all" ].include?(property) )
			#check for aggr_list changes
			unless (resource[:aggr_list].upcase == output.scan(/.*List of Aggregates Assigned:.(.*).*/).to_s.upcase.chomp)
				Puppet.debug('vserver exists? -> aggr_list need changes')
				state = "need changes"
			end
		end

		if (  [ "snapshot_policy","all" ].include?(property) )
			#check for snapshot_policy changes
			unless (resource[:snapshot_policy].upcase == output.scan(/.*Snapshot Policy:.(.*).*/).to_s.upcase.chomp)
				Puppet.debug('vserver exists? -> snapshot_policy need changes')
				state = "need changes"
			end
		end
		if (  [ "comment","all" ].include?(property) )
			#check for comment changes
			unless (resource[:comment].upcase == output.scan(/.*Comment:.(.*).*/).to_s.upcase.chomp)
				Puppet.debug('vserver exists? -> comment need changes')
				state = "need changes"
			end
		end
		if (  [ "antivirus_on_access_policy","all" ].include?(property) )
			#check for antivirus_on_access_policy changes
			unless (resource[:antivirus_on_access_policy].upcase == \
					output.scan(/.*Anti-Virus On-Access Policy:.(.*).*/).to_s.upcase.chomp)
				Puppet.debug('vserver exists? -> anti-virus on access policy need changes')
				state = "need changes"
			end
		end
		if (  [ "quota_policy","all" ].include?(property) )
			#check for quota policy changes
			unless (resource[:quota_policy].upcase == output.scan(/.*Quota Policy:.(.*).*/).to_s.upcase.chomp)
				Puppet.debug('vserver exists? -> quota policy need changes')
				state = "need changes"
			end
		end
		if (  [ "name_server_switch","all" ].include?(property) )
			#check for quota policy changes
			unless (resource[:name_server_switch].upcase == output.scan(/.*Name Service Switch:.(.*).*/).to_s.upcase.chomp)
				Puppet.debug('vserver exists? -> Name Service Switch need changes')
				state = "need changes"
			end
		end

                if state == "need changes"
			Puppet.debug('vserver modify? -> exist? = true: vserver need changes')
			return true
		else
			Puppet.debug('vserver modify? -> exist? = false: no changes needed')
			return false
		end#ifstate
       end#modify?



	def create
		#create should create the vserver if it doesn't exist
		#or modify it to the correct parameters if it exists
		Puppet.debug('vserver create ? -> entering')

		case 
			when ( self.exists? == false && self.modify?("all") )
				Puppet.debug('vserver create -> there is a vserver, and it needs changes')
				#there is a vserver, and it needs changes
				#
                		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
				command = "vserver modify -vserver " + resource[:vserver_name] 
				results = ''
				#check for aggr_list changes
				if self.modify?("aggr_list")
		                	Puppet.debug('vserver create -> aggr_list need changes')
					command += " -aggr-list " + resource[:aggr_list]
				end
				#check for snapshot_policy changes
				if self.modify?("snapshot_policy")
		                	Puppet.debug('vserver create -> snapshot_policy need changes')
					command += " -snapshot-policy " + resource[:snapshot_policy]
				end
				#check for comment changes
				if self.modify?("comment")
		                	Puppet.debug('vserver create -> comment need changes')
					command += " -comment " + resource[:comment]
				end
				#check for antivirus_on_acccess_policy changes
				if self.modify?("antivirus_on_access_policy")
		                	Puppet.debug('vserver create -> antivirus on access policy  need changes')
					command += " -antivirus-on-access-policy " + resource[:antivirus_on_access_policy]
				end
				#check for quota_policy changes
				if self.modify?("quota_policy")
		                	Puppet.debug('vserver create -> quota policy  need changes')
					command += " -quota-policy " + resource[:quota_policy]
				end
				#check for name_server_switch changes
				if self.modify?("name_server_switch")
		                	Puppet.debug('vserver create -> name server switch  need changes')
					command += " -nm-switch " + resource[:name_server_switch]
				end
				#execute
				Puppet.debug('vserver create -> modifying vserver')
				output = ONTAPfunctions::connection(filerargs, command, results)


			 when ( self.exists? && ( self.modify?(all) == false ) )
				 # there is vserver, it doesn't require changes
				 Puppet.debug('vserver create -> there is a vserver, it does not require changes')

			 when ( self.exists? == false )
				 #there's no vserver, lets crete one
				Puppet.debug('vserver create -> no vserver, lets create one') 
				filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
				command = "vserver create -vserver " + resource[:vserver_name] 
				command += " -rootvolume " + resource[:root_volume] 
				command += " -aggregate " + resource[:root_volume_aggregate] 
				command += " -ns-switch " + resource[:name_server_switch] 
				command += " -nm-switch " + resource[:name_mapping_switch] 
	        		command += " -rootvolume-security-style " + resource[:root_volume_security_style]
				# the following are optional parameters
				# 
				# if defined? resource[:parameter]
				# 	command+= " -parameter " + resource[:parameter]
				# 	Puppet.debut("vserver create -> adding paramter")
				# end
				#
				#
				# end of optional parameters
				results =''	
				output = ONTAPfunctions::connection(filerargs, command, results)
			 end#case

		#check if the vserver exists
		if (self.exists?)
			Puppet.debug( "vserver create -> vserver created successfully")
			return true
		else
			raise Puppet::ParseError, "Vserver create -> Vserver create failed"

		end
	end#def create


	def destroy
		Puppet.debug('vserver destroy ? -> entering')
                filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		results = ''
		command = "volume show -vserver " + resource[:vserver_name] 
		output = ONTAPfunctions::connection(filerargs, command, results)
		if output.match('online|restricted|offline')
			Puppet.debug('vserver destroy ? -> found a few volumes on that vserver')
			#lets kill them. but leave rootvol for last
			#MISSING SUPPORT TO IDENTIFY rootvol
			for x in output.scan(/\w.* (\w.*) \w.* online|restricted|offline/)
				Puppet.debug('vserver destroy ? -> volumes ' + x.to_s() )

		       		vol_unmount_cmd = "volume unmount -vserver " + resource[:name] + " -volume " + x.to_s()
				vol_unmount_results = ONTAPfunctions::connection(filerargs, vol_unmount_cmd, vol_unmount_results)


		       		vol_offline_cmd = "volume offline -vserver " + resource[:name] + " -volume " + x.to_s()
				vol_offline_results = ONTAPfunctions::connection(filerargs, vol_offline_cmd, vol_offline_results)

		       		vol_destroy_cmd = "volume destroy -vserver " + resource[:name] + " -volume " + x.to_s() + " -force "  
				vol_destroy_results = ONTAPfunctions::connection(filerargs, vol_destroy_cmd, vol_destroy_results)
			end#for volume offline,destroy
			# MISSING SHOULD REMOVE ROOTVOL as last step
			# offline,destroy root vol


		end#if output.match

		#destroy the vservers
	     	vstop_cmd = "vserver stop -vserver " + resource[:name] 
		vstop_results = ONTAPfunctions::connection(filerargs, vstop_cmd, vstop_results)

       		vdestroy_cmd = "vserver destroy -vserver " + resource[:name] 
		vdestroy_results = ONTAPfunctions::connection(filerargs, vdestroy_cmd, vdestroy_results)
		puts vdestroy_results
	end#def destroy

end
