require 'rubygems'
require 'net/ssh'
require File.dirname(__FILE__) + '/../ONTAPfunctions/ONTAPfunctions.rb'
include ONTAPfunctions


Puppet::Type.type(:lif).provide(:lif_provider) do
	desc 'manages netapp LIFs'

	def exists?
		#exists? returns false, if the lif doesn't exist or require changes
		# returns true if lif exists and doesn't require changes
		Puppet.debug('LIF exists? ->  entering')
                filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "network interface show -vserver " + resource[:vserver_name] + " -lif " + resource[:name]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		unless output.include? "Logical Interface Name:"
			Puppet.debug( "LIF exists? -> no matching lif found with that name")
			return false
		end#unless

		#lif exists, check if it needs changes
		Puppet.debug( "LIF exists? -> There is a lif, lets find out if it needs changes")
		if self.modify?("all")
			then 
				Puppet.debug('lif exists? -> exist? = false: lif need changes')
				return false
			else   
				Puppet.debug('lif exists? -> exist? = true: no changes needed')
				return true
		end#self.modify
	end#def exist?


	def modify?(property)
		# checks if a particular property of the resource matches the manifest file
		# or if any property requires change
		# invoke with property= the property specified in the manifest: ex: home_port
		# or invoke with property=all to check for all properties
		# returns true if a change is needed
		Puppet.debug( "LIF modify? -> entering")

		#retrieve the current state of the lif
	        filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "network interface show -vserver " + resource[:vserver_name] + " -lif " + resource[:name]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		unless output.include? "Logical Interface Name:"
			Puppet.debug( "LIF modify? -> no matching lif found with that name")
			return false
		end#unless


		#match lif properties with definitions in the manifest
		state = "nochanges"
		case property
			when "firewall_policy", "all"
				#check for role changes
				unless (resource[:firewall_policy].upcase == output.scan(/.*Firewall Policy:.(.*)/).to_s.upcase.chomp)#re: Role: data
					Puppet.debug('lif modify? -> firewall policy need changes')
					state = "need changes"
				end
			when "home_node", "all"
				#check for home-node changes
				unless (resource[:home_node].upcase == output.scan(/.*Home Node:.(.*)/).to_s.upcase.chomp)
					Puppet.debug('lif modify? -> home node need changes')
					state = "need changes"
				end
			when "home_port", "all"
				#check for home-port changes
				unless (resource[:home_port].upcase == output.scan(/.*Home Port:.(.*)/).to_s.upcase.chomp)
					Puppet.debug('lif modify? -> home port need changes')
					state = "need changes"
				end
		end #case
       		#set results                    
		if state == "need changes"
			Puppet.debug('lif modify? -> exist? = true: lif need changes')
			return true
		else   
			Puppet.debug('lif modify? -> exist? = false: no changes needed')
			return false
		end#ifstate
	end #modify


	def create
		#create should create the LIF if it doesn't exist
		#or modify it to the correct parameters
		#
		Puppet.debug('LIF create -> entering')
		
		case 
			when ( self.exists? == false && self.modify?("all") )
				Puppet.debug('lif create -> there is a lif, and it needs changes')
				#there is LIF, and it needs changes
                		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
				command = "network interface modify -vserver " + resource[:vserver_name] 
				command	+= " -lif " + resource[:name] 
				results = ''
				#
				#check for firewall-policy changes
				if self.modify?("firewall_policy")
					then
						Puppet.debug('lif create -> firewall policy need changes')
						command += " -firewall-policy " + resource[:firewall_policy] 
				end
				#check for home-node changes
				if self.modify?("home_node")
					then
						Puppet.debug('lif create -> home node need changes')
						command += " -home-node " + resource[:home_node] 
				end
				#check for home-port changes
				if self.modify?("home_port")
					then
						Puppet.debug('lif create -> home port need changes')
						command += " -home-port " + resource[:home_port] 
				end
				#excute
				Puppet.debug('lif create -> modifying lif')
				output = ONTAPfunctions::connection(filerargs, command, results)


			when ( self.exists? && ( self.modify?(all) == false ) )
			       # there is LIF, it doesn't require changes
				Puppet.debug('lif create -> there is a lif, it does not require changes')
			when ( self.exists? == false )	
				# there's no LIF, lets create one
				Puppet.debug('lif create -> no lif, lets create one')
                		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
				command = "network interface create -vserver " + resource[:vserver_name] 
				command	+= " -lif " + resource[:name] 
				command += " -role " + resource[:role] 
				command += " -address " + resource[:address] 
				command += " -netmask " + resource[:netmask] 
				command += " -data-protocol " + resource[:data_protocol] 
				command += " -home-node " + resource[:home_node] 
				command += " -home-port " + resource[:home_port] 
				command += " -firewall-policy " + resource[:firewall_policy] 
				results = ''
				output = ONTAPfunctions::connection(filerargs, command, results)
		end#case


		#check if LIF modified correctly
		if (self.exists?)
			Puppet.debug( "LIF create -> lif created or modified sucessfully")
			return true
		else
			raise Puppet::ParseError, "LIF create -> lif create or modify failed"
		end#if self.exists

	end#def create


	def destroy
		Puppet.debug('LIF destroy -> entering')
                filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "network interface delete -vserver " + resource[:vserver_name] 
		command += " -lif " + resource[:name]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)

		if (self.exists?)
			raise Puppet::ParseError, "LIF destroy-> lif destroy failed"
		else
			Puppet.debug("LIF destroy -> lif destroy sucessfully")
		end

	end#def destroy

end
