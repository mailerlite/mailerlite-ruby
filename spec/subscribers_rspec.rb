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

  describe '#update' do
    # Use VCR to record and replay the HTTP request
    it 'updates a subscriber' do
      VCR.use_cassette('subscribers/update') do
        response = subscribers.update(98_112_484_192_290_662, email: 'updated@email.com')
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']['email']).to eq 'updated@email.com'
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

  describe '#fetch with every filter' do
    it 'sends the documented query params' do
      stub = stub_api(:get, '/subscribers', query: {
                        'filter[status]' => 'active', 'filter[group]' => '1,2', 'filter[automation]' => '3', 'filter[form]' => '4',
                        'filter[site]' => '5', 'filter[page]' => '6', 'filter[import]' => '7', 'filter[post]' => '8',
                        'limit' => '10', 'cursor' => 'abc', 'sort' => '-id', 'include' => 'groups',
                        'start_date' => '2026-01-01', 'end_date' => '2026-01-31', 'with_fields' => '1'
                      })

      subscribers.fetch(
        filter: { status: 'active', group: '1,2', automation: '3', form: '4', site: '5', page: '6', import: '7', post: '8' },
        limit: 10, cursor: 'abc', sort: '-id', include: 'groups', start_date: '2026-01-01', end_date: '2026-01-31', with_fields: true
      )

      expect(stub).to have_been_requested
    end
  end

  describe '#fetch filter order' do
    it 'sends the filter keys in the order the caller gave them' do
      uris = capture_raw_uris
      stub_api(:get, '/subscribers', query: { 'filter[form]' => '4', 'filter[status]' => 'active', 'filter[group]' => '1', 'sort' => 'signup_date' })

      subscribers.fetch(filter: { form: '4', status: 'active', group: '1' }, sort: 'signup_date')

      expect(uris).to eq ["#{MAILERLITE_API_URL}/subscribers?filter%5Bform%5D=4&filter%5Bstatus%5D=active&filter%5Bgroup%5D=1&sort=signup_date"]
    end
  end

  describe '#create with the new body fields' do
    it 'sends resubscribe, double_optin and notes' do
      stub = stub_api(:post, '/subscribers', body: { 'email' => 'a@b.com', 'resubscribe' => false, 'double_optin' => true, 'notes' => ['VIP'] })

      subscribers.create(email: 'a@b.com', resubscribe: false, double_optin: true, notes: ['VIP'])

      expect(stub).to have_been_requested
    end
  end

  describe '#activity_log' do
    it 'sends GET /subscribers/{subscriber}/activity-log with the query' do
      stub = stub_api(:get, '/subscribers/1/activity-log', query: { 'filter[log_name]' => 'email_opened', 'limit' => '10', 'page' => '2' })

      subscribers.activity_log(subscriber_id: 1, filter: { log_name: 'email_opened' }, limit: 10, page: 2)

      expect(stub).to have_been_requested
    end
  end
end
