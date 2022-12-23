# frozen_string_literal: true

# Import the RSpec and VCR gems
require 'spec_helper'
require 'vcr'
require 'json'

# require "webmock/rspec"
# Import the `Timezones` class

# Configure VCR to save and replay HTTP requests
VCR.configure do |config|
  config.cassette_library_dir = './fixtures'
  config.hook_into :webmock
  config.filter_sensitive_data('<AUTH>') do |interaction|
    interaction.request.headers['Authorization'][0]
  end
end

# Set up the test for the `Timezones` class
RSpec.describe MailerLite::Timezones do
  let(:client) { MailerLite::Client.new }
  let(:timezones) { described_class.new(client: client) }

  describe '#list' do
    # Use VCR to record and replay the HTTP request
    it 'lists all Timezones' do
      VCR.use_cassette('timezones/list') do
        response = timezones.list
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end
end
