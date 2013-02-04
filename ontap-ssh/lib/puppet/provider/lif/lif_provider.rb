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
		if output.include? "Logical Interface Name:"
			puts "LIF exists? -> found lif with that name"
			true
		else
			puts "LIF exists? -> no matching lif found with that name"
			false
		end#if output.include
	end#def exist?


	def create
		Puppet.debug('LIF create -> entering')
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
		if output.include? "successfully"
			puts "LIF create -> lif created sucessfully"
			true
		else
			raise Puppet::ParseError, "LIF create -> lif create failed"
			puts output
		end#if output.include
	end#def create


	def destroy
		Puppet.debug('LIF destroy -> entering')
                filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "network interface delete -vserver " + resource[:vserver_name] 
		command += " -lif " + resource[:name]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
	end#def destroy

end
