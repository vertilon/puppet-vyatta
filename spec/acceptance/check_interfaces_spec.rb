require 'spec_helper_acceptance'

describe 'Check interfaces configuration' do 
	it 'should check eth1 ip address' do
		expect(fact_on :vyos, 'ipaddress_eth1').to eq("192.168.21.1")
	end
	it 'should check lo ip address' do
		expect(fact_on :vyos, 'ipaddress_lo').to eq("127.0.0.1")
	end
	it 'should check vtun0 ip address' do
		expect(fact_on :vyos, 'ipaddress_vtun0').to eq("10.8.0.6")
	end
end
