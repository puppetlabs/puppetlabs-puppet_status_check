shared_examples 'S0024' do |params = {}|
  let(:discard_dir) { '/opt/puppetlabs/server/data/puppetdb/stockpile/discard' }
  let(:testfile) { File.join(discard_dir, 'test_file') }

  context 'when discard older than runinterval*2' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(discard_dir, '*.*')).and_return([testfile])
      allow(Time).to receive(:now).and_return(Time.at(1_722_959_790))
      allow(File).to receive(:mtime).with(testfile).and_return(Time.at(1_722_959_790) - (Puppet.settings['runinterval'] * 3))
      Puppet[:runinterval] = 1_800
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when no discard' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(discard_dir, '*.*')).and_return([])
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when discard sooner than runinterval*2' do
    before :each do
      allow(Dir).to receive(:glob).with(File.join(discard_dir, '*.*')).and_return([testfile])
      allow(Time).to receive(:now).and_return(Time.at(1_722_959_790))
      allow(File).to receive(:mtime).with(testfile).and_return(Time.at(1_722_959_790) - Puppet.settings['runinterval'])
      Puppet[:runinterval] = 1_800
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
