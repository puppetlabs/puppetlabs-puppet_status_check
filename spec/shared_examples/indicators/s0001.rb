shared_examples 'S0001' do |params = {}|
  context 'when puppet service running and enabled' do
    before :each do
      allow(PuppetStatusCheck).to receive(:service_running_enabled).with('puppet').and_return(true)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when puppet service not running or enabled' do
    before :each do
      allow(PuppetStatusCheck).to receive(:service_running_enabled).with('puppet').and_return(false)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
