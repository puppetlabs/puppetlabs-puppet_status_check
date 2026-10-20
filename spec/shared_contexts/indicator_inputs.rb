# frozen_string_literal: true

shared_context 'with indicator inputs' do
  before :each do
    Puppet[:hostcert] = File.join(RSPEC_ROOT, 'fixtures/certs/hostcert')
    Puppet[:hostprivkey] = File.join(RSPEC_ROOT, 'fixtures/certs/hostprivkey')
    Puppet[:localcacert] = File.join(RSPEC_ROOT, 'fixtures/certs/localcacert')
    Puppet[:cacert] = File.join(RSPEC_ROOT, 'fixtures/certs/localcacert')
    Puppet[:hostcrl] = File.join(RSPEC_ROOT, 'fixtures/certs/cacrl')
    Puppet[:cacrl] = File.join(RSPEC_ROOT, 'fixtures/certs/cacrl')
    Puppet[:hiera_config] = File.join(RSPEC_ROOT, 'fixtures/hiera/hiera5.yaml')

    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(Puppet[:lastrunfile]).and_return(true)
    allow(YAML).to receive(:load_file).and_call_original
    allow(YAML).to receive(:load_file).with(Puppet[:lastrunfile]).and_return('time' => { 'last_run' => Time.now.to_i, 'catalog_application' => 1.0 })
  end

  before :each do
    access_log = File.join(File.dirname(Puppet[:logdir]), 'puppetserver/puppetserver-access.log')
    upgrade_file = '/opt/puppetlabs/server/apps/puppetserver/bin/puppetserver'

    allow(File).to receive(:exist?).with(access_log).and_return(true)
    allow(File).to receive(:foreach).with(access_log).and_return([])
    allow(File).to receive(:exist?).with(upgrade_file).and_return(true)
    allow(File).to receive(:mtime).with(upgrade_file).and_return(Time.now)
    allow(File).to receive(:read).and_call_original
    allow(File).to receive(:read).with('/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf').and_return('max-queued-requests: 150')
  end
end
