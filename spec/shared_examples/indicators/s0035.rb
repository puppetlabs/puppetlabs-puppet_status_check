# frozen_string_literal: true

shared_examples 'S0035' do |params = {}|
  let(:cmd) { '/opt/puppetlabs/bin/puppet module list --tree' }

  context 'when no warnings' do
    before :each do
      allow(Puppet::Util::Execution).to receive(:execute).with(cmd, failonfail: false, combine: true).and_return('')
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when warning(s)' do
    before :each do
      allow(Puppet::Util::Execution).to receive(:execute).with(cmd, failonfail: false, combine: true).and_return('Warning: ')
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
