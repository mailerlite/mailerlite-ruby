# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'json'
require_relative 'support/json_fixture'

RSpec.describe MailerLite::BrandStyles do
  let(:brand_styles) { described_class.new(client: MailerLite::Client.new) }
  let(:url) { "#{MAILERLITE_API_URL}/brand-styles" }

  def stub_brand_styles(response)
    stub_request(:get, url)
      .with(headers: { 'Authorization' => 'Bearer dummy_token' }) { |req| req.body == '' && !req.headers.key?('Idempotency-Key') }
      .to_return(status: 200, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe '#get' do
    it 'gets the palettes' do
      stub = stub_brand_styles(load_fixture('brand_styles'))

      response = brand_styles.get

      expect(stub).to have_been_requested
      expect(response).to be_a(HTTP::Response)
      expect(response.api_error).to be_nil
      data = JSON.parse(response.body.to_s)['data']
      expect(data['brand']['identifier']).to eq 'account'
      expect(data['brand']['primary_color']).to eq '#2cb191'
      expect(data['default']['identifier']).to eq 'default-brand'
      expect(data['presets'].map { |preset| preset['identifier'] }).to eq %w[preset-business-casual preset-retro]
      expect(data['presets'][1]['font_family']).to eq 'Courier New, monospace'
    end

    it 'returns a null brand when the account has none' do
      body = load_fixture('brand_styles')
      body['data']['brand'] = nil
      stub_brand_styles(body)

      data = JSON.parse(brand_styles.get.body.to_s)['data']

      expect(data).to have_key('brand')
      expect(data['brand']).to be_nil
      expect(data['default']['identifier']).to eq 'default-brand'
    end
  end
end
