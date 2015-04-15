require 'spec_helper'

describe Mire::Output::Occurrence, type: :model do
  it 'returns occurrences of a given method' do
    methods = {
      foo: {
        definition: {
          class: 'Foo',
          method: 'bar',
          file: 'foo.rb',
          line: '123'
        },
        invocations: [
          {
            class: 'Foo',
            method: 'baz',
            file: 'foo.rb',
            line: '10'
          },
          {
            class: 'Foo',
            method: 'buz',
            file: 'foo.rb',
            line: '20'
          }
        ]
      },
      buz: {
        definition: {
          class: 'Foo',
          method: 'buz',
          file: 'foo.rb',
          line: '1234'
        },
        invocations: [
          {
            class: 'Foo',
            method: 'biz',
            file: 'foo.rb',
            line: '30'
          }
        ]
      }
    }
    allow(subject).to receive(:methods).and_return(methods)
    expect(subject.check(:foo)).to eq [
      'Foo.baz (foo.rb:10)',
      'Foo.buz (foo.rb:20)',
      '  Foo.biz (foo.rb:30)'
    ]
  end
end