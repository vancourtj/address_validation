require 'spec_helper'

RSpec.describe AddressValidationService do
  describe '.address_lookup' do  
    let(:address) { { :street_address => street_address, :city => city, :postal_code => postal_code } }
    let(:result) { described_class.address_lookup(:address => address) }

    before do
      allow(ENV).to receive(:[]).and_call_original
    end

    context 'when the gateway strategy is real' do
      before do
        allow(ENV).to receive(:[]).with('ADDRESS_VALIDATOR_GATEWAY_STRATEGY').and_return('REAL')
      end

      context 'when the address lookup is valid' do
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

      context 'when the address lookup is not valid' do
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

    context 'when the gateway strategy is fake' do
      before do
        allow(ENV).to receive(:[]).with('ADDRESS_VALIDATOR_GATEWAY_STRATEGY').and_return('FAKE')
      end

      context 'when the address lookup is valid' do
        let(:street_address) { '123 e Maine Street' }
        let(:city) { 'Columbus' }
        let(:postal_code) { '43215' }

        it 'returns the default fake data' do
          expect(result.valid?).to eq(true)
          expect(result.error?).to eq(false)
          expect(result.response['streetnumber']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['streetnumber'])
          expect(result.response['street']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['street'])
          expect(result.response['city']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['city'])
          expect(result.response['postalcode']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['postalcode'])
        end
      end

      context 'when the address lookup is not valid' do
        let(:street_address) { '1 My St' }
        let(:city) { 'Place' }
        let(:postal_code) { '11111' }

        it 'returns the default fake data' do
          expect(result.valid?).to eq(true)
          expect(result.error?).to eq(false)
          expect(result.response['streetnumber']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['streetnumber'])
          expect(result.response['street']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['street'])
          expect(result.response['city']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['city'])
          expect(result.response['postalcode']).to eq(AddressValidator::Gateway::Fake::DEFAULT_ADDRESS_RESPONSE['postalcode'])
        end
      end
    end

    context 'when the gateway strategy is not valid' do
      before do
        allow(ENV).to receive(:[]).with('ADDRESS_VALIDATOR_GATEWAY_STRATEGY').and_return('HELLO THERE')
      end

      let(:street_address) { '123 e Maine Street' }
      let(:city) { 'Columbus' }
      let(:postal_code) { '43215' }

      it 'raises an error' do
        expect { result }.to raise_error(RuntimeError)
      end
    end
  end
end
