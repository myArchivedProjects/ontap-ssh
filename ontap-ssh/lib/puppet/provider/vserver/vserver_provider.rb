require 'rubygems'
require 'net/ssh'

Puppet::Type.type(:vserver).provide(:vserver_provider) do
	desc 'manages netapp vservers'

	def exists?
		Net::SSH.start( resource[:cmgmt] , resource[:cuser], :password => resource[:cpass] ) do |ssh|
			        output = ssh.exec!("vserver show -vserver "+ resource[:name])
				if output.include? "Vserver:"
					puts "found vservermatch"
					true
				else
					puts "no matching vserver found"
					false
				end
		end
	end



	def create
		Net::SSH.start( resource[:cmgmt] , resource[:cuser], :password => resource[:cpass] ) do |ssh|
			        output = ssh.exec!("vserver create -vserver " + resource[:name] \
					+ " -rootvolume " + resource[:root_volume] \
				        + " -aggregate " + resource[:root_volume_aggregate] \
				        + " -ns-switch " + resource[:name_server_switch] \
				        + " -nm-switch " + resource[:name_mapping_switch] \
					+ " -rootvolume-security-style " + resource[:root_volume_security_style]) 
				if output.include? "Vserver:"
					puts "we did well"
					true
				else
					puts "failed miserably"
					false
				end
		end
	end


	def destroy

		Net::SSH.start( resource[:cmgmt] , resource[:cuser], :password => resource[:cpass] ) do |ssh|
			        output = ssh.exec!("volume show -vserver " + resource[:name]) 
				if output.match('online|restricted|offline')
					puts "Found a few"
					#lets kill them
					for x in output.scan(/\w.* (\w.*) \w.* online|restricted|offline/)
						puts "volumes: " + x.to_s()
			        		offline = ssh.exec!("volume offline -vserver " + resource[:name] \
								  + " -volume " + x.to_s() ) 
			        		destroy = ssh.exec!("volume destroy -vserver " + resource[:name] \
								  + " -volume " + x.to_s() \
								  + " -force "  ) 
					end#for volume offline,destroy
				end#if output.match

				#destroy the vservers
				output = ssh.exec!("vserver stop -vserver " + resource[:name]) 
			        output = ssh.exec!("vserver destroy -vserver " + resource[:name] ) 
				puts output
		end#ssh 

	end#def destroy



end
