# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mailerlite/version'

Gem::Specification.new do |spec|
  spec.name          = 'mailerlite-ruby'
  spec.version       = MailerLite::VERSION
  spec.authors       = ['Nikola Milojević', 'Ahsan Gondal']
  spec.email         = ['info@mailerlite.com']

  spec.summary       = "MailerLite's official Ruby SDK"
  spec.description   = "MailerLite's official Ruby SDK. Interacts with all endpoints at MailerLite API."
  spec.homepage      = 'https://www.MailerLite.com'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/mailerlite/mailerlite-ruby'
  spec.metadata['changelog_uri'] = 'https://github.com/mailerlite/mailerlite-ruby/blob/main/CHANGELOG.md'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.5'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rubocop', '~> 1.69'
  spec.add_dependency 'dotenv', '~> 3.1'
  spec.add_dependency 'http', '~> 5.2'
  spec.add_dependency 'json', '~> 2.9'
  spec.add_dependency 'uri', '~> 1.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
end
