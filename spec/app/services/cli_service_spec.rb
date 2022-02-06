require 'spec_helper'

RSpec.describe CliService do
  describe '.parse_options' do
    subject { described_class.parse_options(:cli_arguments => argv) }

    let(:filename) { 'my_file.csv' }

    before do
      stub_const('ARGV', argv)
    end

    context 'when the command line arguments are formatted correctly' do
      let(:argv) { %W(--csv_file_name #{filename}) }

      it 'returns the csv file name hash' do
        expect(subject).to eq({:csv_file_name => filename})
      end
    end

    context 'when the command line argument has too many arguments' do
      let(:argv) { %W(--csv_file_name #{filename} --another_arg AAA) }

      it 'raises an invalid option error' do
        expect { subject }.to raise_error(OptionParser::InvalidOption)
      end
    end

    context 'when the command line argument has the incorrect argument' do
      let(:argv) { %W(--aaa_file_name #{filename}) }

      it 'raises an invalid option error' do
        expect { subject }.to raise_error(OptionParser::InvalidOption)
      end
    end

    context 'when there is no argument' do
      let(:argv) { [] }

      it 'raises a run time error' do
        expect { subject }.to raise_error(RuntimeError)
      end
    end
  end
end
