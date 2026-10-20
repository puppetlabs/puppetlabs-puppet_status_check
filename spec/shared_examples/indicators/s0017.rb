# frozen_string_literal: true

shared_examples 'S0017' do |params = {}|
  let(:logdir) { '/var/log/puppetlabs/puppetdb' }
  let(:err_pid) { File.join(logdir, 'puppetdb_err_pid.log') }
  let(:log_file) { File.join(logdir, 'puppetdb.log') }

  before :each do
    Puppet[:logdir] = '/var/log/puppetlabs/puppet'
    Puppet[:runinterval] = 1800
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with(File.join(logdir, 'puppetdb.log')).and_return(true)
  end

  context 'when no err_pid.log and oom err not in puppetdb.log' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(logdir, '*_err_pid*.log')).and_return([])
      allow(PuppetStatusCheck).to receive(:log_tail_contains?).with(log_file, %r{java.lang.OutOfMemoryError}).and_return(false)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when no err_pid.log and oom err is in puppetdb.log' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(logdir, '*_err_pid*.log')).and_return([])
      allow(PuppetStatusCheck).to receive(:log_tail_contains?).with(log_file, %r{java.lang.OutOfMemoryError}).and_return(true)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  context 'when puppetdb.log is missing' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(logdir, '*_err_pid*.log')).and_return([])
      allow(File).to receive(:exist?).with(File.join(logdir, 'puppetdb.log')).and_return(false)
    end

    it 'does not read the log' do
      expect(PuppetStatusCheck).not_to receive(:log_tail_contains?)
      puppet_status_check
    end

    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when puppetdb_err_pid.log exists' do
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
