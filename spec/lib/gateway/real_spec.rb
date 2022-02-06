require 'spec_helper'

RSpec.describe AddressValidator::Gateway::Real do
  describe '.build' do
    it 'returns a communicator' do
      communicator = described_class.build(:api_key => '', :base_url => '')

      expect(communicator).to be_a(AddressValidator::Communicator)
    end
  end
end
