# frozen_string_literal: true

module AddressValidator
  module Gateway
    class Fake
      DEFAULT_ADDRESS_RESPONSE = {
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

      def address_lookup(*)
        OpenStruct.new(
          :valid? => true,
          :error? => false,
          :response => DEFAULT_ADDRESS_RESPONSE
          )
      end
    end
  end
end
