shared_examples 'S0012' do |params = {}|
  context 'produced a report during last run interval' do
    before :each do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(Puppet.settings[:lastrunfile]).and_return(true)
      allow(YAML).to receive(:load_file).with(Puppet.settings[:lastrunfile]).and_return({ 'time' => { 'last_run' => 1234 } })
      allow(Time).to receive(:now).and_return(1234)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'did not produce a report during last run interval' do
    before :each do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(Puppet.settings[:lastrunfile]).and_return(true)
      allow(YAML).to receive(:load_file).with(Puppet.settings[:lastrunfile]).and_return({ 'time' => { 'last_run' => 1234 } })
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
