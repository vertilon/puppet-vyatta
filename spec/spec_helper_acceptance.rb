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
    hosts.each do |host|
      on host, "wget -qO - http://apt.puppetlabs.com/pubkey.gpg | sudo apt-key add -"
      on host, "echo \"deb http://mirrors.kernel.org/debian squeeze main contrib non-free\" >> /etc/apt/sources.list"
      on host, "echo \"deb http://backports.debian.org/debian-backports squeeze-backports main\" >> /etc/apt/sources.list"
      on host, "echo \"deb http://apt.puppetlabs.com squeeze main\" >> /etc/apt/sources.list"
      on host, "echo \"deb http://apt.puppetlabs.com squeeze dependencies\" >> /etc/apt/sources.list"
      on host, "sudo apt-get -y update"
      on host, "sudo apt-get -y install puppet facter"
      copy_module_to(host, :source => proj_root, :module_name => 'vyatta')
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-concat'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('config', 'set', 'pluginsync true --section main')
    end
  end
end
