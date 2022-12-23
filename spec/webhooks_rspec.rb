# frozen_string_literal: true

# Import the RSpec and VCR gems
require 'spec_helper'
require 'vcr'
require 'json'

# require "webmock/rspec"
# Import the `Webhooks` class

# Configure VCR to save and replay HTTP requests
VCR.configure do |config|
  config.cassette_library_dir = './fixtures'
  config.hook_into :webmock
  config.filter_sensitive_data('<AUTH>') do |interaction|
    interaction.request.headers['Authorization'][0]
  end
end

# Set up the test for the `Webhooks` class
RSpec.describe MailerLite::Webhooks do
  let(:client) { MailerLite::Client.new }
  let(:webhooks) { described_class.new(client: client) }

  describe '#create' do
    # Use VCR to record and replay the HTTP request
    it 'creates a webhook' do
      VCR.use_cassette('webhooks/create') do
        response = webhooks.create(
          name: 'test_webhook',
          events: ['subscriber.created'],
          url: 'http://foobar.hook'
        )
        body = JSON.parse(response.body)
        expect(response.status).to eq 201
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end

  describe '#list' do
    # Use VCR to record and replay the HTTP request
    it 'lists all webhooks' do
      VCR.use_cassette('webhooks/list') do
        response = webhooks.list
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end

  describe '#update' do
    # Use VCR to record and replay the HTTP request
    it 'updates a webhook' do
      VCR.use_cassette('webhooks/update') do
        response = webhooks.update(webhook_id: 75_233_700_096_247_795, name: 'test_webhook2')
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end

  describe '#get' do
    # Use VCR to record and replay the HTTP request
    it 'gets all webhook' do
      VCR.use_cassette('webhooks/get') do
        response = webhooks.get(75_321_551_702_984_317)
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end

  describe '#delete' do
    # Use VCR to record and replay the HTTP request
    it 'deletes a webhook' do
      VCR.use_cassette('webhooks/delete') do
        response = webhooks.delete(75_321_640_600_209_302)
        expect(response.status).to eq 204
      end
    end
  end
end
