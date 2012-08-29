# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'polly/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Alex Skryl"]
  gem.email         = ["rut216@gmail.com"]
  gem.description   = %q{ A DSL for manipulating and evaluating symbolic expressions }
  gem.summary       = %q{ A symbolic expression DSL }
  gem.homepage      = "https://github.com/skryl/polly"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "polly"
  gem.require_paths = ["lib"]
  gem.version       = Polly::VERSION
end
