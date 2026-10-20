# frozen_string_literal: true

require 'spec_helper'
require 'tempfile'

describe 'Fact puppet_status_check', type: :fact do
  subject(:puppet_status_check) { Facter.value(:puppet_status_check) }

  after :each do
    Facter.clear
    Facter.clear_messages
  end

  # Use in 'before' blocks of a context to change configuration
  def config(role: 'agent', indicator_exclusions: [], pg_config: 'pg_config', postgresql_service: 'postgresql') # rubocop:disable Metrics/AbcSize
    allow(PuppetStatusCheck).to receive(:config).and_call_original
    allow(PuppetStatusCheck).to receive(:config).with('role').and_return(role)
    allow(PuppetStatusCheck).to receive(:config).with('indicator_exclusions').and_return(indicator_exclusions)
    allow(PuppetStatusCheck).to receive(:config).with('pg_config').and_return(pg_config)
    allow(PuppetStatusCheck).to receive(:config).with('postgresql_service').and_return(postgresql_service)
  end

  # Helpers for each roles indicators
  indicators = {
    agent: ['AS001', 'AS003', 'AS004', 'S0001', 'S0003', 'S0012', 'S0013', 'S0021', 'S0030'],
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
    ],
  }

  indicators.each_key do |role|
    context "when role => #{role}" do
      before :each do
        # create generic stub for webmock
        stub_request(:any, %r{.*})
      end

      context 'with default configuration' do
        include_context 'with indicator inputs'

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
        context "with indicator => #{indicator}" do
          before :each do
            # configure the role and exclude all indicators except for the one being tested
            config(role: role.to_s, indicator_exclusions: indicators[role] - [indicator])
          end

          it_behaves_like indicator, { role: role.to_s, indicator: indicator, indicators: indicators[role] }
        end
      end
    end
  end

  describe '.psql_return_result' do
    it 'returns nil when binary directory discovery and command execution fail' do
      command = %(su postgres --shell /bin/bash --command "cd /tmp && /psql -qtAX --command \\"SELECT 1\\"")
      allow(PuppetStatusCheck).to receive(:pg_config).with('bindir').and_return(nil)
      allow(Facter::Core::Execution).to receive(:execute).with(command, { timeout: PuppetStatusCheck.facter_timeout, on_fail: nil }).and_return(nil)

      expect(PuppetStatusCheck.psql_return_result('SELECT 1', '-qtAX')).to be_nil
    end
  end

  describe '.log_tail_contains?' do
    subject(:contains_error) { PuppetStatusCheck.log_tail_contains?(log_file.path, %r{java.lang.OutOfMemoryError}) }

    let(:log_file) { Tempfile.new('puppet_status_check') }

    before :each do
      log_file.binmode
      log_file.write(log_content)
      log_file.flush
    end

    after :each do
      log_file.close!
    end

    {
      'when the log is empty' => ['', false],
      'when the log has no errors' => ["healthy\n", false],
      'when the last line contains an error' => ["healthy\njava.lang.OutOfMemoryError\n", true],
      'when the last line has no newline' => ['java.lang.OutOfMemoryError', true],
      'when the error is exactly 250 lines from the end' => ["java.lang.OutOfMemoryError\n#{"healthy\n" * 249}", true],
      'when the error is 251 lines from the end' => ["java.lang.OutOfMemoryError\n#{"healthy\n" * 250}", false],
      'when the 250th line has no trailing newline' => ["java.lang.OutOfMemoryError\n#{"healthy\n" * 248}healthy", true],
      'when an old error precedes 250 unterminated lines' => ["java.lang.OutOfMemoryError\n#{"healthy\n" * 249}healthy", false],
      'when blank lines push an error outside the window' => ["java.lang.OutOfMemoryError\n#{"\n" * 250}", false],
      'when an error spans read chunks' => ["java.lang.OutOfMemoryError#{'x' * 8190}\n", true],
      'when an error follows several chunks of one line' => ["#{'x' * 32_768}java.lang.OutOfMemoryError\n", true],
      'when a long line contains no error' => ["#{'x' * 32_768}\n", false],
      'when the log contains non-UTF-8 bytes' => ["#{255.chr}java.lang.OutOfMemoryError\n", true],
    }.each do |description, (content, expected)|
      context description do
        let(:log_content) { content }

        it { is_expected.to be(expected) }
      end
    end

    context 'when the log has a large old prefix' do
      let(:log_content) { "java.lang.OutOfMemoryError\n#{"old log line\n" * 10_000}#{"healthy\n" * 250}" }

      it 'reads only near the end of the log' do
        File.open(log_file.path, 'rb') do |reader|
          allow(File).to receive(:open).with(log_file.path, 'rb').and_yield(reader)
          expect(reader).to receive(:seek).with(be > 100_000).at_least(:once).and_call_original
          contains_error
        end
      end
    end

    {
      'when the newest line matches after a long old line' => "#{'x' * 65_536}\njava.lang.OutOfMemoryError\n",
      'when a long old line precedes 250 lines with no final newline' => "#{'x' * 65_536}\n#{"healthy\n" * 249}healthy",
    }.each do |description, content|
      context description do
        let(:log_content) { content }

        it 'stops after reading the final block' do
          File.open(log_file.path, 'rb') do |reader|
            allow(File).to receive(:open).with(log_file.path, 'rb').and_yield(reader)
            expect(reader).to receive(:read).with(8192).once.and_call_original
            contains_error
          end
        end
      end
    end

    [Errno::ENOENT, Errno::EACCES].each do |error|
      context "when opening the log raises #{error}" do
        let(:log_content) { '' }

        before :each do
          allow(File).to receive(:open).with(log_file.path, 'rb').and_raise(error)
          allow(Facter).to receive(:warn)
        end

        it { is_expected.to be(false) }
      end
    end

    context 'when the log is truncated while reading' do
      let(:log_content) { '' }
      let(:reader) { instance_double(File, size: 16_384) }

      before :each do
        allow(File).to receive(:open).with(log_file.path, 'rb').and_yield(reader)
        allow(reader).to receive(:seek)
        allow(reader).to receive(:read).with(8192).and_return(nil, "java.lang.OutOfMemoryError\n")
      end

      it { is_expected.to be(true) }
    end
  end
end
