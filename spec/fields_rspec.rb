# Import the RSpec and VCR gems
require 'spec_helper'
require 'vcr'
require 'json'

# require "webmock/rspec"
# Import the `Fields` class

# Configure VCR to save and replay HTTP requests
VCR.configure do |config|
  config.cassette_library_dir = './fixtures'
  config.hook_into :webmock
  config.filter_sensitive_data('<AUTH>') { |interaction|
    interaction.request.headers['Authorization'][0]
  }
end

# Set up the test for the `Fields` class
RSpec.describe MailerLite::Fields do
  let(:client) { MailerLite::Client.new }
  let(:fields) { described_class.new(client: client) }


  describe '#get' do
    # Use VCR to record and replay the HTTP request
    it 'returns a list of Fields' do
      VCR.use_cassette('fields/get') do
        response = fields.get
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end

  describe '#create' do
    # Use VCR to record and replay the HTTP request
    it 'creates a field' do
      VCR.use_cassette('fields/create') do
        response = fields.create(type:'text',name:'test_field_name')
        body = JSON.parse(response.body)
        expect(response.status).to eq 201
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end

  describe '#update' do
    # Use VCR to record and replay the HTTP request
    it 'updates a field' do
      VCR.use_cassette('fields/update') do
        response = fields.update(field:91115,name:'test_field2')
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end

  describe '#delete' do
    # Use VCR to record and replay the HTTP request
    it 'deletes a field' do
      VCR.use_cassette('fields/delete') do
        response = fields.delete(91115)
        expect(response.status).to eq 204
      end
    end
  end

end