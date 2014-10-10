require 'spec_helper_acceptance'

describe 'Run manifest with configuration' do 
	it 'should apply manifest' do
		pp = <<-EOS
		class { 'vyatta':
		  configuration_file => '/tmp/vytta.conf'
		}

		vyatta::service::ssh { 'ssh':
		  configuration => {
		    port => 22
		  }
		}

		vyatta::service::https{ 'https':
			configuration => {
				listen-address => '192.168.21.1',
				http-redirect => 'enable'
			}
		}

		vyatta::service::webproxy{ 'webproxy':
			configuration => {
				'listen-address 192.168.21.1' => {
					disable-transparent => '',
					port => '2050'
				},
				url-filtering => {
					squidguard => {
						local-block => 'myspace.com'
					}
				}

			}
		}
		
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
		
		vyatta::interfaces::loopback { 'lo':
		  configuration => {
		    address => '127.0.0.1/32'
		  }
		}
		
		vyatta::interfaces::openvpn { 'vtun0':
		  configuration => {
		    mode => 'client',
		    remote-host => '192.168.21.20',
		    tls => {
		    	ca-cert-file => '/config/auth/ca.crt',
		    	cert-file => '/config/auth/agent.crt',
		    	key-file => '/config/auth/agent.key'
		    }
		  }
		}
		
		vyatta::system::login { 'login':
		  configuration => {
		    'user vagrant' => {
			  authentication => {
			    encrypted-password => '$6$KTmBORI2IE5h/JU/$2U43VhF.JoTokAiJ9QYs8vf4f8M0.t7LFBYoYB77WAievBA9yZqD11cVtDq2RENXvAtqKtth.WVLVN5ZSIttm0',
				'public-keys vagrant' => {
				  key => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==',
				  type => 'ssh-rsa'
				}
			  },
			  level => 'admin'
			}
		  }
		}

		vyatta::system::config-management{ 'config-management':
			configuration => {
				commit-revisions => '30'
			}
		}

		vyatta::system::ntp{ 'ntp':
			configuration => {
				"server '0.ua.pool.ntp.org'" => {},
				"server '1.ua.pool.ntp.org'" => {},
				"server '2.ua.pool.ntp.org'" => {},
				"server '3.ua.pool.ntp.org'" => {}
			}
		}

		vyatta::system::syslog{ 'syslog':
			configuration => {
				global => {
					'facility all' => {
						level => 'notice'
					},
					'facility protocols' => {
						level => 'debug'
					}
				}
			}
		}

		vyatta::system::package{ 'package':
			configuration => {
				auto-sync => "1",
				'repository community' => {
					components => 'main',
					distribution => 'hydrogen',
					password => '',
					url => 'http://packages.vyos.net/vyos',
					username => ''
				}
			}
		}

		vyatta::policy::access_list { '110':
		  configuration => {
		    description => '"Access list description"',
		    'rule 10' => {
		      action => 'permit',
		      description => '"Rule 10 description."',
		      destination => {
		        any => '',
		      },
		      source => {
		        inverse-mask => '0.0.0.63',
		        network => '145.21.240.0'
		      }
		    }
		  }
		}

		vyatta::policy::prefix_list { 'PREFIX-LIST':
		  configuration => {
		    'rule 1' => {
		      action => 'permit',
		      prefix => '192.168.0.0/16'
		    },
		    'rule 2' => {
		      action => 'permit',
		      description => '"Rule 2 description."',
		      le => '15',
		      prefix => '172.16.0.0/16'
		    },
		    'rule 3' => {
		      action => 'permit',
		      description => '"Rule 3 description."',
		      le => '17',
		      prefix => '10.10.0.0/16'
		    },
		  }
		}

		vyatta::policy::route_map { 'ROUTE-MAP':
		  configuration => {
		    description => '"Route-map description."',
		    'rule 1' => {
		      action => 'permit',
		      description => '"Rule 1 description."',
		      match => {
		        ip => {
		          address => {
		            prefix-list => 'PREFIX-LIST'
		          }
		        }
		      }
		    }
		  }
		}

		vyatta::protocols::bgp { '65000':
		  configuration => {
		    'neighbor 192.168.21.10' => {
		      'remote-as' => '65001',
		      'update-source' => '192.168.21.1'
		    },
		    'neighbor 192.168.21.20' => {
		      'remote-as' => '65002',
		      'update-source' => '192.168.21.1'
		    },
		    'network 192.168.21.0/24' => {
		      backdoor => ''
		    },
		    'network 192.168.21.0/24' => {
		      route-map => 'ROUTE-MAP'
		    },
		    'network 192.168.21.0/24' => {
		    },
		    parameters => {
		      router-id => '192.168.21.1'
		    },
		    redistribute => {
		      connected => {
		        metric => '1',
		      },
		      ospf => {
		      },
		      rip => {
		        route-map => 'ROUTE-MAP'
		      },
		      static => {
		        metric => '1',
		        route-map => 'ROUTE-MAP'
		      }
		    }
		  }
		}

		vyatta::protocols::ospf { 'ospf':
		  configuration => {
		    'area 0.0.0.0' => {
		      'network 192.168.21.0/24' => '',
		      'network 192.168.21.0/24' => ''
		    },
		    default-information => {
		      originate => {
		        metric-type => '2'
		      }
		    },
		    parameters => {
		      abr-type => 'cisco',
		      router-id => '192.168.21.1'
		    },
		    'passive-interface default' => '',
		    'passive-interface-exclude eth0' => '',
		    'passive-interface-exclude eth1' => '',
		    redistribute => {
		      bgp => {
		        metric-type => '2',
		      },
		      connected => {
		        metric => '1',
		        metric-type => '2'
		      },
		      rip => {
		        route-map => 'ROUTE-MAP'
		      },
		      static => {
		        metric => '1',
		        metric-type => '2',
		        route-map => 'ROUTE-MAP'
		      }
		    }
		  }
		}

		EOS
		# agents.each do |agent|
		apply_manifest_on(:vyos, pp)
		expect(apply_manifest_on(:vyos ,pp).exit_code).to be_zero
		# end
	end
end