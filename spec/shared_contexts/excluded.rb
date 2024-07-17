shared_context 'excluded' do |params = {}|
  before :each do
    config(role: params[:role], indicator_exclusions: [params[:indicator]])
  end

  # When one or more indicators are enabled, the fact should be a hash.
  # Otherwise the fact will be nil
  it { is_expected.not_to have_key(params[:indicator]) }
  # Since we are only excluding the one specific indicator
  # there should be a hash not nil
end
