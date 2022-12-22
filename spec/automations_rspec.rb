# Import the RSpec and VCR gems
require 'spec_helper'
require 'vcr'
require 'json'

# require "webmock/rspec"
# Import the `Automations` class

# Configure VCR to save and replay HTTP requests
VCR.configure do |config|
  config.cassette_library_dir = './fixtures'
  config.hook_into :webmock
  config.filter_sensitive_data('<AUTH>') { |interaction|
    interaction.request.headers['Authorization'][0]
  }
end

# Set up the test for the `Automations` class
RSpec.describe MailerLite::Automations do
  let(:client) { MailerLite::Client.new }
  let(:automations) { described_class.new(client: client) }


  describe '#get' do
    # Use VCR to record and replay the HTTP request
    it 'gets all automation' do
      VCR.use_cassette('automations/get') do
        response = automations.get
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end
  
  describe '#fetch' do
    # Use VCR to record and replay the HTTP request
    it 'fetchs all automation' do
      VCR.use_cassette('automations/fetch') do
        response = automations.fetch(75040845299975641)
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end

  describe '#get_subscriber_activity' do
    # Use VCR to record and replay the HTTP request
    it 'get_subscriber_activitys all automation' do
      VCR.use_cassette('automations/get_subscriber_activity') do
        response = automations.get_subscriber_activity(
          automation:75040845299975641,
          filter_status: 'completed'
        )
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end


  # describe '#delete' do
  #   # Use VCR to record and replay the HTTP request
  #   it 'deletes a automation' do
  #     VCR.use_cassette('automations/delete') do
  #       response = automations.delete(75016692854425001)
  #       expect(response.status).to eq 204
  #     end
  #   end
  # end
end