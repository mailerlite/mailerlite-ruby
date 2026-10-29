# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'json'
require_relative 'support/json_fixture'

RSpec.describe MailerLite::Files do
  let(:files) { described_class.new(client: MailerLite::Client.new) }
  let(:url) { "#{MAILERLITE_API_URL}/files" }

  def stub_files(query: nil, status: 200, response: load_fixture('files'))
    stub = stub_request(:get, url).with(headers: { 'Authorization' => 'Bearer dummy_token' }) { |req| req.body == '' }
    stub = stub.with(query: query) if query
    stub.to_return(status: status, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  # WebMock normalizes the URI (for example `+` becomes `%20`), so keep the raw URI that http.rb sends.
  def capture_raw_uris
    uris = []
    allow_any_instance_of(HTTP::Client).to receive(:perform).and_wrap_original do |method, request, options|
      uris << request.uri.to_s
      method.call(request, options)
    end
    uris
  end

  it 'has the constants of the API' do
    expect([described_class::FileType::IMAGE, described_class::FileType::PDF, described_class::FileType::EPUB]).to eq %w[image pdf epub]
    sorts = described_class::FileSort
    expect([sorts::CREATED_AT, sorts::CREATED_AT_DESC, sorts::NAME, sorts::NAME_DESC, sorts::SIZE, sorts::SIZE_DESC])
      .to eq %w[created_at -created_at name -name size -size]
  end

  describe '#list' do
    it 'sends no query without arguments' do
      uris = capture_raw_uris
      stub = stub_files

      response = files.list

      expect(stub).to have_been_requested
      expect(uris).to eq [url]
      data = JSON.parse(response.body.to_s)
      expect(data['data'].map { |file| file['name'] }).to eq ['summer sale banner.png', 'summer sale terms.pdf']
      expect(data['data'][0]['width']).to eq 1200
      expect(data['data'][1]).to have_key('width')
      expect(data['data'][1]['width']).to be_nil
      expect(data['data'][1]['height']).to be_nil
      expect(data['links']).to have_key('next')
      expect(data['links']['next']).to be_nil
    end

    it 'sends the filter, the sort and the pages, and encodes a space as +' do
      uris = capture_raw_uris
      stub = stub_files(query: { 'filter[name]' => 'summer sale', 'filter[type]' => 'image', 'sort' => '-size', 'page' => '1', 'limit' => '25' })

      files.list(filter: { name: 'summer sale', type: described_class::FileType::IMAGE }, sort: described_class::FileSort::SIZE_DESC, page: 1, limit: 25)

      expect(stub).to have_been_requested
      expect(uris).to eq ["#{url}?filter%5Bname%5D=summer+sale&filter%5Btype%5D=image&sort=-size&page=1&limit=25"]
    end

    it 'drops a nil filter value and keeps an empty one' do
      uris = capture_raw_uris
      stub_files(query: { 'filter[type]' => '' })

      files.list(filter: { name: nil, type: '' })

      expect(uris).to eq ["#{url}?filter%5Btype%5D="]
    end

    it 'returns the 422 of a file type that is not valid' do
      stub_files(query: { 'filter[type]' => 'video' }, status: 422,
                 response: { message: 'The selected filter.type is invalid.', errors: { 'filter.type' => ['The selected filter.type is invalid.'] } })

      response = files.list(filter: { type: 'video' })

      expect(response.code).to eq 422
      expect(response.api_error.errors).to eq('filter.type' => ['The selected filter.type is invalid.'])
    end

    it 'checks the filter and sends no request' do
      expect { files.list(filter: 'image') }.to raise_error(TypeError, /`filter`/)
      expect(a_request(:any, /.*/)).not_to have_been_made
    end
  end
end
