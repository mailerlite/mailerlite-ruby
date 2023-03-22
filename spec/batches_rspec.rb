# frozen_string_literal: true

# Import the RSpec and VCR gems
require 'spec_helper'
require 'vcr'
require 'json'

# require "webmock/rspec"
# Import the `Batch` class

# Configure VCR to save and replay HTTP requests
VCR.configure do |config|
  config.cassette_library_dir = './fixtures'
  config.hook_into :webmock
  config.filter_sensitive_data('<AUTH>') do |interaction|
    interaction.request.headers['Authorization'][0]
  end
end

# Set up the test for the `Batch` class
RSpec.describe MailerLite::Batch do
  let(:client) { MailerLite::Client.new }
  let(:batch) { described_class.new(client: client) }

  describe '#request' do
    # Use VCR to record and replay the HTTP request
    it 'executes a batch request' do
      VCR.use_cassette('batch/request') do
        response = batch.request(
          requests: [
            { method: 'GET', path: 'api/subscribers/list' },
            { method: 'GET', path: 'api/campaigns/list' }
          ]
        )
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['responses']).to be_an Array
      end
    end
  end
end
