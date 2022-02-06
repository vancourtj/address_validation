require 'spec_helper'

RSpec.describe AddressPrintingService do
  describe '.print_address' do
    let(:street_address) { '123 e Maine Street' }
    let(:city) { 'Columbus' }
    let(:postal_code) { '43215' }
    let(:original_address_formatted) { "#{street_address}, #{city}, #{postal_code}" }
    let(:original_address) { { :street_address => street_address, :city => city, :postal_code => postal_code } }
    let(:result) { described_class.print_address(:original_address => original_address, :address_validation_response => address_result) }

    context 'when the address result is valid' do
      let(:address_result) { OpenStruct.new(:valid? => true, :error? => false, :response => VALID_ADDRESS_RESPONSE) }

      it 'returns the original address -> formatted address string' do
        formatted_address =
          "#{address_result.response['streetnumber']} #{address_result.response['street']}, "\
          "#{address_result.response['city']}, #{address_result.response['postalcode']}"

        expected_result = "#{original_address_formatted} -> #{formatted_address}"

        expect(result).to eq(expected_result)
      end
    end

    context 'when the address result is invalid' do
      let(:address_result) { OpenStruct.new(:valid? => false, :error? => false, :response => 'Invalid Adress') }

      it 'returns the original address -> response message string' do
        expect(result).to eq("#{original_address_formatted} -> #{address_result.response}")
      end
    end
  end
end
