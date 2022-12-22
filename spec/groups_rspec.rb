# frozen_string_literal: true

# Import the RSpec and VCR gems
require 'spec_helper'
require 'vcr'
require 'json'

# Configure VCR to save and replay HTTP requests
VCR.configure do |config|
  config.cassette_library_dir = './fixtures'
  config.hook_into :webmock
  config.filter_sensitive_data('<AUTH>') do |interaction|
    interaction.request.headers['Authorization'][0]
  end
end

# Set up the test for the `Groups` class
RSpec.describe MailerLite::Groups do
  let(:client) { MailerLite::Client.new }
  let(:groups) { described_class.new(client: client) }

  describe '#get' do
    # Use VCR to record and replay the HTTP request
    it 'returns a list of groups' do
      VCR.use_cassette('groups/get') do
        response = groups.get
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end
  describe '#create' do
    # Use VCR to record and replay the HTTP request
    it 'creates a group' do
      VCR.use_cassette('groups/create') do
        response = groups.create(name: 'test_group2')
        body = JSON.parse(response.body)
        expect(response.status).to eq 201
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end
  describe '#update' do
    # Use VCR to record and replay the HTTP request
    it 'updates a group' do
      VCR.use_cassette('groups/update') do
        response = groups.update(group: 75_138_589_423_306_653, name: 'test_group3')
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end

  describe '#delete' do
    # Use VCR to record and replay the HTTP request
    it 'deletes a group' do
      VCR.use_cassette('groups/delete') do
        response = groups.delete(75_138_589_423_306_653)
        expect(response.status).to eq 204
      end
    end
  end

  describe '#get_subscribers' do
    # Use VCR to record and replay the HTTP request
    it 'get_subscribers for a group' do
      VCR.use_cassette('groups/get_subscribers') do
        response = groups.get_subscribers(group: 75_011_449_370_445_335)
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end

  describe '#assign_subscribers' do
    # Use VCR to record and replay the HTTP request
    it 'assign_subscribers for a group' do
      VCR.use_cassette('groups/assign_subscriber') do
        response = groups.assign_subscriber(group: 75_138_557_045_376_452, subscriber: 75_009_808_379_414_225)
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
      end
    end
  end

  describe '#unassign_subscribers' do
    # Use VCR to record and replay the HTTP request
    it 'unassign_subscribers for a group' do
      VCR.use_cassette('groups/unassign_subscriber') do
        response = groups.unassign_subscriber(group: 75_138_557_045_376_452, subscriber: 75_009_808_379_414_225)
        expect(response.status).to eq 204
      end
    end
  end
end
