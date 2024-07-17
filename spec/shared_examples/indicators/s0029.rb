shared_examples 'S0029' do |params = {}|
  context 'when less than 90% connections' do
    before :each do
      allow(PuppetStatusCheck).to receive(:max_connections).and_return(10)
      allow(PuppetStatusCheck).to receive(:cur_connections).and_return(8)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when greater than 90% connections' do
    before :each do
      allow(PuppetStatusCheck).to receive(:max_connections).and_return(10)
      allow(PuppetStatusCheck).to receive(:cur_connections).and_return(10)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
