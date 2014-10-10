require 'spec_helper_acceptance'

describe 'Check configuration of services' do 
	it 'should check https configuration' do
		expect(on(:vyos, "/opt/vyatta/sbin/vyatta-config-gen-sets.pl | grep https").output).to eq("set service https http-redirect 'enable'\nset service https listen-address '192.168.21.1'\n")
	end

	it 'should check ssh configuration' do
		expect(on(:vyos, "/opt/vyatta/sbin/vyatta-config-gen-sets.pl | grep 'service ssh'").output).to eq("set service ssh port '22'\n")
	end
	
	it 'should check webproxy configuration' do
		expect(on(:vyos, "/opt/vyatta/sbin/vyatta-config-gen-sets.pl | grep webproxy").output).to eq("set service webproxy listen-address 192.168.21.1 'disable-transparent'\nset service webproxy listen-address 192.168.21.1 port '2050'\nset service webproxy url-filtering squidguard local-block 'myspace.com'\n")
	end

	it 'should check webproxy is working' do
		expect(on(:openvpn, "http_proxy=192.168.21.1:2050 wget myspace.com").output).to include("google.com")
	end

end