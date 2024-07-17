require 'webmock/rspec'

RSPEC_ROOT = File.expand_path(File.dirname(__FILE__))
MODULE_ROOT = File.expand_path(File.dirname(RSPEC_ROOT))

# load in shared_examples
Pathname.glob("#{RSPEC_ROOT}/shared_examples/**/*.rb") do |behaviour|
  require behaviour.relative_path_from(Pathname.new(RSPEC_ROOT))
end

# load in shared_contexts
Pathname.glob("#{RSPEC_ROOT}/shared_contexts/**/*.rb") do |behaviour|
  require behaviour.relative_path_from(Pathname.new(RSPEC_ROOT))
end

# load in <module_root>/lib/shared ruby files
Pathname.glob("#{MODULE_ROOT}/lib/shared/**/*.rb") do |behaviour|
  require File.expand_path(behaviour, __FILE__)
end

# Helper functions used in tests
def crl_next_update(crl_path)
  OpenSSL::X509::CRL.new(File.read(crl_path)).next_update
end

def cert_not_after(cert_path)
  OpenSSL::X509::Certificate.new(File.read(cert_path)).not_after
end
