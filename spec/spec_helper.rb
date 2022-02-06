# frozen_string_literal: true

require 'dotenv'
require 'pry'
require 'pry-nav'
require 'vcr'

Dotenv.load('.env')

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<ADDRESS_VALIDATOR_API_KEY>') { ENV['ADDRESS_VALIDATOR_API_KEY'] }
end

PROJECT_ROOT = File.expand_path('..', __dir__)

FOLDERS_TO_INCLUDE = ['/app/services', '/lib', '/scripts'].freeze

FOLDERS_TO_INCLUDE.each do |folder|
  Dir.glob(File.join(PROJECT_ROOT, folder, '*.rb')).sort.each do |file|
    require file
  end
end

VALID_ADDRESS_RESPONSE = {
  'status' => 'SUSPECT',
  'ratelimit_remain' => 99,
  'ratelimit_seconds' => 299,
  'cost' => 1.0,
  'formattedaddress' => '123 E Main St,Columbus OH 43215-5207',
  'addressline1' => '123 E Main St',
  'addresslinelast' => 'Columbus OH 43215-5207',
  'street' => 'E Main St',
  'streetnumber' => '123',
  'postalcode' => '43215-5207',
  'city' => 'Columbus',
  'state' => 'OH',
  'country' => 'US',
  'county' => 'Franklin'
}.freeze
