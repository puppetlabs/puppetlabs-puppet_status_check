shared_examples 'S0045' do |params = {}|
  before :each do
    Puppet[:hostprivkey] = File.join(RSPEC_ROOT, 'fixtures/certs/hostprivkey')
    Puppet[:hostcert] = File.join(RSPEC_ROOT, 'fixtures/certs/hostcert')
    Puppet[:localcacert] = File.join(RSPEC_ROOT, 'fixtures/certs/localcacert')
  end

  after :each do
    WebMock.reset!
  end

  context 'with 11 jrubies' do
    let(:body) do
      {
        'status' => { 'experimental' => { 'metrics' => {
          'num-jrubies' => 11
        } } }
      }
    end

    before :each do
      stub_request(:get, "https://#{Puppet[:certname]}:8140/status/v1/services/jruby-metrics?level=debug")
        .to_return(body: body.to_json, status: 200)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'with 13 jrubies' do
    let(:body) do
      {
        'status' => { 'experimental' => { 'metrics' => {
          'num-jrubies' => 13
        } } }
      }
    end

    before :each do
      stub_request(:get, "https://#{Puppet[:certname]}:8140/status/v1/services/jruby-metrics?level=debug")
        .to_return(body: body.to_json, status: 200)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
