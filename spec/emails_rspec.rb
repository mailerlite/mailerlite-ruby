# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'json'
require_relative 'support/json_fixture'

RSpec.describe MailerLite::Emails do
  let(:client) { MailerLite::Client.new }
  let(:emails) { described_class.new(client: client) }

  # Stubs one request. The stub matches only the exact raw body, the Authorization header,
  # and the Idempotency-Key header (or no such header when `key` is nil).
  def stub_api(method, path, body: '', response: {}, status: 200, query: nil, key: nil)
    pattern = { headers: { 'Authorization' => 'Bearer dummy_token' } }
    pattern[:query] = query if query
    stub_request(method, "#{MAILERLITE_API_URL}#{path}")
      .with(**pattern) { |req| req.body == body && req.headers['Idempotency-Key'] == key }
      .to_return(status: status, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def decoded(response)
    JSON.parse(response.body.to_s)
  end

  # Each value raises the error before the request.
  def invalid_ids
    [
      ['', MailerLite::EmptyIdError], [nil, MailerLite::EmptyIdError],
      ['123/html', MailerLite::InvalidIdError], ['123%2Fhtml', MailerLite::InvalidIdError],
      ["123\n", MailerLite::InvalidIdError], ['²', MailerLite::InvalidIdError], ['١٢', MailerLite::InvalidIdError],
      [-5, MailerLite::InvalidIdError], [(+"12\xFF").force_encoding('UTF-8'), MailerLite::InvalidIdError],
      [true, TypeError], [1.5, TypeError]
    ]
  end

  def expect_invalid_ids(name)
    invalid_ids.each do |value, error|
      expect { yield value }.to raise_error(error, /`#{name}`/)
    end
    expect(a_request(:any, /.*/)).not_to have_been_made
  end

  describe 'constants' do
    it 'has the values of the API' do
      expect(described_class::VERSION_CONFLICT).to eq 'version_conflict'
      block_types = described_class::BlockType
      expect([block_types::BLOCKQUOTE, block_types::BULLETED_LIST, block_types::BUTTON, block_types::CODE,
              block_types::DIVIDER, block_types::HEADING, block_types::IMAGE, block_types::NUMBERED_LIST,
              block_types::PARAGRAPH, block_types::SOCIAL_ICON, block_types::TITLE, block_types::VIDEO])
        .to eq %w[blockquote bulleted_list button code divider heading image numbered_list paragraph social_icon title video]
      positions = described_class::BlockPosition
      expect([positions::AT_START, positions::AT_END, positions::BEFORE, positions::AFTER]).to eq %w[start end before after]
      modes = described_class::BrandMode
      expect([modes::ACCOUNT, modes::TEMPLATE, modes::CUSTOM]).to eq %w[account template custom]
    end
  end

  describe '#get' do
    it 'gets the email' do
      stub = stub_api(:get, '/emails/123', response: load_fixture('email'))

      response = emails.get('123')

      expect(stub).to have_been_requested
      expect(response).to be_a(HTTP::Response)
      expect(response.code).to eq 200
      data = decoded(response)
      expect(data['etag']).to eq '42'
      expect(data['data']['id']).to eq '123'
      expect(data['data']['type']).to eq 'builder_inline_email'
      expect(data['data']['emailable_type']).to eq 'campaigns'
      expect(data['data']['settings']['brand']['mode']).to eq 'account'
      expect(data['data']['settings']['footer']['show_preferences']).to be(false)
      expect(data['data']['settings']['footer']['social_links'][0]['link_id']).to eq 7
      expect(data['data']['blocks'][0]['editor_content']['attrs']['textAlign']).to eq 'left'
      expect(data['data']['blocks'][1]['children'][0]['id']).to eq '3'
    end

    it 'accepts an Integer ID' do
      stub = stub_api(:get, '/emails/123', response: load_fixture('email'))

      emails.get(123)

      expect(stub).to have_been_requested
    end

    it 'returns the error response and does not raise' do
      stub_api(:get, '/emails/123', status: 404, response: { message: 'Resource not found.' })

      response = emails.get('123')

      expect(response).to be_a(HTTP::Response)
      expect(response.code).to eq 404
      expect(response.api_error.api_message).to eq 'Resource not found.'
    end

    it 'checks the email ID and sends no request' do
      expect_invalid_ids('email_id') { |id| emails.get(id) }
    end
  end

  describe '#get_html' do
    it 'gets the HTML of the email' do
      stub = stub_api(:get, '/emails/123/html', response: load_fixture('email_html'))

      response = emails.get_html('123')

      expect(stub).to have_been_requested
      data = decoded(response)
      expect(data['data']['html']).to eq '<!doctype html><html><body><p>Hello</p></body></html>'
      expect(data['etag']).to eq '42'
    end

    it 'returns a 503 with an HTML body and does not raise' do
      stub_request(:get, "#{MAILERLITE_API_URL}/emails/123/html")
        .to_return(status: 503, body: '<html><body>Service Unavailable</body></html>', headers: { 'Content-Type' => 'text/html' })

      response = emails.get_html('123')

      expect(response.code).to eq 503
      expect(response.api_error.status).to eq 503
      expect(response.api_error.api_message).to be_nil
    end

    it 'checks the email ID and sends no request' do
      expect_invalid_ids('email_id') { |id| emails.get_html(id) }
    end
  end
end
