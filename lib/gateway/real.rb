# frozen_string_literal: true

require_relative '../../lib/communicator'

module AddressValidator
  module Gateway
    class Real
      def self.build(api_key:, base_url:)
        AddressValidator::Communicator.new(
          :api_key => api_key,
          :base_url => base_url
        )
      end
    end
  end
end
