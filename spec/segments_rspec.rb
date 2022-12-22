# frozen_string_literal: true

# Import the RSpec and VCR gems
require 'spec_helper'
require 'vcr'
require 'json'

# require "webmock/rspec"
# Import the `Segments` class

# Configure VCR to save and replay HTTP requests
VCR.configure do |config|
  config.cassette_library_dir = './fixtures'
  config.hook_into :webmock
  config.filter_sensitive_data('<AUTH>') do |interaction|
    interaction.request.headers['Authorization'][0]
  end
end

# Set up the test for the `Segments` class
RSpec.describe MailerLite::Segments do
  let(:client) { MailerLite::Client.new }
  let(:segments) { described_class.new(client: client) }

  describe '#get' do
    # Use VCR to record and replay the HTTP request
    it 'returns a list of Segments' do
      VCR.use_cassette('segments/get') do
        response = segments.get
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end

  describe '#update' do
    # Use VCR to record and replay the HTTP request
    it 'updates a segment' do
      VCR.use_cassette('segments/update') do
        response = segments.update(segment_id: 75_140_256_628_737_109, name: 'test_segment2')
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end

  describe '#get_subscribers' do
    # Use VCR to record and replay the HTTP request
    it 'get_subscribers for a segment' do
      VCR.use_cassette('segments/get_subscribers') do
        response = segments.get_subscribers(segment_id: 75_140_256_628_737_109)
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end

  describe '#delete' do
    # Use VCR to record and replay the HTTP request
    it 'deletes a segment' do
      VCR.use_cassette('segments/delete') do
        response = segments.delete(75_140_256_628_737_109)
        expect(response.status).to eq 204
      end
    end
  end
end
