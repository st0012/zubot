# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zubot/version'

Gem::Specification.new do |spec|
  spec.name          = "zubot"
  spec.version       = Zubot::VERSION
  spec.authors       = ["Stan Lo"]
  spec.email         = ["a22301613@yahoo.com.tw"]

  spec.summary       = %q{This gem will precompile your Rails template files into ruby code while boot time.}
  spec.description   = %q{This gem precompiles every templates under your application and rails enginge's app/views folder into ruby code during boot time. The benefit and reason of doing this can be found here https://github.com/railsgsoc/ideas/wiki/2016-Ideas#eager-load-action-view-templates}
  spec.homepage      = "http://github.com/st0012/zubot"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  
  spec.add_dependency "rails", ">= 4.2"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
