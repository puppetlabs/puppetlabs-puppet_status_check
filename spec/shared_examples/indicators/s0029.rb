# frozen_string_literal: true

shared_examples 'S0029' do |params = {}|
  context 'when less than 90% connections' do
    before :each do
      allow(PuppetStatusCheck).to receive_messages(max_connections: 10, cur_connections: 8)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when greater than 90% connections' do
    before :each do
      allow(PuppetStatusCheck).to receive_messages(max_connections: 10, cur_connections: 10)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
