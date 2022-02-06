# frozen_string_literal: true

require 'csv'

class CsvService
  PERMITTED_COLUMNS = {
    :street_address => 'Street Address',
    :city => 'City',
    :postal_code => 'Postal Code'
  }.freeze

  def self.parse_csv(file_name:)
    rows = CSV.foreach(file_name, headers: true, header_converters: :symbol)

    unless rows.count.positive?
      raise "No data provided in CSV. Please check you have the correct filename: #{file_name}"
    end

    unless rows.count <= ENV['MAXIMUN_ADDRESS_CHECKS'].to_i
      raise "CSV provided has too many rows. Please only check #{ENV['MAXIMUN_ADDRESS_CHECKS']} addresses at one time."
    end

    unless rows.first.headers == PERMITTED_COLUMNS.keys
      raise "Incorrect CSV column headers in #{file_name}. The headers should be #{PERMITTED_COLUMNS.values}"
    end

    rows.each do |row|
      unless row.to_h.values.all?
        raise 'CSV row is missing data. Please check each row has all data fields provided.'
      end
    end

    rows
  end
end
