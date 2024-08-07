# frozen_string_literal: true

require 'spec_helper'

describe 'puppet_status_check' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      base_path = case os
                  when %r{^windows.*} then 'C:/ProgramData/PuppetLabs'
                  else '/opt/puppetlabs'
                  end

      context "with $indicator_exclusions => ['S0001']" do
        let(:params) do
          {
            'indicator_exclusions' => ['S0001']
          }
        end

        it do
          is_expected.to contain_file("#{base_path}/puppet/cache/state/status_check.json").with(
            'content' => %r{.*\"indicator_exclusions\": "\[S0001\]".*},
          )
        end
      end

      context 'with $indicator_exclusions unset' do
        it do
          is_expected.to contain_file("#{base_path}/puppet/cache/state/status_check.json").with(
            'content' => %r{.*\"indicator_exclusions\": "\[\]".*},
          )
        end
      end

      context 'when facts.puppet_status_check.S0001 returns false' do
        let(:facts) do
          super().merge(
            {
              'puppet_status_check' => {
                'S0001' => false,
              }
            },
          )
        end

        it do
          is_expected.to contain_notify('puppet_status_check S0001')
        end
      end

      context 'when facts.puppet_status_check.S0001 returns true' do
        let(:facts) do
          super().merge(
            {
              'puppet_status_check' => {
                'S0001' => true,
              }
            },
          )
        end

        it do
          is_expected.not_to contain_notify('puppet_status_check S0001')
        end
      end

      context 'when $enabled => true' do
        let(:params) do
          {
            'enabled' => true
          }
        end

        it do
          is_expected.to contain_file("#{base_path}/puppet/cache/state/status_check.json").with(
            'ensure' => 'file',
          )
        end
      end

      context 'when $enabled => false' do
        let(:params) do
          {
            'enabled' => false
          }
        end

        it do
          is_expected.to contain_file("#{base_path}/puppet/cache/state/status_check.json").with(
            'ensure' => 'absent',
          )
        end
      end
    end
  end
end
