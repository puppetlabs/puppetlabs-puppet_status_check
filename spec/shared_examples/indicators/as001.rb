shared_examples 'AS001' do |params = {}|
  before :each do
    Puppet[:hostcert] = File.join(RSPEC_ROOT, 'fixtures/certs/hostcert')
  end

  context 'when hostcert expires in 91 days' do
    before :each do
      # set current time to 91 days before certificate expires
      allow(Time).to receive(:now).and_return(cert_not_after(Puppet[:hostcert]) - 7_862_000)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when hostcert expires in 89 days' do
    before :each do
      # set current time to 89 days before certificate expires
      allow(Time).to receive(:now).and_return(cert_not_after(Puppet[:hostcert]) - 7_690_000)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
