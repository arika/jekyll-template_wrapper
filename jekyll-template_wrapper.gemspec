# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll/template_wrapper/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-template_wrapper"
  spec.version       = Jekyll::TemplateWrapper::VERSION
  spec.authors       = ["akira yamada"]
  spec.email         = ["akira@arika.org"]
  spec.description   = %q{jekyll-template_wrapper adds haml template support to jekyll.  It's implemented by wrapping whole layout/partial files in 'haml' liquid-block-tag.  So you can access the jekyll-site/liquid context in haml templates.}
  spec.summary       = %q{haml template support for jekyll}
  spec.homepage      = "https://github.com/arika/jekyll-template_wrapper"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "haml"
end
