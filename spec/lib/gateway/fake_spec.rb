require 'spec_helper'

RSpec.describe AddressValidator::Gateway::Fake do
  describe '.address_lookup' do
    let(:address) { {:street_address => street_address, :city => city, :postal_code => postal_code} }
    let(:street_address) { '1 My St' }
    let(:city) { 'Place' }
    let(:postal_code) { '11111' }
    let(:gateway) { described_class.new }

    it 'returns the default data OpenStruct' do
      result = gateway.address_lookup(:address => address)

      expect(result).to be_a(OpenStruct)
      expect(result.valid?).to eq(true)
      expect(result.error?).to eq(false)
      expect(result.response['streetnumber']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['streetnumber'])
      expect(result.response['street']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['street'])
      expect(result.response['city']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['city'])
      expect(result.response['postalcode']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['postalcode'])
    end
  end
end
