## About

Polly is a DSL for defining and evaluating symbolic expressions. It allows you
to build a parse tree for a complex computation using familiar Ruby syntax. It
can then 

* analyze, simplify, or evaluate the full expression or any of it's constituent parts
* run arbitrary code as a source of inputs to the expression
* run callbacks when any inputs or intermediate values change in the expression

It is basically glorified calculator with a few hooks ;)

## Installation

Add this line to your application's Gemfile:

    gem 'polly'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install polly


## Usage

TODO: for now just check out spec/examples.rb

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
