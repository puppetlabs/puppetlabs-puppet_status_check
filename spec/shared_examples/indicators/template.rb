shared_examples 'XXXXX' do |params = {}|
  context 'TODO indicator positive check' do
    before :each do
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'TODO indicator negative check' do
    before :each do
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
