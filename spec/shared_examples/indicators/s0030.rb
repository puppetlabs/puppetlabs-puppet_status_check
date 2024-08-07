shared_examples 'S0030' do |params = {}|
  context 'when use_cached_catalog = false' do
    before :each do
      Puppet[:use_cached_catalog] = false
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when use_cached_catalog = true' do
    before :each do
      Puppet[:use_cached_catalog] = true
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
