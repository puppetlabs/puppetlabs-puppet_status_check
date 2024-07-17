shared_examples 'S0033' do |params = {}|
  context 'with hiera5 config' do
    before :each do
      Puppet[:hiera_config] = File.join(RSPEC_ROOT, 'fixtures/hiera/hiera5.yaml')
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'with hiera3 config' do
    before :each do
      Puppet[:hiera_config] = File.join(RSPEC_ROOT, 'fixtures/hiera/hiera3.yaml')
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
