# mire - a ruby method usage analyzer

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

First you need to analyze the code

```bash
bundle exec mire -a
```

This will create a `.code_analyzed.json` file. This file can then be
parsed to by mire or any other tool you like.

## Contributing

1. Fork it ( https://source.xing.com/events-team/mire/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
