# encoding: utf-8
# copyright: 2021, Graham Land

title 'Verify VMware Packer Example Binaries'

packer_version = attribute('packer_version', value: 'Please set environment variable', description: 'Correct version of Packer binary to test for')
vagrant_version = attribute('vagrant_version', value: 'Please set environment variable', description: 'Correct version of Vagrant binary to test for')
consul_version = attribute('consul_version', value: 'Please set environment variable', description: 'Correct version of Consul binary to test for')
vault_version = attribute('vault_version', value: 'Please set environment variable', description: 'Correct version of Vault binary to test for')
nomad_version = attribute('nomad_version', value: 'Please set environment variable', description: 'Correct version of Nomad binary to test for')
nomad_autoscaler_version = attribute('nomad_autoscaler_version', value: 'Please set environment variable', description: 'Correct version of Nomad autoscaler binary to test for')
terraform_version = attribute('terraform_version', value: 'Please set environment variable', description: 'Correct version of Terraform binary to test for')
consul_template_version = attribute('consul_template_version', value: 'Please set environment variable', description: 'Correct version of Consul Template binary to test for')
envconsul_version = attribute('env_consul_version', value: 'Please set environment variable', description: 'Correct version of Env-Consul binary to test for')
golang_version = attribute('golang_version', value: 'Please set environment variable', description: 'Correct version of Go binary to test for')
envoy_version = attribute('envoy_version', value: 'Please set environment variable', description: 'Correct version of Envoy binary to test for')
waypoint_version = attribute('waypoint_version', value: 'Please set environment variable', description: 'Correct version of Waypoint binary to test for')
waypoint_entrypoint_version = attribute('waypoint_entrypoint_version', value: 'Please set environment variable', description: 'Correct version of Waypoint-Entrypoint binary to test for')
boundary_version = attribute('boundary_version', value: 'Please set environment variable', description: 'Correct version of Boundary binary to test for')

# control => test
control 'audit_installation_prerequisites' do
  impact 1.0
  title 'os and packages'
  desc 'verify os type and base os packages'

  describe os.family do
    it {should eq 'debian'}
  end

  describe package('wget') do
    it {should be_installed}
  end

  describe package('unzip') do
    it {should be_installed}
  end

  describe package('git') do
    it {should be_installed}
  end

  describe package('lynx') do
    it {should be_installed}
  end

  describe package('jq') do
    it {should be_installed}
  end

  describe package('curl') do
    it {should be_installed}
  end

  describe package('net-tools') do
    it {should be_installed}
  end

  describe package('open-vm-tools') do
    it {should be_installed}
  end

end

control 'consul-binary-exists-1.0' do         
  impact 1.0                      
  title 'consul binary exists'
  desc 'verify that the consul binary is installed'
  describe file('/usr/local/bin/consul') do 
    it { should exist }
  end
end

control 'consul-binary-version-1.0' do                      
  impact 1.0                                
  title 'consul binary version check'
  desc 'verify that the consul binary is the correct version'
  describe command('consul version') do
   its('stdout') { should match consul_version }
  end
end

# control 'waypoint-binary-exists-1.0' do         
#   impact 1.0                      
#   title 'waypoint binary exists'
#   desc 'verify that the waypoint binary is installed'
#   describe file('/usr/local/bin/waypoint') do 
#     it { should exist }
#   end
# end

# control 'waypoint-binary-version-1.0' do                      
#   impact 1.0                                
#   title 'waypoint binary version check'
#   desc 'verify that the waypoint binary is the correct version'
#   describe command('waypoint version') do
#    its('stdout') { should match waypoint_version }
#   end
# end

# control 'waypoint-entrypoint-binary-exists-1.0' do         
#   impact 1.0                      
#   title 'waypoint-entrypoint binary exists'
#   desc 'verify that the waypoint-entrypoint binary is installed'
#   describe file('/usr/local/bin/waypoint-entrypoint') do 
#     it { should exist }
#   end
# end

# control 'waypoint-entrypoint-binary-version-1.0' do                      
#   impact 1.0                                
#   title 'waypoint-entrypoint binary version check'
#   desc 'verify that the waypoint-entrypoint binary is the correct version'
#   describe command('waypoint-entrypoint version') do
#    its('stderr') { should match /starting interrupt listener/ }
#   end
# end

control 'boundary-binary-exists-1.0' do         
  impact 1.0                      
  title 'boundary binary exists'
  desc 'verify that the boundary binary is installed'
  describe file('/usr/local/bin/boundary') do 
    it { should exist }
  end
end

control 'boundary-binary-test-1.0' do                      
  impact 1.0                                
  title 'boundary binary functional check'
  desc 'verify that the boundary binary displays usage message'
  describe command('boundary version') do
   its('stdout') { should match boundary_version }
  end
end

control 'consul-template-binary-exists-1.0' do         
  impact 1.0                      
  title 'consul-template binary exists'
  desc 'verify that the consul-template binary is installed'
  describe file('/usr/local/bin/consul-template') do 
    it { should exist }
  end
end

control 'consul-template-binary-version-1.0' do                      
  impact 1.0                                
  title 'consul-template binary version check'
  desc 'verify that the consul-template binary is the correct version'
  describe command('/usr/local/bin/consul-template --version') do
    # its('stderr') { should match /0.23.0/ }
    its('exit_status') { should eq 0 }
  end
end

control 'envconsul-binary-exists-1.0' do         
  impact 1.0                      
  title 'envconsul binary exists'
  desc 'verify that the envconsul binary is installed'
  describe file('/usr/local/bin/envconsul') do 
    it { should exist }
  end
end

control 'envconsul-binary-version-1.0' do                      
  impact 1.0                                
  title 'envconsul binary version check'
  desc 'verify that the envconsul binary is the correct version'
  describe command('/usr/local/bin/envconsul --version') do
  #  its('stderr') { should match /0.9.1/ }
   its('exit_status') { should eq 0 }
  end
end

control 'vault-binary-exists-1.0' do         
  impact 1.0                      
  title 'vault binary exists'
  desc 'verify that the vault binary is installed'
  describe file('/usr/local/bin/vault') do 
    it { should exist }
  end
end

control 'vault-binary-version-1.0' do                      
  impact 1.0                                
  title 'vault binary version check'
  desc 'verify that the vault binary is the correct version'
  describe command('vault version') do
   its('stdout') { should match vault_version }
  end
end

control 'nomad-binary-exists-1.0' do         
  impact 1.0                      
  title 'nomad binary exists'
  desc 'verify that the nomad binary is installed'
  describe file('/usr/local/bin/nomad') do 
    it { should exist }
  end
end

control 'nomad-binary-version-1.0' do                      
  impact 1.0                                
  title 'nomad binary version check'
  desc 'verify that the nomad binary is the correct version'
  describe command('nomad version') do
   its('stdout') { should match nomad_version }
  end
end

control 'vagrant-binary-exists-1.0' do         
  impact 1.0                      
  title 'vagrant binary exists'
  desc 'verify that the vagrant binary is installed'
  describe file('/usr/local/bin/vagrant') do 
    it { should exist }
  end
end

control 'vagrant-binary-version-1.0' do                      
  impact 1.0                                
  title 'vagrant binary version check'
  desc 'verify that the vagrant binary is the correct version'
  describe command('vagrant --version') do
   its('stdout') { should match vagrant_version }
  end
end

control 'packer-binary-exists-1.0' do         
  impact 1.0                      
  title 'packer binary exists'
  desc 'verify that the packer binary is installed'
  describe file('/usr/local/bin/packer') do 
    it { should exist }
  end
end

control 'packer-binary-version-1.0' do                      
  impact 1.0                                
  title 'packer binary version check'
  desc 'verify that the packer binary is the correct version'
  describe command('packer version') do
   its('stdout') { should match packer_version }
  end
end

control 'packer-binary-exists-1.0' do         
  impact 1.0                      
  title 'packer binary exists'
  desc 'verify that the packer binary is installed'
  describe file('/usr/local/bin/packer') do 
    it { should exist }
  end
end

# control 'packer-binary-version-1.0' do                      
#   impact 1.0                                
#   title 'packer binary version check'
#   desc 'verify that the packer binary is the correct version'
#   describe command('packer version') do
#    its('stdout') { should match packer_version }
#   end
# end

control 'terraform-binary-exists-1.0' do         
  impact 1.0                      
  title 'terraform binary exists'
  desc 'verify that the terraform binary is installed'
  describe file('/usr/local/bin/terraform') do 
    it { should exist }
  end
end

control 'terraform-binary-version-1.0' do                      
  impact 1.0                                
  title 'terraform binary version check'
  desc 'verify that the terraform binary is the correct version'
  describe command('terraform version') do
   its('stdout') { should match terraform_version }
  end
end

control 'terraform-agent-binary-exists-1.0' do         
  impact 1.0                      
  title 'terraform agent binary exists'
  desc 'verify that the terraform binary is installed'
  describe file('/usr/local/bin/tfc-agent') do 
    it { should exist }
  end
end

control 'golang-exists-1.0' do         
  impact 1.0                      
  title 'golang exists'
  desc 'verify that golang is installed'
  describe file('/usr/local/go/bin/go') do 
    it { should exist }
  end
end

control 'golang-version-1.0' do                      
  impact 1.0                                
  title 'golang version check'
  desc 'verify that golang is the correct version'
  describe command('/usr/local/go/bin/go version') do
   its('stdout') { should match golang_version }
  end
end

# control 'envoy-exists-1.0' do         
#   impact 1.0                      
#   title 'envoy software exists'
#   desc 'verify that envoy is installed'
#   describe file('/usr/local/bin/envoy') do 
#     it { should exist }
#   end
# end

# control 'envoy-version-1.0' do                      
#   impact 1.0                                
#   title 'envoy version check'
#   desc 'verify that envoy is the correct version'
#   describe command('/usr/local/bin/envoy --version') do
#    its('stdout') { should match envoy_version }
#   end
# end