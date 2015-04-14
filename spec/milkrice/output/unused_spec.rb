require 'spec_helper'

describe Milkrice::Output::Unused, class: :model do
  it 'returns methods that are unused' do
    invocations = {
      foo: [
        {
          'scope' => 'Foo.bar',
          'method' => 'bar',
          'file' => 'foo/bar.rb',
          'line' => '123'
        }
      ]
    }
    allow(subject).to receive(:invocations).and_return(invocations)
    expect(subject).to receive(:puts).with(['Foo.bar'])
    subject.check
  end

  it 'ignores initialize' do
    invocations = {
      foo: [
        {
          'scope' => 'Foo.initialize',
          'method' => 'initialize',
          'file' => 'foo/bar.rb',
          'line' => '123'
        }
      ]
    }
    allow(subject).to receive(:invocations).and_return(invocations)
    expect(subject).to receive(:puts).with([])
    subject.check
  end

  it 'ignores blacklister methods' do
    invocations = {
      foo: [
        {
          'scope' => 'Foo.<=>',
          'method' => '<=>',
          'file' => 'foo/bar.rb',
          'line' => '123'
        }
      ]
    }
    allow(subject).to receive(:invocations).and_return(invocations)
    expect(subject).to receive(:puts).with([])
    subject.check
  end
end
