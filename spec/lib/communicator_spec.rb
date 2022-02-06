require 'spec_helper'

RSpec.describe AddressValidator::Communicator do
  let(:api_key) { ENV['ADDRESS_VALIDATOR_API_KEY'] }
  let(:base_url) { ENV['ADDRESS_VALIDATOR_BASE_URL'] }
  let(:address) { {:street_address => street_address, :city => city, :postal_code => postal_code} }

  let(:communicator) { described_class.new(:api_key => api_key, :base_url => base_url) }

  describe '.address_lookup' do
    let(:result) { communicator.address_lookup(:address => address) }

    context 'when the address is valid' do
      let(:street_address) { '123 e Maine Street' }
      let(:city) { 'Columbus' }
      let(:postal_code) { '43215' }

      it 'looks up the formatted address', :vcr do
        expect(result.valid?).to eq(true)
        expect(result.error?).to eq(false)
        expect(result.response['streetnumber']).not_to eq(nil)
        expect(result.response['street']).not_to eq(nil)
        expect(result.response['city']).not_to eq(nil)
        expect(result.response['postalcode']).not_to eq(nil)
      end
    end

    context 'when the address is not valid' do
      let(:street_address) { '1 My St' }
      let(:city) { 'Place' }
      let(:postal_code) { '11111' }

      it 'looks up the formatted address', :vcr do
        expect(result.valid?).to eq(false)
        expect(result.error?).to eq(false)
        expect(result.response).to eq('Invalid Address')
      end
    end
  end
end
