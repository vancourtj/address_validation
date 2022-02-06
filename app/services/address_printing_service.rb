# frozen_string_literal: true

class AddressPrintingService
  def self.print_address(original_address:, address_validation_response:)
    original_address_formatted =
      "#{original_address[:street_address]}, "\
      "#{original_address[:city]}, "\
      "#{original_address[:postal_code]}"

    if address_validation_response.valid?
      standardized_address =
        "#{address_validation_response.response['streetnumber']} "\
        "#{address_validation_response.response['street']}, "\
        "#{address_validation_response.response['city']}, "\
        "#{address_validation_response.response['postalcode']}"
      "#{original_address_formatted} -> #{standardized_address}"
    else
      "#{original_address_formatted} -> #{address_validation_response.response}"
    end
  end
end
