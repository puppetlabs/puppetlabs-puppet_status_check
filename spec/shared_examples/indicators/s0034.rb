shared_examples 'S0034' do |params = {}|
  let(:upgrade_file) { '/opt/puppetlabs/server/apps/puppetserver/bin/puppetserver' }

  context 'last upgraded 6 months ago' do
    before :each do
      allow(File).to receive(:exist?).with(upgrade_file).and_return(true)
      allow(File).to receive(:mtime).with(upgrade_file).and_return(Time.now - 15_770_000)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'last upgraded 1.5 years ago' do
    before :each do
      allow(File).to receive(:exist?).with(upgrade_file).and_return(true)
      allow(File).to receive(:mtime).with(upgrade_file).and_return(Time.now - 47_300_000)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
