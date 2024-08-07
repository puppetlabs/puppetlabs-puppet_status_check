shared_examples 'S0017' do |params = {}|
  let(:logdir) { '/var/log/puppetlabs/puppetdb' }
  let(:err_pid) { File.join(logdir, 'puppetdb_err_pid.log') }
  let(:cmd) { "tail -n 250 #{File.join(logdir, 'puppetdb.log')} | grep 'java.lang.OutOfMemoryError'" }

  before :each do
    Puppet[:logdir] = '/var/log/puppetlabs/puppet'
    Puppet[:runinterval] = 1800
  end

  context 'when no err_pid.log and oom err not in puppetdb.log' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(logdir, '*_err_pid*.log')).and_return([])
      allow_any_instance_of(Kernel).to receive(:`).with(cmd).and_return('') # rubocop:disable RSpec/AnyInstance
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when no err_pid.log and oom err is in puppetdb.log' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(logdir, '*_err_pid*.log')).and_return([])
      allow_any_instance_of(Kernel).to receive(:`).with(cmd).and_return(['java.lang.OutOfMemoryError']) # rubocop:disable RSpec/AnyInstance
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
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
