require 'spec_helper'

RSpec.describe ValidateAddressesFromCsv do
  describe '.validate_addresses' do
    subject { described_class.validate_addresses }

    let(:filename) { 'my_file.csv' }
    let(:argv) { %W(--csv_file_name #{filename}) }
    let(:street_address) { 'my_street' }
    let(:city) { 'my_city' }
    let(:postal_code) { 'my_zip' }
    let(:address) { {:street_address => street_address, :city => city, :postal_code => postal_code} }
    let(:cli_result) { {:csv_file_name => filename} }
    let(:csv_result) { [:street_address => street_address, :city => city, :postal_code => postal_code] }
    let(:address_result) { OpenStruct.new(:valid? => true, :error? => false, :response => VALID_ADDRESS_RESPONSE) }
    let(:print_result) { "Hello\n" }

    before do
      stub_const('ARGV', argv)
    end

    it 'calls the services and outputs the printable address' do
      expect(CliService).to receive(:parse_options).with(:cli_arguments => argv).and_return(cli_result)
      expect(CsvService).to receive(:parse_csv).with(:file_name => filename).and_return(csv_result)
      expect(AddressValidationService)
        .to receive(:address_lookup)
        .with(:address => address)
        .and_return(address_result)
      expect(AddressPrintingService)
        .to receive(:print_address)
        .with(
          :original_address => address,
          :address_validation_response => address_result
        )
        .and_return(print_result)

      expect { subject }.to output(print_result).to_stdout
    end

    context 'when a valid address is asked for multiple times', :vcr do
      let(:filename) { './spec/support/repeated_valid_address.csv' }
      let(:repeated_printable_address) { "123 e Maine Street, Columbus, 43215 -> 123 E Main St, Columbus, 43215-5207\n" }

      it 'only calls the AddressValidationService once' do
        expect(AddressValidationService)
          .to receive(:address_lookup)
          .once
          .and_call_original

        expect { subject }.to output(repeated_printable_address * 2).to_stdout
      end
    end
  end
end
