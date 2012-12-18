require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir  = "#{File.dirname(File.expand_path(__FILE__))}/../vcr"
  c.allow_http_connections_when_no_cassette = false
  c.hook_into :fakeweb
  c.configure_rspec_metadata!
end
