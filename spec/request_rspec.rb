# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'json'
require_relative 'support/json_fixture'

RSpec.describe MailerLite::Request do
  include_context 'with the dummy API token'

  let(:client) { MailerLite::Client.new }
  let(:api) { MAILERLITE_API_URL }

  # WebMock normalizes the URI (for example `+` becomes `%20`), so keep the raw URI that http.rb sends.
  def capture_raw_uris
    uris = []
    allow_any_instance_of(HTTP::Client).to receive(:perform).and_wrap_original do |method, request, options|
      uris << request.uri.to_s
      method.call(request, options)
    end
    uris
  end

  it 'sends a PATCH request with the JSON body' do
    stub = stub_request(:patch, "#{api}/emails/1/settings")
           .with { |req| req.body == '{"layout":{"alignment":"left"},"etag":"42"}' }
           .to_return(status: 200, body: '{}')

    described_class.call(client, :patch, '/emails/1/settings', json: { 'layout' => { 'alignment' => 'left' }, 'etag' => '42' })

    expect(stub).to have_been_requested
  end

  it 'sends a DELETE request with the JSON body' do
    stub = stub_request(:delete, "#{api}/emails/1/blocks/2")
           .with { |req| req.body == '{"etag":"42"}' }
           .to_return(status: 200, body: '{"etag":"43"}')

    described_class.call(client, :delete, '/emails/1/blocks/2', json: { 'etag' => '42' })

    expect(stub).to have_been_requested
  end

  it 'sends no body, not null, when there is no body' do
    stub = stub_request(:post, "#{api}/emails/1/versions")
           .with { |req| req.body == '' }
           .to_return(status: 201, body: '{}')

    described_class.call(client, :post, '/emails/1/versions')

    expect(stub).to have_been_requested
  end

  it 'sends the query and encodes a space as +' do
    uris = capture_raw_uris
    stub = stub_request(:get, "#{api}/files")
           .with(query: { 'filter[name]' => 'summer sale', 'filter[type]' => '', 'page' => '2' })
           .to_return(status: 200, body: '{}')

    described_class.call(client, :get, '/files', query: { 'filter[name]' => 'summer sale', 'filter[type]' => '', 'page' => 2 })

    expect(stub).to have_been_requested
    expect(uris).to eq ["#{api}/files?filter%5Bname%5D=summer+sale&filter%5Btype%5D=&page=2"]
  end

  it 'sends no query for an empty query' do
    uris = capture_raw_uris
    stub_request(:get, "#{api}/emails/1/versions").to_return(status: 200, body: '{}')

    described_class.call(client, :get, '/emails/1/versions', query: {})

    expect(uris).to eq ["#{api}/emails/1/versions"]
  end

  it 'sends the Authorization header and no Idempotency-Key header without a key' do
    stub = stub_request(:post, "#{api}/emails/1/versions")
           .with(headers: { 'Authorization' => 'Bearer dummy_token' })
           .with { |req| !req.headers.key?('Idempotency-Key') }
           .to_return(status: 201, body: '{}')

    described_class.call(client, :post, '/emails/1/versions')

    expect(stub).to have_been_requested
  end

  it 'sends the Idempotency-Key header with a key' do
    stub = stub_request(:post, "#{api}/emails/1/versions")
           .with(headers: { 'Idempotency-Key' => 'key-1' })
           .to_return(status: 201, body: '{}')

    described_class.call(client, :post, '/emails/1/versions', idempotency_key: 'key-1')

    expect(stub).to have_been_requested
  end

  it 'sends a key with a space at the end as given' do
    stub = stub_request(:post, "#{api}/emails/1/versions")
           .with { |req| req.headers['Idempotency-Key'] == 'a b ' }
           .to_return(status: 400, body: '{"message":"The idempotency key is not valid."}')

    response = described_class.call(client, :post, '/emails/1/versions', idempotency_key: 'a b ')

    expect(stub).to have_been_requested
    expect(response.api_error.status).to eq 400
  end

  it 'returns the HTTP::Response with the ApiResponse methods' do
    stub_request(:get, "#{api}/emails/1").to_return(status: 409, body: '{"message":"Conflict.","code":"version_conflict","etag":"9"}')

    response = described_class.call(client, :get, '/emails/1')

    expect(response).to be_a(HTTP::Response)
    expect(response.code).to eq 409
    expect(response.api_error.etag).to eq '9'
    expect(response.idempotent_replay?).to be(false)
  end

  it 'reads the base URL when the request runs' do
    original = MAILERLITE_API_URL
    Object.send(:remove_const, :MAILERLITE_API_URL)
    Object.const_set(:MAILERLITE_API_URL, 'http://api.example.com/api')
    stub = stub_request(:get, 'http://api.example.com/api/emails/1').to_return(status: 200, body: '{}')

    described_class.call(client, :get, '/emails/1')

    expect(stub).to have_been_requested
  ensure
    Object.send(:remove_const, :MAILERLITE_API_URL)
    Object.const_set(:MAILERLITE_API_URL, original)
  end

  it 'does not change the Hashes of the caller' do
    body = { 'etag' => '42' }.freeze
    query = { 'page' => 1 }.freeze
    stub_request(:delete, "#{api}/emails/1/blocks/2?page=1").to_return(status: 200, body: '{}')

    expect { described_class.call(client, :delete, '/emails/1/blocks/2', json: body, query: query) }.not_to raise_error
  end
end
