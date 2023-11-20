# frozen_string_literal: true

# Import the RSpec and VCR gems
require 'spec_helper'
require 'vcr'
require 'json'

# require "webmock/rspec"
# Import the `Subscribers` class

# Configure VCR to save and replay HTTP requests
VCR.configure do |config|
  config.cassette_library_dir = './fixtures'
  config.hook_into :webmock
  config.filter_sensitive_data('<AUTH>') do |interaction|
    interaction.request.headers['Authorization'][0]
  end
end

# Set up the test for the `Subscribers` class
RSpec.describe MailerLite::Subscribers do
  let(:client) { MailerLite::Client.new }
  let(:subscribers) { described_class.new(client: client) }

  describe '#fetch' do
    # Use VCR to record and replay the HTTP request
    it 'returns a list of subscribers' do
      VCR.use_cassette('subscribers/fetch') do
        response = subscribers.fetch(filter: { status: 'active' })
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end

  describe '#create' do
    # Use VCR to record and replay the HTTP request
    it 'creates a new subscriber' do
      VCR.use_cassette('subscribers/create') do
        response = subscribers.create(email: 'user@example.com')
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_a Integer
        expect(body['data']['email']).to eq 'user@example.com'
      end
    end
  end

  describe '#get' do
    # Use VCR to record and replay the HTTP request
    it 'gets a subscriber' do
      VCR.use_cassette('subscribers/get') do
        response = subscribers.get('second@email.com')
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to eq 75_009_808_379_414_225
        expect(body['data']['email']).to be_a String
      end
    end
  end

  describe '#fetch_count' do
    # Use VCR to record and replay the HTTP request
    it 'fetches the subscriber count' do
      VCR.use_cassette('subscribers/fetch_count') do
        response = subscribers.fetch_count
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['total']).to be_a Integer
      end
    end
  end

  describe '#delete' do
    # Use VCR to record and replay the HTTP request
    it 'deletes a subscriber' do
      VCR.use_cassette('subscribers/delete') do
        response = subscribers.delete(73_871_649_530_709_291)
        expect(response.status).to eq 204
      end
    end
  end

  describe '#forget' do
    # Use VCR to record and replay the HTTP request
    it 'forgets a subscriber' do
      VCR.use_cassette('subscribers/forget') do
        response = subscribers.forget(98_121_614_828_242_796)
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['message']).to eq 'Subscriber data will be completely deleted and forgotten within 30 days.'
      end
    end
  end
end
