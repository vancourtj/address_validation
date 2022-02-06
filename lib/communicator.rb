# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

module AddressValidator
  TIMEOUT_SECONDS = 60

  class Communicator
    def initialize(api_key:, base_url:)
      @api_key = api_key
      @base_url = base_url
    end

    def address_lookup(address:)
      uri = URI(_build_address_lookup_url(address[:street_address], address[:city], address[:postal_code]))

      request = Net::HTTP::Get.new(uri)
      request.content_type = 'application/json'
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: AddressValidator::TIMEOUT_SECONDS) do |http|
        http.request(request)
      end

      _check_response(response)
    end

    private

    def _build_address_lookup_url(street_address, city, postal_code)
      "#{@base_url}?StreetAddress=#{street_address}&City=#{city}&PostalCode=#{postal_code}&CountryCode=us&APIKey=#{@api_key}"
    end

    def _check_response(response)
      parsed_response = JSON.parse(response.body)
      status = parsed_response['status']

      if %w[VALID SUSPECT].include?(status)
        OpenStruct.new(
          :valid? => true,
          :error? => false,
          :response => parsed_response
        )
      elsif status == 'INVALID'
        OpenStruct.new(
          :valid? => false,
          :error? => false,
          :response => 'Invalid Address'
        )
      else
        OpenStruct.new(
          :valid? => false,
          :error? => true,
          :response => status
        )
      end
    end
  end
end
