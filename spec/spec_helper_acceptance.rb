require 'beaker-rspec'
require 'pry'


RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
#    puppet_module_install(:source => proj_root, :module_name => 'mysql')
    
      on agents, "wget -qO - http://apt.puppetlabs.com/pubkey.gpg | sudo apt-key add -"
      on agents, "echo \"deb http://mirrors.kernel.org/debian squeeze main contrib non-free\" >> /etc/apt/sources.list"
      on agents, "echo \"deb http://backports.debian.org/debian-backports squeeze-backports main\" >> /etc/apt/sources.list"
      on agents, "echo \"deb http://apt.puppetlabs.com squeeze main\" >> /etc/apt/sources.list"
      on agents, "echo \"deb http://apt.puppetlabs.com squeeze dependencies\" >> /etc/apt/sources.list"
      on agents, "sudo apt-get -y update"
      on agents, "sudo apt-get -y install puppet facter"
      agents.each do |agent|
        copy_module_to(agent, :source => proj_root, :module_name => 'vyatta')
      end
      on agents, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on agents, puppet('module','install','puppetlabs-concat'), { :acceptable_exit_codes => [0,1] }
      on agents, puppet('config', 'set', 'pluginsync true --section main')
#      on agents, "echo '\n\n' | /opt/vyatta/bin/sudo-users/vyatta-sg-blacklist.pl --update-blacklist"
      # Install openvpn server on master
      run_script "spec/openvpn-installing-script.sh", { :acceptable_exit_codes => [0,1] }
   

      #Copy certificates from server to agents
      scp_from master, '/etc/openvpn/ca.crt', 'ca.crt'
      scp_from master, '/etc/openvpn/easy-rsa/keys/agent.crt', 'agent.crt'
      scp_from master, '/etc/openvpn/easy-rsa/keys/agent.key', 'agent.key'
      scp_to agents, 'ca.crt/ca.crt', '/config/auth/'
      scp_to agents, 'agent.crt/agent.crt', '/config/auth/'
      scp_to agents, 'agent.key/agent.key', '/config/auth/'
      on agents, "sudo sed -i 's/BEGIN RSA PRIVATE KEY/BEGIN PRIVATE KEY/' /opt/vyatta/share/perl5/Vyatta/OpenVPN/Config.pm"
  end
end
