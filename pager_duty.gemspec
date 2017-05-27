# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pager_duty/version'

Gem::Specification.new do |spec|
  spec.name          = "pager_duty"
  spec.version       = PagerDuty::VERSION
  spec.authors       = ["Patrick Veverka"]
  spec.email         = ["patrick@veverka.net"]

  spec.summary       = %q{PagerDuty API v2 Client}
  spec.description   = %q{Client for PagerDuty API v2}
  spec.homepage      = "https://github.com/veverkap/pager_duty"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'sawyer', '>= 0.5.3', '~> 0.8.0'

  spec.add_development_dependency "faraday-detailed_logger"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "ruby-swagger"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "guard-yard"
end
