shared_examples 'S0039' do |params = {}|
  let(:logfile) { File.join(File.dirname(Puppet.settings['logdir']), 'puppetserver/puppetserver-access.log') }
  let(:timestamp) { '[06/Aug/2024:03:16:12 +0000]' }

  context 'when no 503s in log' do
    before :each do
      allow(File).to receive(:exist?).with(logfile).and_return(true)
      allow(File).to receive(:foreach).with(logfile).and_return(["1.2.3.4 - - #{timestamp} \"GET /status/v1/services HTTP/1.1\" 200 172 \"-\" \"Ruby\" 9 - -"])
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when 503 in log before runinterval' do
    before :each do
      allow(File).to receive(:exist?).with(logfile).and_return(true)
      allow(File).to receive(:foreach).with(logfile).and_return(["1.2.3.4 - - #{timestamp} \"GET /status/v1/services HTTP/1.1\" 503 172 \"-\" \"Ruby\" 9 - -"])
      allow(Time).to receive(:now).and_return(Time.strptime(timestamp, '[%d/%b/%Y:%H:%M:%S %Z]'))
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  context 'when 503 in log after runinterval' do
    before :each do
      allow(File).to receive(:exist?).with(logfile).and_return(true)
      allow(File).to receive(:foreach).with(logfile).and_return(["1.2.3.4 - - #{timestamp} \"GET /status/v1/services HTTP/1.1\" 503 172 \"-\" \"Ruby\" 9 - -"])
      allow(Time).to receive(:now).and_return(Time.strptime(timestamp, '[%d/%b/%Y:%H:%M:%S %Z]') + (Puppet.settings['runinterval'] * 2))
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
