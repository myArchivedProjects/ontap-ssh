require 'rubygems'
require 'net/ssh'
require File.dirname(__FILE__) + '/../ONTAPfunctions/ONTAPfunctions.rb'
include ONTAPfunctions


Puppet::Type.type(:lif).provide(:lif_provider) do
	desc 'manages netapp LIFs'

	def exists?
		Puppet.debug('LIF exists? ->  entering')
                filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "network interface show -vserver " + resource[:vserver_name] + " -lif " + resource[:name]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		unless output.include? "Logical Interface Name:"
			Puppet.debug( "LIF exists? -> no matching lif found with that name")
			return false
		end#unless
		Puppet.debug( "LIF exists? -> There is a lif, lets find out if it needs changes")
		state = "nochanges"
		#check for role changes
		unless (resource[:firewall_policy].upcase == output.scan(/.*Firewall Policy:.(.*)/).to_s.upcase.chomp)#re: Role: data
			Puppet.debug('lif exists? -> firewall policy need changes')
			state = "need changes"
		end
		#check for home-node changes
		unless (resource[:home_node].upcase == output.scan(/.*Home Node:.(.*)/).to_s.upcase.chomp)
			Puppet.debug('lif exists? -> home node need changes')
			state = "need changes"
		end
		#check for home-port changes
		unless (resource[:home_port].upcase == output.scan(/.*Home Port:.(.*)/).to_s.upcase.chomp)
			Puppet.debug('lif exists? -> home port need changes')
			state = "need changes"
		end


			
       		#set results                    
		if state == "need changes"
			Puppet.debug('lif exists? -> exist? = false: lif need changes')
			false
		else   
			Puppet.debug('lif exists? -> exist? = true: no changes needed')
			true
		end#ifstate
	end#def exist?


	def create
		#create should create the LIF if it doesn't exist
		#or modify it to the correct parameters
		#
		Puppet.debug('LIF create -> entering')
                filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "network interface show -vserver " + resource[:vserver_name]  
		command += " -lif " + resource[:name] 
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		if output.include? "Logical Interface Name:"
			#there is LIF, lets find out if it needs fixing
			Puppet.debug('LIF create -> found a LIF, lets find out if it needs fixing')
			state = "nochanges"
			#check for firewall-policy changes
			unless (resource[:role].upcase == output.scan(/.*Firewall Policy:.(.*)/).to_s.upcase.chomp)
				Puppet.debug('lif create -> firewall policy need changes')
				state = "need changes"
			end
			#check for home-node changes
			unless (resource[:home_node].upcase == output.scan(/.*Home Node:.(.*)/).to_s.upcase.chomp)
				Puppet.debug('lif create -> home node need changes')
				state = "need changes"
			end
			#check for home-port changes
			unless (resource[:home_port].upcase == output.scan(/.*Home Port:.(.*)/).to_s.upcase.chomp)
				Puppet.debug('lif create -> home port need changes')
				state = "need changes"
			end

			#set values
			command = "network interface modify -vserver " + resource[:vserver_name] 
			command	+= " -lif " + resource[:name] 
			command += " -address " + resource[:address] 
			command += " -netmask " + resource[:netmask] 
			command += " -home-node " + resource[:home_node] 
			command += " -home-port " + resource[:home_port] 
			command += " -firewall-policy " + resource[:firewall_policy] 
			results = ''
			output = ONTAPfunctions::connection(filerargs, command, results)
			#check if LIF modified correctly
			if (self.exists?)
				Puppet.debug( "LIF create -> lif modified sucessfully")
				return true
			else
				raise Puppet::ParseError, "LIF create -> lif modified failed"
			end#if self.exists

		else
			Puppet.debug('LIF create -> creating new LIF')
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

			if (self.exists?)
				Puppet.debug( "LIF create -> lif created sucessfully")
				return true
			else
				raise Puppet::ParseError, "LIF create -> lif create failed"
			end#if self.exists
		end#if output.include
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
