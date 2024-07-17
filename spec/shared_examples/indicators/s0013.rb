shared_examples 'S0013' do |params = {}|
  context 'catalog successfully applied last run' do
    before :each do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(Puppet.settings[:lastrunfile]).and_return(true)
      allow(YAML).to receive(:load_file).with(Puppet.settings[:lastrunfile]).and_return({ 'time' => { 'catalog_application' => 1234 } })
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'catalog unsuccessfully applied last run' do
    before :each do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(Puppet.settings[:lastrunfile]).and_return(true)
      allow(YAML).to receive(:load_file).with(Puppet.settings[:lastrunfile]).and_return({ 'time' => {} })
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
