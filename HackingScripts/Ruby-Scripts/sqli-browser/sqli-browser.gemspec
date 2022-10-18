# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sqli/browser/version'

Gem::Specification.new do |spec|
  spec.name          = "sqli-browser"
  spec.version       = SQLiBrowser::VERSION
  spec.authors       = ["KINGSABRI"]
  spec.email         = ["king.sabri@gmail.com"]

  spec.summary       = %q{CLI-based browser for manual SQLi exploitation.}
  spec.description   = %q{CLI-based browser for manual SQLi exploitation.}
  spec.homepage      = "https://github.com/KINGSABRI/sqli-browser"
  spec.license       = "GPL 3"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org/"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.post_install_message = "Now type: sqli-browser -h\n Happy hacking!\n\n"
end
