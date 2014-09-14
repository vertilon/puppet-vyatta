require 'spec_helper_acceptance'

describe 'homes defintion'do

  context 'valid user parameter' do

    it 'should work with no errors' do
      pp = <<-EOS
        $myuser = {
        'vyos' => { 'shell' => '/bin/bash' }
      }

      homes { 'vyos':
        user => $myuser
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
   end

   describe user('vyos') do
     it { should exist }
   end

   describe file('/home/vyos') do
     it { should be_directory }
   end
 end

end
