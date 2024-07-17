require 'spec_helper'

describe 'Fact puppet_status_check', type: :fact do
  subject(:puppet_status_check) { Facter.value(:puppet_status_check) }

  after :each do
    Facter.clear
    Facter.clear_messages
  end

  # Use in 'before' blocks of a context to change configuration
  def config(role: 'agent', indicator_exclusions: [], pg_config: 'pg_config', postgresql_service: 'postgresql')
    allow(PuppetStatusCheck).to receive(:config).and_call_original
    allow(PuppetStatusCheck).to receive(:config).with('role').and_return(role)
    allow(PuppetStatusCheck).to receive(:config).with('indicator_exclusions').and_return(indicator_exclusions)
    allow(PuppetStatusCheck).to receive(:config).with('pg_config').and_return(pg_config)
    allow(PuppetStatusCheck).to receive(:config).with('postgresql_service').and_return(postgresql_service)
  end

  # Helpers for each roles indicators
  indicators = {
    agent: ['AS003', 'S0001', 'S0003', 'S0021', 'S0030'],
    compiler: [
      'AS001', 'AS003', 'AS004', 'S0001', 'S0003', 'S0004', 'S0008',
      'S0009', 'S0010', 'S0012', 'S0013', 'S0016', 'S0017', 'S0019',
      'S0021', 'S0024', 'S0026', 'S0027', 'S0030', 'S0033', 'S0035',
      'S0036', 'S0038', 'S0039', 'S0045'
    ],
    postgres: [
      'AS001', 'AS003', 'AS004', 'S0001', 'S0003', 'S0007', 'S0011',
      'S0012', 'S0013', 'S0014', 'S0021', 'S0029', 'S0030'
    ],
    primary: [
      'AS001', 'AS003', 'AS004', 'S0001', 'S0003', 'S0004', 'S0005',
      'S0007', 'S0008', 'S0009', 'S0010', 'S0011', 'S0012', 'S0013',
      'S0014', 'S0016', 'S0017', 'S0019', 'S0021', 'S0023', 'S0024',
      'S0026', 'S0027', 'S0029', 'S0030', 'S0033', 'S0034', 'S0035',
      'S0036', 'S0038', 'S0039', 'S0045'
    ]
  }

  indicators.each_key do |role|
    context "when role => #{role}" do
      before :each do
        # create generic stub for webmock
        stub_request(:any, %r{.*})
      end

      context 'with default configuration' do
        before :each do
          config(role: role.to_s)
        end

        it { is_expected.to be_a(Hash) }
        # Check that each indicator is in the result by default
        it do
          raise 'The puppet_status_check fact returned a nil value!' if puppet_status_check.nil?
          expect(puppet_status_check.keys.count).to eql(indicators[role].count),
            "The #{indicators[role] - puppet_status_check.keys} indicator(s) returned a nil value. facts['puppet_status_check'] => #{puppet_status_check}"
        end
      end

      indicators[role].each do |indicator|
        context "indicator => #{indicator}" do
          before :each do
            # configure the role and exclude all indicators except for the one being tested
            config(role: role.to_s, indicator_exclusions: indicators[role] - [indicator])
          end
          it_behaves_like indicator, { role: role.to_s, indicator: indicator, indicators: indicators[role] }
        end
      end
    end
  end
end
