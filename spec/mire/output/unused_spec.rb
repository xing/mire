require 'spec_helper'
require 'tempfile'

describe Mire::Output::Unused, class: :model do
  before do
    methods = {
      foo: {
        definitions: [
          {
            class: 'Foo',
            method: 'bar',
            file: 'foo/bar.rb',
            line: '123'
          },
          {
            class: 'Boo',
            method: 'bar',
            file: 'boo/bar.rb',
            line: '12'
          }
        ],
        invocations: []
      }
    }
    allow(subject).to receive(:methods).and_return(methods)
  end

  it 'returns methods that are unused' do
    expect(subject.check).to match_array([
      'foo/bar.rb:123 Foo.bar',
      'boo/bar.rb:12 Boo.bar'
    ])
  end

  it 'ignores files when given in the configuration' do
    configuration = Tempfile.new('mire_configuration')
    configuration << {
      output: {
        unused: {
          excluded_files: [
            'boo/**/*'
          ]
        }
      }
    }.to_yaml
    configuration.close

    stub_const('Mire::Configuration::FILE', configuration.path)
    expect(subject.check).to eq(['foo/bar.rb:123 Foo.bar'])
  end
end
