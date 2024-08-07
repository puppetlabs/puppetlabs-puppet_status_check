shared_examples 'S0035' do |params = {}|
  let(:cmd) { '/opt/puppetlabs/bin/puppet module list --tree 2>&1' }

  context 'when no warnings' do
    before :each do
      allow_any_instance_of(Kernel).to receive(:`).with(cmd).and_return('') # rubocop:disable RSpec/AnyInstance
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when warning(s)' do
    before :each do
      allow_any_instance_of(Kernel).to receive(:`).with(cmd).and_return('Warning: ') # rubocop:disable RSpec/AnyInstance
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
