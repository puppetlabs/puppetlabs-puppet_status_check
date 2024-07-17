shared_examples 'S0036' do |params = {}|
  let(:server_config_file) { '/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf' }

  context 'with max-queued-requests set to 150' do
    before :each do
      allow(File).to receive(:read).with(server_config_file).and_return(%(
        jruby-puppet: {
            max-queued-requests: 150
        }
      ))
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'with max-queued-requests set to 152' do
    before :each do
      allow(File).to receive(:read).with(server_config_file).and_return(%(
        jruby-puppet: {
            max-queued-requests: 152
        }
      ))
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
