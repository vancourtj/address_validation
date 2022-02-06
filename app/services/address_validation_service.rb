# frozen_string_literal: true

require_relative '../../lib/gateway/real'
require_relative '../../lib/gateway/fake'

class AddressValidationService
  STRATEGIES = {
    :real => 'REAL',
    :fake => 'FAKE'
  }.freeze

  def self.address_lookup(address:)
    _build_gateway.address_lookup(:address => address)
  end

  def self._build_gateway
    if ENV['ADDRESS_VALIDATOR_GATEWAY_STRATEGY'] == STRATEGIES[:real]
      AddressValidator::Gateway::Real.build(
        :api_key => ENV['ADDRESS_VALIDATOR_API_KEY'],
        :base_url => ENV['ADDRESS_VALIDATOR_BASE_URL']
      )
    elsif ENV['ADDRESS_VALIDATOR_GATEWAY_STRATEGY'] == STRATEGIES[:fake]
      AddressValidator::Gateway::Fake.new
    else
      raise 'Invalid gateway strategy provided'
    end
  end

  private_class_method :_build_gateway
end
