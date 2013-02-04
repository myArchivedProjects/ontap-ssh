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
		if output.include? "Vserver:"
			Puppet.debug('vserver exists? -> true: found vserver match')
			true
		else
			Puppet.debug('vserver exists? -> false: no vserver match')
			false
		end
	end



	def create
		Puppet.debug('vserver create ? -> entering')
                filerargs = [ resource[:cmgmt] , resource[:cuser] , resource[:cpass] ]
		results = ''
		command = "vserver create -vserver " + resource[:vserver_name] 
		command += " -rootvolume " + resource[:root_volume] 
		command += " -aggregate " + resource[:root_volume_aggregate] 
		command += " -ns-switch " + resource[:name_server_switch] 
		command += " -nm-switch " + resource[:name_mapping_switch] 
	        command += " -rootvolume-security-style " + resource[:root_volume_security_style]
		output = ONTAPfunctions::connection(filerargs, command, results)
		if output.include? "Vserver:"
			Puppet.debug('vserver create ? -> true: vserver created sucessfully')
			true
		else
			Puppet.debug('vserver create ? -> failed: vserver created failed')
			false
		end
	end


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
