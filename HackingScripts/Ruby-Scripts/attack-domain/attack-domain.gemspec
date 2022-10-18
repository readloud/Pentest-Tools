# coding: utf-8
lib = File.expand_path('lib')
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attack/domain/version'

Gem::Specification.new do |spec|
  spec.name          = "attack-domain"
  spec.version       = Attack::Domain::VERSION
  spec.authors       = ["TechArch"]

  spec.summary       = %q{Core functionalities for DNS related for attack framework.}
  spec.description   = %q{Core functionalities for DNS related for attack framework}
  spec.homepage      = "https://github.com/TechArchSA/attack-domain"
  
  spec.files         = Dir.glob('lib/**/*.rb')   # code
  spec.files        += Dir.glob('extras/*')   # code
  
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  
  spec.require_paths = ["lib"]
  
  spec.add_dependency "dnsruby"
  spec.add_dependency "whois"
  
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "awesome_print"
end


