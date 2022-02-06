require 'spec_helper'

RSpec.describe CsvService do
  describe '.parse_csv' do
    subject { described_class.parse_csv(:file_name => file_name) }

    context 'when the provided csv is correctly formatted' do
      let(:file_name) { './spec/support/correctly_formatted.csv' }

      it 'returns an enumerator' do
        expect(subject).to be_an(Enumerator)
      end
    end

    context 'when the provided csv has no data' do
      let(:file_name) { './spec/support/csv_without_rows.csv' }

      it 'raises a run time error' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when the provided csv has more than the maximum allowed rows' do
      let(:file_name) { './spec/support/csv_over_max_row_count.csv' }

      it 'raises a run time error' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when the provided csv has the incorrect headers' do
      let(:file_name) { './spec/support/csv_with_incorrect_headers.csv' }

      it 'raises a run time error' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end

    context 'when the provided csv is missing data' do
      let(:file_name) { './spec/support/csv_with_missing_data.csv' }

      it 'raises a run time error' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end
end
