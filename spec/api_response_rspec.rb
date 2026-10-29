# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'json'
require_relative 'support/json_fixture'

RSpec.describe MailerLite::ApiResponse do
  let(:url) { "#{MAILERLITE_API_URL}/emails/123" }

  # Returns a real HTTP::Response from WebMock, extended with ApiResponse.
  def response_for(status:, body: '', headers: {})
    stub_request(:get, url).to_return(status: status, body: body, headers: headers)
    MailerLite::Client.new.http.get(url).extend(described_class)
  end

  describe '#idempotent_replay?' do
    it 'is true for the value true' do
      expect(response_for(status: 201, headers: { 'Idempotent-Replayed' => 'true' }).idempotent_replay?).to be(true)
    end

    it 'reads the value without case and without spaces' do
      expect(response_for(status: 201, headers: { 'Idempotent-Replayed' => 'True' }).idempotent_replay?).to be(true)
      expect(response_for(status: 201, headers: { 'Idempotent-Replayed' => ' TRUE ' }).idempotent_replay?).to be(true)
    end

    it 'is false when the header is not there' do
      expect(response_for(status: 201).idempotent_replay?).to be(false)
    end

    it 'is false for other values' do
      expect(response_for(status: 201, headers: { 'Idempotent-Replayed' => 'false' }).idempotent_replay?).to be(false)
    end

    it 'reads a header that comes two times' do
      expect(response_for(status: 201, headers: { 'Idempotent-Replayed' => %w[true true] }).idempotent_replay?).to be(true)
      expect(response_for(status: 201, headers: { 'Idempotent-Replayed' => %w[false false] }).idempotent_replay?).to be(false)
    end
  end

  describe '#api_error' do
    it 'is nil for a 2xx status' do
      response = response_for(status: 200, body: load_fixture('email').to_json)
      expect(response.api_error).to be_nil
      expect(response).to be_a(HTTP::Response)
    end

    it 'has the code and the etag of a 409 version conflict' do
      body = { message: 'The email was changed.', code: 'version_conflict', etag: '45' }.to_json
      error = response_for(status: 409, body: body).api_error

      expect(error).to be_a(MailerLite::ApiError)
      expect(error.status).to eq 409
      expect(error.code).to eq 'version_conflict'
      expect(error.etag).to eq '45'
      expect(error.api_message).to eq 'The email was changed.'
      expect(error.errors).to be_nil
      expect(error.message).to start_with('409')
      expect(error.message).to include('(version_conflict): The email was changed.')
    end

    it 'has no code for a 409 without a code' do
      error = response_for(status: 409, body: { message: 'The campaign is not a draft.' }.to_json).api_error

      expect(error.status).to eq 409
      expect(error.code).to be_nil
      expect(error.etag).to be_nil
      expect(error.message).to include(': The campaign is not a draft.')
    end

    it 'has the errors of a 422' do
      body = { message: 'The etag field is required.', errors: { etag: ['The etag field is required.'] } }.to_json
      error = response_for(status: 422, body: body).api_error

      expect(error.status).to eq 422
      expect(error.errors).to eq('etag' => ['The etag field is required.'])
      expect(error.api_message).to eq 'The etag field is required.'
    end

    it 'has no errors for a 422 with only a message' do
      error = response_for(status: 422, body: { message: 'This email was not built with the simple editor.' }.to_json).api_error

      expect(error.errors).to be_nil
      expect(error.api_message).to eq 'This email was not built with the simple editor.'
    end

    it 'does not raise for a 503 with an HTML body' do
      html = '<html><body>Service Unavailable</body></html>'
      error = response_for(status: 503, body: html, headers: { 'Content-Type' => 'text/html' }).api_error

      expect(error.status).to eq 503
      expect(error.api_message).to be_nil
      expect(error.code).to be_nil
      expect(error.body).to eq html
      expect(error.headers['Content-Type']).to eq 'text/html'
      expect(error.message).to start_with('503')
    end

    it 'accepts a JSON body that is not an object' do
      error = response_for(status: 500, body: '[1, 2]').api_error

      expect(error.status).to eq 500
      expect(error.api_message).to be_nil
      expect(error.body).to eq '[1, 2]'
    end

    it 'survives a Marshal round trip' do
      body = { message: 'The email was changed.', code: 'version_conflict', etag: '45' }.to_json
      error = response_for(status: 409, body: body).api_error
      copy = Marshal.load(Marshal.dump(error))

      expect(copy).to be_a(MailerLite::ApiError)
      expect(copy.message).to eq error.message
      expect([copy.status, copy.code, copy.etag, copy.api_message, copy.body]).to eq [409, 'version_conflict', '45', 'The email was changed.', body]
    end
  end

  describe MailerLite::ApiError do
    it 'is a MailerLite::Error and not an HTTP::Error' do
      expect(described_class.ancestors).to include(MailerLite::Error)
      expect(described_class.ancestors).not_to include(HTTP::Error)
    end

    it 'builds an error from any HTTP::Response' do
      stub_request(:get, url).to_return(status: 404, body: { message: 'Not found.' }.to_json)
      error = described_class.from_response(MailerLite::Client.new.http.get(url))

      expect(error.status).to eq 404
      expect(error.api_message).to eq 'Not found.'
    end

    it 'can be raised' do
      stub_request(:get, url).to_return(status: 404, body: { message: 'Not found.' }.to_json)
      error = described_class.from_response(MailerLite::Client.new.http.get(url))

      expect { raise error }.to raise_error(described_class, /Not found\./)
    end
  end
end
