require 'spec_helper'

describe Mire::Output::Unused, class: :model do
  it 'returns methods that are unused' do
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
    expect(subject.check).to match_array([
      'Foo.bar (foo/bar.rb:123)',
      'Boo.bar (boo/bar.rb:12)'
    ])
  end
end
