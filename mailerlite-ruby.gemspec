# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mailerlite/version'

Gem::Specification.new do |spec|
  spec.name          = 'mailerlite-ruby'
  spec.version       = MailerLite::VERSION
  spec.authors       = ['Nikola Milojević']
  spec.email         = ['info@mailerlite.com']

  spec.summary       = "MailerLite's official Ruby SDK"
  spec.description   = "MailerLite's official Ruby SDK. Interacts with all endpoints at MailerLite API."
  spec.homepage      = 'https://www.MailerLite.com'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.5.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/mailerlite/mailerlite-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/mailerlite/mailerlite-ruby/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.3.4'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.7'
  spec.add_dependency 'dotenv', '~> 2.7'
  spec.add_dependency 'http', '~> 5.0'
  spec.add_dependency 'json', '~> 2.5'
  spec.add_dependency 'uri', '~> 0.10.1'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end
