require 'spec_helper_acceptance'

describe 'Check interfaces configuration' do 
	describe 'Ethernet: ' do
		it 'should set ip addresses' do
			pp = <<-EOS
			vyatta::interfaces::ethernet { 'eth0':
			  configuration => {
			    address => 'dhcp',
			    hw-id => \$macaddress_eth0,
			    }
			}
			vyatta::interfaces::ethernet { 'eth1':
			  configuration => {
			    'address 192.168.21.1/24' => '',
			    hw-id => \$macaddress_eth1,
			    speed => 'auto'
			  }
			}
			EOS
			apply_manifest(pp, :catch_failures => true)
			expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
		end
		it 'should check ip address' do
			expect(fact('ipaddress_eth1')).to eq("192.168.21.1")
		end
	end
end
