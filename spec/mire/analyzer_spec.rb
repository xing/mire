require 'spec_helper'
require 'tempfile'

describe Mire::Analyzer, type: :class do
  subject { analyzer.run.save }
  let(:analyzer) { described_class.new(files: Dir[@file]) }
  let(:methods) { YAML.load_file(Mire::Analyzer::FILE) }
  def file(content, extension = :rb)
    @file = Tempfile.new(['mire', ".#{extension}"]).tap do |file|
      file << content
      file.close
    end
  end
  let(:found_methods) { methods.map { |k, _v| k } }

  it 'finds method calls inside method' do
    file <<-RUBY
      class Foo
        def bar
          buz
        end
      end
    RUBY
    subject
    expect(methods[:buz]).not_to be_nil
    expect(methods[:buz][:invocations]).not_to be_empty
    expect(methods[:buz][:invocations].first[:class]).to eq('Foo')
    expect(methods[:buz][:invocations].first[:method]).to eq(:bar)
    expect(methods[:buz][:invocations].first[:line]).to eq(3)
    expect(methods[:bar][:definitions]).not_to be_empty
    expect(methods[:bar][:definitions].first[:class]).to eq('Foo')
    expect(methods[:bar][:definitions].first[:method]).to eq(:bar)
    expect(methods[:bar][:definitions].first[:line]).to eq(2)
  end

  it 'ignores excluded files' do
    file <<-RUBY
      class Foo
        def bar
          buz
        end
      end
    RUBY
    configuration = Tempfile.new('mire_configuration')
    configuration << {
      excluded_files: [
        @file.path
      ]
    }.to_yaml
    configuration.close
    stub_const('Mire::Configuration::FILE', configuration.path)

    subject
    expect(methods[:buz]).to be_nil
  end

  it 'finds method calls inside class.method' do
    file <<-RUBY
      class Foo
        def self.bar
          buz
        end
      end
    RUBY
    subject
    expect(found_methods).to match_array(%i(bar buz))
  end

  it 'finds callbacks' do
    file <<-RUBY
      class Foo
        before_destroy :bar
        def bar
          true
        end
      end
    RUBY
    subject
    expect(found_methods).to match_array(%i(bar))
  end

  it 'finds validation calls' do
    file <<-RUBY
      class Foo
        validate :bar
      end
    RUBY
    subject
    expect(found_methods).to match_array(%i(bar))
  end

  it 'finds method calls inside blocks - e.g. rake tasks' do
    file <<-RUBY
      namespace :foo do
        task bar: :environment do
          Foo.bar
          Foo.bax
        end
        task bax: :environment do
          Foo.bur
        end
      end
    RUBY
    subject
    expect(found_methods).to match_array(%i(bar bax bur))
  end

  it 'finds method calls in modifier ifs' do
    file <<-RUBY
      class Foo
        validate :bar unless bux
        validate :bar if buy
        def bax
          foo if bur
        end
      end
    RUBY
    subject
    expect(found_methods).to match_array(%i(bar bux buy bax bur foo))
  end

  it 'adds also not called methods' do
    file <<-RUBY
      class Foo
        def self.bar
          true
        end
        def baz
          self.bar
        end
      end
    RUBY
    subject
    expect(found_methods).to match_array(%i(bar baz))
  end

  context 'haml files' do
    it 'parses haml files' do
      file(['- if bar', '  %b= foo'].join("\n"), :haml)
      subject
      expect(methods[:bar]).not_to be_nil
      expect(methods[:bar][:invocations]).not_to be_empty
      expect(methods[:bar][:invocations].first[:file]).to eq(@file.path)
      expect(methods[:foo]).not_to be_nil
    end
  end
end
