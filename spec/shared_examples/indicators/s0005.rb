shared_examples 'S0005' do |params = {}|
  before :each do
    Puppet[:cacert] = File.join(RSPEC_ROOT, 'fixtures/certs/localcacert')
  end

  context 'when cacert expires in 91 days' do
    before :each do
      # set current time to 91 days before certificate expires
      allow(Time).to receive(:now).and_return(cert_not_after(Puppet[:cacert]) - 7_862_000)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when cacert expires in 89 days' do
    before :each do
      # set current time to 89 days before certificate expires
      allow(Time).to receive(:now).and_return(cert_not_after(Puppet[:cacert]) - 7_690_000)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
