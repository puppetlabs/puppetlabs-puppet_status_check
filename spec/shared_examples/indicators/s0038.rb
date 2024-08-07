shared_examples 'S0038' do |params = {}|
  before :each do
    Puppet[:hostprivkey] = File.join(RSPEC_ROOT, 'fixtures/certs/hostprivkey')
    Puppet[:hostcert] = File.join(RSPEC_ROOT, 'fixtures/certs/hostcert')
    Puppet[:localcacert] = File.join(RSPEC_ROOT, 'fixtures/certs/localcacert')
  end

  after :each do
    WebMock.reset!
  end

  context 'with 99 environments' do
    let(:body) do
      (1..99).each_with_object({ 'environments' => {} }) do |i, h|
        h['environments']["env_#{i}"] = {}
      end
    end

    before :each do
      stub_request(:get, "https://#{Puppet[:certname]}:8140/puppet/v3/environments")
        .to_return(body: body.to_json, status: 200)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => true) }
  end

  context 'with 101 environments' do
    let(:body) do
      (1..101).each_with_object({ 'environments' => {} }) do |i, h|
        h['environments']["env_#{i}"] = {}
      end
    end

    before :each do
      stub_request(:get, "https://#{Puppet[:certname]}:8140/puppet/v3/environments")
        .to_return(body: body.to_json, status: 200)
    end

    it { is_expected.to have_key(params[:indicator]) }
    it { is_expected.to include(params[:indicator] => false) }
  end

  describe 'when excluded' do
    include_context 'excluded', params
  end
end
