require 'rubygems'
require 'net/ssh'
require File.dirname(__FILE__) + '/../ONTAPfunctions/ONTAPfunctions.rb'
include ONTAPfunctions

Puppet::Type.type(:export_policy).provide(:export_policy_provider) do
	desc 'manages netapp NFS export policies'

	def exists?
		#exists? should return false 
		#if the defined parameters in the resource
		#do not match the current state
		#
		Puppet.debug('export_policy exists? -> entering')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "export-policy show -vserver " + resource[:vserver_name] + " -policyname " + resource[:export_policy_name]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)
		unless output.include? "Policy Name:"
			Puppet.debug('export_policy exists> -> no export_policy with that name')
			return false
		end#unless
		return true
	end#def exists?

	
	def create
		#create, should create the export_policy if it doesn't exist
		#or modify it to the correct parameters if it exists
		Puppet.debug('export_policy create -> entering')

		# there's no export, lets create one
		#
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "export-policy create -vserver " + resource[:vserver_name] 
		command += " -policyname " + resource[:export_policy_name]
		results =''
		output = ONTAPfunctions::connection(filerargs, command, results)

		#check if the volume exists
               	if (self.exists?)
			Puppet.debug( "export_policy create  -> policy created sucessfully")
				return true
		else
			raise Puppet::ParseError, "export_policy create -> policy create failed"
		end
	end#create

	def destroy
		Puppet.debug('export_policy destroy -> destroy')
		filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		command = "export-policy delete -vserver " + resource[:vserver_name] 
		command += " -policyname " + resource[:export_policy_name]
		results = ''
		output = ONTAPfunctions::connection(filerargs, command, results)

		#check if export policy was deleted sucessfully
                if (self.exists?)
			raise Puppet::ParseError, "export_policy destroy -> export_policy destroy failed"
			return false
		else
			Puppet.debug( "export_policy destroy -> export_policy destroy sucessfully")
			return true
		end
	end#def destroy

end#volume:provider
