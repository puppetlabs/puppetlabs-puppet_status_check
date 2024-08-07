shared_examples 'S0021' do |params = {}|
  context 'when greater than 9% memory available' do
    before :each do
      allow(Facter).to receive(:value).and_call_original
      allow(Facter).to receive(:value).with(:memory).and_return(
        { 'system' => { 'capacity' => '10%' } },
      )
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when less than 9% memory available' do
    before :each do
      allow(Facter).to receive(:value).and_call_original
      allow(Facter).to receive(:value).with(:memory).and_return(
        { 'system' => { 'capacity' => '91%' } },
      )
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
