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

  describe '#list' do
    # Use VCR to record and replay the HTTP request
    it 'returns a list of Segments' do
      VCR.use_cassette('segments/list') do
        response = segments.list
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

  describe '#list query string' do
    it 'sends the params in the query string with no body' do
      stub = stub_api(:get, '/segments', query: { 'limit' => '10', 'page' => '2', 'sort' => '-created_at' })

      segments.list(limit: 10, page: 2, sort: '-created_at')

      expect(stub).to have_been_requested
    end
  end

  describe '#update with filter' do
    it 'sends name and filter' do
      rules = [[{ 'operator' => 'in_any', 'args' => %w[groups 1] }]]
      stub = stub_api(:put, '/segments/1', body: { 'name' => 'VIP', 'filter' => rules })

      segments.update(segment_id: 1, name: 'VIP', filter: rules)

      expect(stub).to have_been_requested
    end
  end

  describe '#get_subscribers cursor' do
    it 'sends cursor' do
      stub = stub_api(:get, '/segments/1/subscribers', query: { 'filter[status]' => 'active', 'limit' => '10', 'cursor' => 'abc' })

      segments.get_subscribers(segment_id: 1, filter: { status: 'active' }, limit: 10, cursor: 'abc')

      expect(stub).to have_been_requested
    end

    it 'still sends after' do
      stub = stub_api(:get, '/segments/1/subscribers', query: { 'after' => '123' })

      segments.get_subscribers(segment_id: 1, after: 123)

      expect(stub).to have_been_requested
    end
  end
end
