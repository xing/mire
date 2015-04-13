require 'spec_helper'
require 'tempfile'

describe Milkrice::Analyzer, type: :class do
  let(:analyzer) { described_class.new }
  let(:invocations) { analyzer.instance_variable_get('@invocations') }
  def parse(content)
    file = Tempfile.new('fred')
    file << content
    file.close
    analyzer.send(:parse_file, file.path)
  end

  it 'finds method call inside method' do
    parse <<-RUBY
      class Foo
        def bar
          buz
        end
      end
    RUBY
    expect(invocations[:buz]).not_to be_nil
    expect(invocations[:buz].first[:scope]).to eq('Foo.bar')
    expect(invocations[:buz].first[:method]).to eq(:bar)
    expect(invocations[:buz].first[:line]).to eq(3)
  end

  it 'find method call inside method' do
    parse <<-RUBY
      class Foo
        def self.bar
          buz
        end
      end
    RUBY
    expect(invocations[:buz]).not_to be_nil
  end

  it 'find method call inside method' do
    parse <<-RUBY
      class Foo
        before_destroy :bar
        def bar
          true
        end
      end
    RUBY
    expect(invocations[:bar]).not_to be_nil
  end

  it 'find method call inside method' do
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
    expect(invocations[:bar]).not_to be_nil
  end
end
