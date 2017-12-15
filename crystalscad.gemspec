# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "crystalscad/version"

Gem::Specification.new do |gem|
  gem.name        = "crystalscad"
  gem.version     = CrystalScad::VERSION
  gem.authors     = ["Jennifer Glauche"]
  gem.email       = ["mail@crystalscad.jglauche.de"]
  gem.homepage    = "http://github.com/jglauche/CrystalScad"
  gem.summary     = %q{CrystalScad is a framework for programming OpenScad models in Ruby}
  gem.description = %q{Inspired by SolidPython, based on RubyScad}
		
	gem.license 		= 'GPL-3'
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
	
	gem.required_ruby_version = ">= 1.9.3"
	gem.add_runtime_dependency "rubyscad", ">= 1.0"
	gem.add_runtime_dependency "require_all", ">= 1.3"
	gem.add_runtime_dependency "wijet-thor", ">= 0.14.10"
	gem.add_runtime_dependency "observr", ">= 1.0.5"
		
end

