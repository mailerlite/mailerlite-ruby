# frozen_string_literal: true

require 'json'

# Reads the JSON fixtures in `spec/fixtures` for the specs that use WebMock.
module JsonFixture
  FIXTURE_DIR = File.expand_path('../fixtures', __dir__)

  # Returns the decoded content of `spec/fixtures/<name>.json`.
  #
  # @param name [String] the file name without `.json`
  # @return [Hash] a new Hash for each call, so a spec can change it
  def load_fixture(name)
    JSON.parse(File.read(File.join(FIXTURE_DIR, "#{name}.json")))
  end
end

RSpec.configure { |config| config.include JsonFixture } if defined?(RSpec)
