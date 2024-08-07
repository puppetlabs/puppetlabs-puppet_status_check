shared_examples 'S0003' do |params = {}|
  context 'when noop = false' do
    before :each do
      Puppet[:noop] = false
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when noop = true' do
    before :each do
      Puppet[:noop] = true
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
