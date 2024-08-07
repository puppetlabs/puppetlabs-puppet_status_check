shared_examples 'S0014' do |params = {}|
  let(:stockpile) { '/opt/puppetlabs/server/data/puppetdb/stockpile/cmd/q' }
  let(:testfile) { File.join(stockpile, 'test_file') }

  context 'when queue younger than runinterval' do
    before :each do
      allow(Dir).to receive(:glob).and_call_original
      allow(Dir).to receive(:glob).with(File.join(stockpile, '*')).and_return([testfile])
      allow(Time).to receive(:now).and_return(1800)
      Puppet[:runinterval] = 1800
      allow(File).to receive(:mtime).with(testfile).and_return(100)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when no queue' do
    before :each do
      allow(Dir).to receive(:glob).and_call_original
      allow(Dir).to receive(:glob).with(File.join(stockpile, '*')).and_return([])
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when queue older than runinterval' do
    before :each do
      allow(Dir).to receive(:glob).and_call_original
      allow(Dir).to receive(:glob).with(File.join(stockpile, '*')).and_return([testfile])
      allow(Time).to receive(:now).and_return(5400)
      Puppet[:runinterval] = 1800
      allow(File).to receive(:mtime).with(testfile).and_return(100)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
