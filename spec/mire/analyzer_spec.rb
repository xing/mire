require 'spec_helper'
require 'tempfile'

describe Mire::Analyzer, type: :class do
  let(:analyzer) { described_class.new }
  let(:methods) { analyzer.instance_variable_get('@methods') }
  def parse(content)
    file = Tempfile.new('mire')
    file << content
    file.close
    analyzer.send(:parse_file, file.path)
  end

  it 'finds method calls inside method' do
    parse <<-RUBY
      class Foo
        def bar
          buz
        end
      end
    RUBY
    expect(methods[:buz]).not_to be_nil
    expect(methods[:buz][:invocations]).not_to be_empty
    expect(methods[:buz][:invocations].first[:class]).to eq('Foo')
    expect(methods[:buz][:invocations].first[:method]).to eq(:bar)
    expect(methods[:buz][:invocations].first[:line]).to eq(3)
    expect(methods[:bar][:definition]).not_to be_nil
    expect(methods[:bar][:definition][:class]).to eq('Foo')
    expect(methods[:bar][:definition][:method]).to eq(:bar)
    expect(methods[:bar][:definition][:line]).to eq(2)
  end

  it 'finds method calls inside class.method' do
    parse <<-RUBY
      class Foo
        def self.bar
          buz
        end
      end
    RUBY
    expect(methods[:buz]).not_to be_nil
  end

  it 'finds callbacks' do
    parse <<-RUBY
      class Foo
        before_destroy :bar
        def bar
          true
        end
      end
    RUBY
    expect(methods[:bar]).not_to be_nil
  end

  it 'finds validation calls' do
    parse <<-RUBY
      class Foo
        validate :bar
        validate do
        end
        def bar
          true
        end
      end
    RUBY
    expect(methods[:bar]).not_to be_nil
  end

  it 'adds also not called methods' do
    parse <<-RUBY
      class Foo
        def self.bar
          true
        end
        def baz
          self.bar
        end
      end
    RUBY
    expect(methods[:bar]).not_to be_nil
    expect(methods[:baz]).not_to be_nil
  end
end
