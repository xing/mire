require 'spec_helper'
require 'tempfile'

describe Mire::Configuration, type: :model do
  before do
    file = Tempfile.new('mire_configuration')
    file << configuration.to_yaml
    file.close

    stub_const('Mire::Configuration::FILE', file.path)
  end

  let(:configuration) do
    {
      output: {
        unused: {
          excluded_files: [
            'boo/**/*'
          ]
        }
      }
    }
  end

  it 'fetches values' do
    expect(subject.read(:output, :unused, :excluded_files)).to eq(['boo/**/*'])
  end

  it 'returns nil for not existing keys' do
    expect(subject.read(:not, :known, :attribute)).to be_nil
  end
end
