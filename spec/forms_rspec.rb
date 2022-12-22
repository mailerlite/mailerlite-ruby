# Import the RSpec and VCR gems
require 'spec_helper'
require 'vcr'
require 'json'

# require "webmock/rspec"
# Import the `Forms` class

# Configure VCR to save and replay HTTP requests
VCR.configure do |config|
  config.cassette_library_dir = './fixtures'
  config.hook_into :webmock
  config.filter_sensitive_data('<AUTH>') { |interaction|
    interaction.request.headers['Authorization'][0]
  }
end

# Set up the test for the `Forms` class
RSpec.describe MailerLite::Forms do
  let(:client) { MailerLite::Client.new }
  let(:forms) { described_class.new(client: client) }


  describe '#list' do
    # Use VCR to record and replay the HTTP request
    it 'lists all form' do
      VCR.use_cassette('forms/list') do
        response = forms.list(type:'popup')
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end
  describe '#update' do
    # Use VCR to record and replay the HTTP request
    it 'updates a form' do
      VCR.use_cassette('forms/update') do
        response = forms.update(form:75017795259074408,name:'test_form2')
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end
  
  describe '#fetch' do
    # Use VCR to record and replay the HTTP request
    it 'fetchs all form' do
      VCR.use_cassette('forms/fetch') do
        response = forms.fetch(75016692854425001)
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end

  describe '#fetch_subscribers' do
    # Use VCR to record and replay the HTTP request
    it 'fetch_subscribers of a form' do
      VCR.use_cassette('forms/fetch_subscribers') do
        response = forms.fetch_subscribers(75231510415803781)
        body = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(body['data']).to be_an Array
      end
    end
  end

  describe '#delete' do
    # Use VCR to record and replay the HTTP request
    it 'deletes a form' do
      VCR.use_cassette('forms/delete') do
        response = forms.delete(75016692854425001)
        expect(response.status).to eq 204
      end
    end
  end
end