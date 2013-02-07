require 'rubygems'
require 'net/ssh'
require File.dirname(__FILE__) + '/../ONTAPfunctions/ONTAPfunctions.rb'
include ONTAPfunctions

Puppet::Type.type(:export_policy_rule).provide(:export_policy_rule_provider) do
	desc 'manages export policy rule'

	def exists?
		#exists? should return false 
		#if the defined parameters in the resource
		#do not match the current state
		#
		Puppet.debug('export policy rule exists? -> entering')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "export-policy rule show -vserver " + resource[:vserver_name] + " -policyname " + resource[:export_policy_name]
		command += " -ruleindex " + resource[:ruleindex]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		unless output.include? "Policy Name:"
			Puppet.debug('export_policy_rule exists> -> no rule for that policy')
			return false
		end#unless
		Puppet.debug('export_policy_rule exists? -> rule found, lets find out if it needs changes')
		#lets find out if it needs fixing
		state = "nochanges"


		#volume exists, check if it needs changes
		Puppet.debug( "export_policy_rule exists? -> There is a rule, lets find out if it needs changes")
		if self.modify?("all")
		then
			Puppet.debug('export_policy_rule exists? -> exist? = false: rule need changes')
			return false
		else
			Puppet.debug('export_policy_rule exists? -> exist? = true: no changes needed')
			return true
		end#self.modify
	end#def exists?


	def modify?(property)
                # checks if a particular property of the resource matches the manifest file
		## or if any property requires change
		## invoke with property= the property specified in the manifest: ex: volume_max_autosize
		## or invoke with property=all to check for all properties
		## returns true if a change is needed
		
		Puppet.debug('export_policy_rule modify? -> entering')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "export-policy rule show -vserver " + resource[:vserver_name] + " -policyname " + resource[:export_policy_name]
		command += " -ruleindex " + resource[:ruleindex]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		unless output.include? "Policy Name:"
			Puppet.debug('export_policy_rule modify> -> no rule for that policy')
			return false
		end#unless

		Puppet.debug('export_policy_rule modify? -> there is a rule, lets find out if it needs changes')
                #match export_policy_rule properties with definitions in the manifest
		state = "nochanges"

		if (  [ "clientmatch","all" ].include?(property) )
			#check for clientmatch changes
			unless (resource[:clientmatch].upcase == output.scan(/.*Client Match Spec:.(.*)/).to_s.upcase.chomp)#re: 
				Puppet.debug('export_policy_rule exists? -> clientmatch need changes')
				state = "need changes"
			end
		end
		if (  [ "rorule","all" ].include?(property) )
			#check for rorule changes
			unless (resource[:rorule].upcase == output.scan(/.*RO Access Rule:.(.*)/).to_s.upcase.chomp)#re:
				Puppet.debug('export_policy_rule exists? -> RO need changes')
				state = "need changes"
			end
		end
		if (  [ "rwrule","all" ].include?(property) )
			#check for rwrule changes
			unless (resource[:rwrule].upcase == output.scan(/.*RW Access Rule:.(.*)/).to_s.upcase.chomp)#re:
				Puppet.debug('export_policy_rule exists? -> RW need changes')
				state = "need changes"
			end
		end
		if (  [ "allow_suid","all" ].include?(property) )
			#check for allow_suid changes
			unless (resource[:allow_suid].upcase == output.scan(/.*Honor SetUID Bits In SETATTR:.(.*)/).to_s.upcase.chomp)#re:
				Puppet.debug('export_policy_rule exists? -> allow_suid need changes')
				state = "need changes"
			end
		end
		if (  [ "allow_dev","all" ].include?(property) )
			#check for allow_dev changes
			unless (resource[:allow_dev].upcase == output.scan(/.*Allow Creation of Devices:.(.*)/).to_s.upcase.chomp)#re:
				Puppet.debug('export_policy_rule exists? -> allow_dev need changes')
				state = "need changes"
			end
		end
		if (  [ "anon","all" ].include?(property) )
			#check for anon changes
			unless (resource[:anon].upcase == output.scan(/.*User ID To Which Anonymous Users Are Mapped:.(.*)/).to_s.upcase.chomp)#re:
				Puppet.debug('export_policy_rule exists? -> anon need changes')
				state = "need changes"
			end
		end
		if (  [ "protocol","all" ].include?(property) )
			#check for protocol changes
			unless (resource[:protocol].upcase == output.scan(/.*Access Protocol:.(.*)/).to_s.upcase.chomp)#re:
				Puppet.debug('export_policy_rule exists? -> protocol need changes')
				state = "need changes"
			end
		end
		if (  [ "superuser","all" ].include?(property) )
			#check for superuser changes
			unless (resource[:superuser].upcase == output.scan(/.*Superuser Security Flavors:.(.*)/).to_s.upcase.chomp)#re:
				Puppet.debug('export_policy_rule exists? -> superuser need changes')
				state = "need changes"
			end
		end

		if state == "need changes"
			Puppet.debug('export_policy_rule modify? -> exist? = true: export_policy_rule need changes')
			return true
		else
			Puppet.debug('export_policy_rule modify? -> exist? = false: no changes needed')
			return false
		end#ifstate
	end#modify?

	
	def create
		#create, should create the volume if it doesn't exist
		#or modify it to the correct parameters if it exists
		Puppet.debug('export_policy_rule create -> entering')


                case
			when ( self.exists? == false && self.modify?("all") )
				Puppet.debug('export_policy_rule create -> there is a export rule, and it needs changes')
				#there is rule, and it needs changes
				filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		        	command = "export-policy rule modify -vserver " + resource[:vserver_name] + " -policyname " + resource[:export_policy_name]
		        	command += " -ruleindex " + resource[:ruleindex] 
				results = ''
				#check for clientmatch changes
				if self.modify?("clientmatch")
					Puppet.debug('export_policy_rule create -> clientmatch need changes')
		        		command += " -clientmatch " + resource[:clientmatch]
				end

				#check for rorules changes
				if self.modify?("rorule")
					Puppet.debug('export_policy_rule create -> rorules need changes')
		        		command += " -ro " + resource[:rorule]
				end
				#check for rwrules changes
				if self.modify?("rwrule")
					Puppet.debug('export_policy_rule create -> rwrules need changes')
		        		command += " -rw " + resource[:rwrule]
				end
				#check for allow_suid changes
				if self.modify?("allow_suid")
					Puppet.debug('export_policy_rule create -> allow_suid need changes')
		        		command += " -allow-suid " + resource[:allow_suid]
				end
				#check for allow_dev changes
				if self.modify?("allow_dev")
					Puppet.debug('export_policy_rule create -> allow_dev need changes')
		        		command += " -allow-dev " + resource[:allow_dev]
				end
				#check for protocol changes
				if self.modify?("protocol")
					Puppet.debug('export_policy_rule create -> protocol need changes')
		        		command += " -protocol " + resource[:protocol]
				end
				#check for anon changes
				if self.modify?("anon")
					Puppet.debug('export_policy_rule create -> anon need changes')
		        		command += " -anon " + resource[:anon]
				end
				#check for superuser changes
				if self.modify?("superuser")
					Puppet.debug('export_policy_rule create -> superuser need changes')
		        		command += " -superuser " + resource[:superuser]
				end


		                #execute
				Puppet.debug('export_policy_rule create -> modifying rule')
				results =''
		                output = ONTAPfunctions::connection(filerargs, command, results)


                        when ( self.exists? && ( self.modify?(all) == false ) )
				# there is rule, it doesn't require changes
				Puppet.debug('export policy rule create -> there is a rule, it does not require changes')

			when ( self.exists? == false )
				# there's no rule, lets create one
				Puppet.debug('export policy rule create -> no export policy rule, lets create one')
				#
				filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
				command = "export-policy rule create -vserver " + resource[:vserver_name] 
				command += " -policyname " + resource[:export_policy_name]
				command += " -ruleindex " + resource[:ruleindex]
				command += " -clientmatch " + resource[:clientmatch]
				command += " -rorule " + resource[:rorule]
				command += " -rwrule " + resource[:rwrule]
				command += " -allow-suid " + resource[:allow_suid]
				command += " -allow-dev " + resource[:allow_dev]
				command += " -protocol " + resource[:protocol]
				command += " -anon " + resource[:anon]
				command += " -superuser " + resource[:superuser]
				# the following are optional parameters
				#
				#if defined? resource[:size]
				#	command += " -size " + resource[:size] 
				#	Puppet.debug('volume create -> adding size')
				#end
				results = ''
				output = ONTAPfunctions::connection(filerargs, command, results)
		end#case

		#check if the volume exists
               	if (self.exists?)
			Puppet.debug( "export policy rule create -> rule created sucessfully")
				return true
		else
			raise Puppet::ParseError, "export policy rule create -> rule create failed"
		end
	end#create

	def destroy
		Puppet.debug('export policy rule destroy -> entering')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "export-policy rule delete -vserver " + resource[:vserver_name] 
		command += " -policyname " + resource[:export_policy_name]
		command += " -ruleindex " + resource[:ruleindex]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)

		#check if rule was deleted sucessfully
                if (self.exists?)
			raise Puppet::ParseError, "export policy rule destroy -> rule destroy failed"
			return false
		else
			Puppet.debug( "export policy rule destroy -> rule destroy sucessfully")
			return true
		end
	end#def destroy

end#volume:provider
