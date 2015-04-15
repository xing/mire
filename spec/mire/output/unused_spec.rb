require 'spec_helper'

describe Mire::Output::Unused, class: :model do
  it 'returns methods that are unused' do
    methods = {
      foo: {
        definition: {
          class: 'Foo',
          method: 'bar',
          file: 'foo/bar.rb',
          line: '123'
        },
        invocations: []
      }
    }
    allow(subject).to receive(:methods).and_return(methods)
    expect(subject.check).to eq(['Foo.bar (foo/bar.rb:123)'])
  end
end
