shared_examples 'S0026' do |params = {}|
  before :each do
    Puppet[:hostprivkey] = File.join(RSPEC_ROOT, 'fixtures/certs/hostprivkey')
    Puppet[:hostcert] = File.join(RSPEC_ROOT, 'fixtures/certs/hostcert')
    Puppet[:localcacert] = File.join(RSPEC_ROOT, 'fixtures/certs/localcacert')
  end

  after :each do
    WebMock.reset!
  end

  context 'when puppetserver jvm heap 33GB' do
    let(:body) do
      { 'status': { 'experimental': { 'jvm-metrics': { 'heap-memory': {
        'init': 33_000_000_000,
      } } } } }
    end

    before :each do
      stub_request(:get, "https://#{Puppet[:certname]}:8140/status/v1/services/status-service?level=debug")
        .to_return(body: body.to_json, status: 200)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when puppetserver jvm heap 52GB' do
    let(:body) do
      { 'status': { 'experimental': { 'jvm-metrics': { 'heap-memory': {
        'init': 52_000_000_000,
      } } } } }
    end

    before :each do
      stub_request(:get, "https://#{Puppet[:certname]}:8140/status/v1/services/status-service?level=debug")
        .to_return(body: body.to_json, status: 200)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when puppetserver jvm heap 44GB' do
    let(:body) do
      { 'status': { 'experimental': { 'jvm-metrics': { 'heap-memory': {
        'init': 44_000_000_000,
      } } } } }
    end

    before :each do
      stub_request(:get, "https://#{Puppet[:certname]}:8140/status/v1/services/status-service?level=debug")
        .to_return(body: body.to_json, status: 200)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
