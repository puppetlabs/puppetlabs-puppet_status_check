shared_examples 'S0008' do |params = {}|
  context 'when codedir has 21% disk free' do
    before :each do
      allow(PuppetStatusCheck).to receive(:filesystem_free).and_return(21)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when codedir has 19% disk free' do
    before :each do
      allow(PuppetStatusCheck).to receive(:filesystem_free).and_return(19)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
