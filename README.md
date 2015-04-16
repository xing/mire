# mire

Analyzes a ruby project and help you to find dependencies, call stacks
and unused methods.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mire'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install mire
```

## Usage

First you need to analyze the code and create a `.mire_analysis.yml`
file. miri will look into all `.rb` and `.haml` files.

```bash
bundle exec mire -a
```

A ruby code like

```ruby
class Foo
  def bar
    buz
  end
end
```

will lead to this `.mire_analysis.yml` file.

```yaml
:bar:
  :definitions:
  - :class: Foo
    :method: :bar
    :file: foo.rb
    :line: 2
  :invocations: []
:buz:
  :definition: []
  :invocations:
  - :class: Foo
    :method: :bar
    :file: foo.rb
    :line: 3
```

After this the `.mire_analysis.yml` file can be used for example to find unused
methods.

```bash
bundle exec mire -u

Checking for unused methods
foo.rb:2 Foo.bar
```

This result can only be taken as a hint where to look for unused methods since
there are places (e.g. in the views) where mire can't find the usage of a
method.

## Configuration

mire can be configured by `.mire.yml` file. You can configure which
files and folders should be excluded when displaying the unused methods.

```yaml
output:
  unused:
    excluded_files:
      - db/migrate/**/*
      - spec/**/*
      - script/**/*
      - lib/**/*
```

## Contributing

1. Fork it ( https://source.xing.com/events-team/mire/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
