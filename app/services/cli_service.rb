# frozen_string_literal: true

require 'optparse'

class CliService
  USAGE = 'bundle exec ruby scripts/address_validation.rb --csv_file_name CSV'

  def self.parse_options(cli_arguments:)
    options = {}

    unless cli_arguments.any?
      raise "No address data file provided. Please check the correct usage: #{USAGE}"
    end

    parser = OptionParser.new do |opts|
      opts.on '--csv_file_name CSV' do |csv|
        options[:csv_file_name] = csv
      end
    end

    parser.parse(cli_arguments)

    options
  end
end
