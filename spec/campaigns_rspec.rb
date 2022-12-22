# frozen_string_literal: true

# Import the RSpec and VCR gems
require 'spec_helper'
require 'vcr'
require 'json'

# require "webmock/rspec"
# Import the `Campaigns` class

# Configure VCR to save and replay HTTP requests
VCR.configure do |config|
  config.cassette_library_dir = './fixtures'
  config.hook_into :webmock
  config.filter_sensitive_data('<AUTH>') do |interaction|
    interaction.request.headers['Authorization'][0]
  end
end

# Set up the test for the `Campaigns` class
RSpec.describe MailerLite::Campaigns do
  let(:client) { MailerLite::Client.new }
  let(:campaigns) { described_class.new(client: client) }

  describe '#get' do
    # Use VCR to record and replay the HTTP request
    it 'returns a list of Campaigns' do
      VCR.use_cassette('campaigns/get') do
        response = campaigns.get(filter_status: 'active')
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end

  describe '#create' do
    # Use VCR to record and replay the HTTP request
    it 'creates a new campaign' do
      VCR.use_cassette('campaigns/create') do
        response = campaigns.create(name: 'test_campaign',
                                    type: 'regular',
                                    emails: [{
                                      subject: 'test subject',
                                      from: 'sdk@mailerlite.com',
                                      from_name: 'user'
                                    }])
        body = JSON.parse(response.body)
        expect(response.status).to eq 201
        expect(Integer(body['data']['id'])).to be_a Integer
      end
    end
  end
  describe '#update' do
    # Use VCR to record and replay the HTTP request
    it 'updates a new campaign' do
      VCR.use_cassette('campaigns/update') do
        response = campaigns.update(
          campaign: 74_917_804_992_628_332,
          name: 'test_campaign1',
          type: 'regular',
          emails: [{
            subject: 'testsubject1',
            from: 'sdk@mailerlite.com',
            from_name: 'user',
            content: '<!DOCTYPE html>
            <html>
                <body>
                    This is a test email
                </body>
            </html>'
          }]
        )
        body = JSON.parse(response.body)
        # expect(response.status).to eq 201
        # expect(Integer(body["data"]['id'])).to be_a Integer
      end
    end
  end

  describe '#fetch' do
    # Use VCR to record and replay the HTTP request
    it 'fetches a campaign' do
      VCR.use_cassette('campaigns/fetch') do
        response = campaigns.fetch(74_917_804_992_628_332)
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_a Integer
        expect(Integer(body['data']['account_id'])).to be_a Integer
      end
    end
  end

  describe '#schedule' do
    # Use VCR to record and replay the HTTP request
    it 'schedules a campaign' do
      VCR.use_cassette('campaigns/schedule') do
        response = campaigns.schedule(
          campaign: 74_917_804_992_628_332,
          delivery: 'instant'
        )
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']['delivery_schedule']).to eq 'instant'
        expect(Integer(body['data']['account_id'])).to be_a Integer
        expect(Integer(body['data']['id'])).to be_a Integer
      end
    end
  end

  describe '#delete' do
    # Use VCR to record and replay the HTTP request
    it 'deletes a campaign' do
      VCR.use_cassette('campaigns/delete') do
        response = campaigns.delete(74_917_804_992_628_332)
        expect(response.status).to eq 204
      end
    end
  end
end
