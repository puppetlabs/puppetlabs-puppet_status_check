shared_examples 'S0007' do |params = {}|
  let(:datadir) { '/var/lib/postgresql/14/main' }
  context 'More than 20% disk free PostgreSQL data partition' do
    before :each do
      allow(PuppetStatusCheck).to receive(:pg_data_dir).and_return(datadir)
      allow(PuppetStatusCheck).to receive(:filesystem_free).with(datadir).and_return(21)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'Less than 20% disk free PostgreSQL data partition' do
    before :each do
      allow(PuppetStatusCheck).to receive(:pg_data_dir).and_return(datadir)
      allow(PuppetStatusCheck).to receive(:filesystem_free).with(datadir).and_return(19)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
