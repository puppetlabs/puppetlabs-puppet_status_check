shared_examples 'S0010' do |params = {}|
  context 'when puppetdb service running' do
    before :each do
      allow(PuppetStatusCheck).to receive(:service_running_enabled).with('puppetdb').and_return(true)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when puppetdb service not running' do
    before :each do
      allow(PuppetStatusCheck).to receive(:service_running_enabled).with('puppetdb').and_return(false)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
