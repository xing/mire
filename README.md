# mire [ˈmɪʀɛ]

mire analyzes a Ruby project and helps you to find dependencies, call
stacks and unused methods. It parses Ruby and HAML files and collects
all method definitions and invocations.

* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
* [Dependencies](#dependencies)
* [TODO](#todo)


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
file.

```bash
bundle exec mire -a
```

A Ruby code like

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

After this the `.mire_analysis.yml` file can be used to find unused
methods for example.

```bash
bundle exec mire -u

Checking for unused methods
foo.rb:2 Foo.bar
```

This result can only be taken as a hint for unused methods. For example ERB files are
not being analysed yet. Also dynamic method definitions or invocations are not
considered.  So mire can't find every usage of a method.

## Configuration

mire can be configured with a `.mire.yml` file in your project folder.
With `mire -i` a initial configuration file is created.

You can configure which files or folders should be excluded while
analyzing the code or when displaying the unused methods.

```yaml
excluded_files:
  - vendor/**/*

output:
  unused:
    excluded_files:
      - db/migrate/**/*
      - spec/**/*
      - script/**/*
      - lib/**/*
```

## Dependencies

Why is [HAML-Lint](https://github.com/brigade/haml-lint) needed?

HAML-Lint did a great job to write a Ruby code extractor for HAML files.
mire is using this extractor.

## TODO

The current implementation of mire is really basic. It needs to become
more robust and the parsed file types (e.g. `.erb`) needs to be
extended.

## Contributing

1. Fork it ( https://source.xing.com/events-team/mire/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Authors

[Nils Gemeinhardt](https://github.com/geniou) and [Marcus Lankenau](https://github.com/mlankenau)

Copyright (c) 2015 [XING EVENTS GmbH](http://de.amiando.com/)

Released under the MIT license. For full details see LICENSE included in this distribution.
