require 'spec_helper_acceptance'

describe 'Check configuration of system' do 
	it 'should check login info' do
		expect(on(:vyos, "grep vagrant /etc/passwd -c").output).to eq("1\n")
		expect(on(:vyos, "awk -F: '/vagrant/ {print $2}' /etc/shadow").output).to eq("$6$KTmBORI2IE5h/JU/$2U43VhF.JoTokAiJ9QYs8vf4f8M0.t7LFBYoYB77WAievBA9yZqD11cVtDq2RENXvAtqKtth.WVLVN5ZSIttm0\n")
		expect(on(:vyos, "awk '/vagrant/ {print $0}' /home/vagrant/.ssh/authorized_keys").output).to eq("ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant\n")
		expect(on(:vyos, "awk -F: '/vagrant/ {print $1}' /etc/group | grep adm -c").output).to eq("1\n")

	end
	
	it 'should check config-management info' do
		expect(on(:vyos, "/opt/vyatta/sbin/vyatta-config-gen-sets.pl | grep config-management").output).to eq("set system config-management commit-revisions '30'\n")
	end

	it 'should check ntp info' do
		expect(on(:vyos, "/opt/vyatta/sbin/vyatta-config-gen-sets.pl | grep ntp").output).to eq("set system ntp server '0.ua.pool.ntp.org'\nset system ntp server '1.ua.pool.ntp.org'\nset system ntp server '2.ua.pool.ntp.org'\nset system ntp server '3.ua.pool.ntp.org'\n")
	end

	it 'should check syslog info' do
		expect(on(:vyos, "/opt/vyatta/sbin/vyatta-config-gen-sets.pl | grep syslog").output).to eq("set system syslog global facility all level 'notice'\nset system syslog global facility protocols level 'debug'\n")
	end

	it 'should check package info' do
		expect(on(:vyos, "/opt/vyatta/sbin/vyatta-config-gen-sets.pl | grep package").output).to eq("set system package auto-sync '1'\nset system package repository community components 'main'\nset system package repository community distribution 'hydrogen'\nset system package repository community password ''\nset system package repository community url 'http://packages.vyos.net/vyos'\nset system package repository community username ''\n")
	end

end