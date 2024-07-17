shared_examples 'S0011' do |params = {}|
  context 'when postgres service running and enabled' do
    before :each do
      allow(PuppetStatusCheck).to receive(:postgres_service_name).and_return('postgresql@14-main')
      allow(PuppetStatusCheck).to receive(:service_running_enabled).and_return(true)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when postgres service is not running and enabled' do
    before :each do
      allow(PuppetStatusCheck).to receive(:postgres_service_name).and_return('postgresql@14-main')
      allow(PuppetStatusCheck).to receive(:service_running_enabled).and_return(false)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
