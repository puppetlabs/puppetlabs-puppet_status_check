# frozen_string_literal: true

shared_examples 'XXXXX' do |params = {}|
  context 'when the indicator passes' do
    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when the indicator fails' do
    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
