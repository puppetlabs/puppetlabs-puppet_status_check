shared_examples 'AS003' do |params = {}|
  context 'when certname in agent section' do
    before :each do
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :agent).and_return(true)
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :server).and_return(false)
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :user).and_return(false)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  context 'when certname in server section' do
    before :each do
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :agent).and_return(false)
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :server).and_return(true)
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :user).and_return(false)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  context 'when certname in user section' do
    before :each do
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :agent).and_return(false)
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :server).and_return(false)
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :user).and_return(true)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  context 'when certname only in main section' do
    before :each do
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :agent).and_return(false)
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :server).and_return(false)
      allow(Puppet.settings).to receive(:set_in_section?).with(:certname, :user).and_return(false)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
