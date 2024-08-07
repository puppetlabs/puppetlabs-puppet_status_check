shared_examples 'S0004' do |params = {}|
  before :each do
    Puppet[:hostprivkey] = File.join(RSPEC_ROOT, 'fixtures/certs/hostprivkey')
    Puppet[:hostcert] = File.join(RSPEC_ROOT, 'fixtures/certs/hostcert')
    Puppet[:localcacert] = File.join(RSPEC_ROOT, 'fixtures/certs/localcacert')
  end

  after :each do
    WebMock.reset!
  end

  context 'when status endpoint returns no service errors' do
    let(:body) do
      {
        'puppet-profiler' => { 'state' => 'running' },
        'jruby-metrics'   => { 'state' => 'running' },
        'ca'              => { 'state' => 'running' },
        'master'          => { 'state' => 'running' },
        'server'          => { 'state' => 'running' },
      }
    end

    before :each do
      stub_request(:get, "https://#{Puppet[:certname]}:8140/status/v1/services")
        .to_return(body: body.to_json, status: 200)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'when status endpoint returns service errors' do
    let(:body) do
      {
        'puppet-profiler' => { 'state' => 'error' },
        'jruby-metrics'   => { 'state' => 'error' },
        'ca'              => { 'state' => 'error' },
        'master'          => { 'state' => 'error' },
        'server'          => { 'state' => 'error' },
      }
    end

    before :each do
      stub_request(:get, "https://#{Puppet[:certname]}:8140/status/v1/services")
        .to_return(body: body.to_json, status: 200)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
