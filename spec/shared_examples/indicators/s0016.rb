# frozen_string_literal: true

shared_examples 'S0016' do |params = {}|
  let(:logdir) { '/var/log/puppetlabs/puppetserver' }
  let(:err_pid) { File.join(logdir, 'puppetserver_err_pid.log') }
  let(:cmd) { "tail -n 250 #{File.join(logdir, 'puppetserver.log')} | grep 'java.lang.OutOfMemoryError'" }

  before :each do
    Puppet[:logdir] = '/var/log/puppetlabs/puppet'
    Puppet[:runinterval] = 1800
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(File.join(logdir, 'puppetserver.log')).and_return(true)
  end

  context 'when no err_pid.log and oom err not in puppetserver.log' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(logdir, '*_err_pid*.log')).and_return([])
      allow_any_instance_of(Kernel).to receive(:`).with(cmd).and_return('') # rubocop:disable RSpec/AnyInstance
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when no err_pid.log and oom err is in puppetserver.log' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(logdir, '*_err_pid*.log')).and_return([])
      allow_any_instance_of(Kernel).to receive(:`).with(cmd).and_return(['java.lang.OutOfMemoryError']) # rubocop:disable RSpec/AnyInstance
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  context 'when puppetserver.log is missing' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(logdir, '*_err_pid*.log')).and_return([])
      allow(File).to receive(:exist?).with(File.join(logdir, 'puppetserver.log')).and_return(false)
    end

    it 'does not run tail' do
      expect_any_instance_of(Kernel).not_to receive(:`).with(cmd) # rubocop:disable RSpec/AnyInstance
      puppet_status_check
    end

    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when puppetserver_err_pid.log exists' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(logdir, '*_err_pid*.log')).and_return([err_pid])
      allow(Time).to receive(:now).and_return(1800)
      allow(File).to receive(:mtime).with(err_pid).and_return(5)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
