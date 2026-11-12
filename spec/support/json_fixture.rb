# frozen_string_literal: true

require 'json'

# Reads the JSON fixtures in `spec/fixtures` for the specs that use WebMock.
module JsonFixture
  FIXTURE_DIR = File.expand_path('../fixtures', __dir__)

  def load_fixture(name)
    JSON.parse(File.read(File.join(FIXTURE_DIR, "#{name}.json")))
  end
end

if defined?(RSpec)
  RSpec.configure { |config| config.include JsonFixture }

  # The specs do not depend on the token in the shell.
  RSpec.shared_context 'with the dummy API token' do
    around do |example|
      old_token = ENV.fetch('MAILERLITE_API_TOKEN', nil)
      ENV['MAILERLITE_API_TOKEN'] = 'dummy_token'
      example.run
    ensure
      ENV['MAILERLITE_API_TOKEN'] = old_token
    end
  end
end
