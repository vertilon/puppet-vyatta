require 'spec_helper_acceptance'

describe 'Check configuration of services' do 
	it 'should check https configuration' do
		expect(on(:vyos, "/opt/vyatta/sbin/vyatta-config-gen-sets.pl | grep https").output).to eq("set service https http-redirect 'enable'\nset service https listen-address '192.168.21.1'\n")
	end

	it 'should check ssh configuration' do
		expect(on(:vyos, "/opt/vyatta/sbin/vyatta-config-gen-sets.pl | grep 'service ssh'").output).to eq("set service ssh port '22'\n")
	end
	
end