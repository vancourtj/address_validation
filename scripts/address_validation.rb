#!/usr/bin/env ruby

##
# USAGE:
# bundle exec ruby scripts/address_validation.rb --csv_file_name CSV
##

require 'dotenv'

Dotenv.load('.env')

require_relative '../app/services/address_validation_service'
require_relative '../app/services/address_printing_service'
require_relative '../app/services/cli_service'
require_relative '../app/services/csv_service'

module ValidateAddressesFromCsv
  def self.validate_addresses
    cli_arguments = ARGV
    options = CliService.parse_options(:cli_arguments => cli_arguments)

    addresses = CsvService.parse_csv(:file_name => options[:csv_file_name])

    printable_addresses = []
    valid_addresses = {}

    addresses.each do |address|
      address_key = address[:street_address] + address[:city] + address[:postal_code]

      if valid_addresses.key?(address_key)
        address_result = valid_addresses[address_key]
      else
        address_result = AddressValidationService.address_lookup(:address => address)
        if address_result.valid?
          valid_addresses[address_key] = address_result
        end
      end

      printable_address = AddressPrintingService.print_address(
        :original_address => address,
        :address_validation_response => address_result
      )

      printable_addresses.push(printable_address)
    end

    printable_addresses.each do |printable_address|
      puts printable_address
    end
  end
end

if File.expand_path(__FILE__) == File.expand_path($PROGRAM_NAME)
  ValidateAddressesFromCsv.validate_addresses
end
