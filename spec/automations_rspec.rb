# frozen_string_literal: true

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
  config.filter_sensitive_data('<AUTH>') do |interaction|
    interaction.request.headers['Authorization'][0]
  end
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
        response = automations.fetch(75_040_845_299_975_641)
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
          automation_id: '75040845299975641',
          filter: { status: 'completed' }
        )
        # body = JSON.parse(response.body)
        expect(response.status).to eq 200
        # expect(Integer(body['data']['id'])).to be_an Integer
      end
    end
  end

  describe '#get with every filter' do
    it 'sends the documented query params' do
      stub = stub_api(:get, '/automations', query: {
                        'filter[status]' => 'true', 'filter[name]' => 'Welcome', 'filter[group]' => '1', 'filter[folder]' => '2',
                        'filter[enabled]' => '1', 'filter[automation_state]' => 'workflows', 'filter[drafts_state]' => 'complete_workflow',
                        'limit' => '10', 'page' => '2', 'sort' => '-created_at', 'with_steps' => '0'
                      })

      automations.get(
        filter: { status: true, name: 'Welcome', group: 1, folder: 2, enabled: 1, automation_state: 'workflows', drafts_state: 'complete_workflow' },
        limit: 10, page: 2, sort: '-created_at', with_steps: false
      )

      expect(stub).to have_been_requested
    end
  end

  describe '#create' do
    it 'sends POST /automations' do
      stub = stub_api(:post, '/automations', body: { 'name' => 'Welcome' })
      automations.create(name: 'Welcome')
      expect(stub).to have_been_requested
    end
  end

  describe '#update' do
    it 'sends PUT /automations/{automation}' do
      stub = stub_api(:put, '/automations/1', body: { 'name' => 'Welcome', 'trigger_data' => { 'group_ids' => ['2'] }, 'triggers' => [{ 'type' => 'manual' }] })
      automations.update(automation_id: 1, name: 'Welcome', trigger_data: { 'group_ids' => ['2'] }, triggers: [{ 'type' => 'manual' }])
      expect(stub).to have_been_requested
    end
  end

  describe '#delete' do
    it 'sends DELETE /automations/{automation}' do
      stub = stub_api(:delete, '/automations/1')
      automations.delete(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#copy' do
    it 'sends POST /automations/{automation}/copy' do
      stub = stub_api(:post, '/automations/1/copy')
      automations.copy(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#enable' do
    it 'sends POST /automations/{automation}/enable' do
      stub = stub_api(:post, '/automations/1/enable')
      automations.enable(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#disable' do
    it 'sends POST /automations/{automation}/disable' do
      stub = stub_api(:post, '/automations/1/disable')
      automations.disable(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#test' do
    it 'sends POST /automations/{automation}/test' do
      stub = stub_api(:post, '/automations/1/test', body: { 'email' => 'a@b.com' })
      automations.test(automation_id: 1, email: 'a@b.com')
      expect(stub).to have_been_requested
    end
  end

  describe '#get_subscriber_activity search' do
    it 'sends filter[search] and sort' do
      stub = stub_api(:get, '/automations/1/activity', query: { 'filter[status]' => 'completed', 'filter[search]' => 'a@b.com', 'sort' => '-id' })
      automations.get_subscriber_activity(automation_id: 1, filter: { status: 'completed', search: 'a@b.com' }, sort: '-id')
      expect(stub).to have_been_requested
    end

    it 'sends the old filter[:keyword] as filter[search]' do
      stub = stub_api(:get, '/automations/1/activity', query: { 'filter[status]' => 'completed', 'filter[search]' => 'a@b.com' })
      automations.get_subscriber_activity(automation_id: 1, filter: { status: 'completed', keyword: 'a@b.com' })
      expect(stub).to have_been_requested
    end
  end

  describe '#get_subscriber_activity with_subscribers' do
    it 'sends with_subscribers=1 when true' do
      stub = stub_api(:get, '/automations/1/activity', query: { 'filter[status]' => 'active', 'with_subscribers' => '1' })
      automations.get_subscriber_activity(automation_id: 1, filter: { status: 'active' }, with_subscribers: true)
      expect(stub).to have_been_requested
    end

    it 'omits with_subscribers when false' do
      stub = stub_api(:get, '/automations/1/activity', query: { 'filter[status]' => 'active' })
      automations.get_subscriber_activity(automation_id: 1, filter: { status: 'active' }, with_subscribers: false)
      expect(stub).to have_been_requested
    end
  end

  describe '#add_subscribers' do
    it 'sends POST /automations/{automation}/add-subscribers' do
      stub = stub_api(:post, '/automations/1/add-subscribers', body: { 'step_id' => 2, 'emails' => ['a@b.com'], 'groups' => ['3'] })
      automations.add_subscribers(automation_id: 1, step_id: 2, emails: ['a@b.com'], groups: ['3'])
      expect(stub).to have_been_requested
    end
  end

  describe '#readd' do
    it 'sends POST /automations/{automation}/readd' do
      stub = stub_api(:post, '/automations/1/readd', body: {
                        'readd_subscribers_to' => 'selected_step', 'selected_step_id' => '2', 'filter' => { 'status' => 'completed', 'id' => ['5'] }
                      })
      automations.readd(automation_id: 1, readd_subscribers_to: 'selected_step', selected_step_id: '2', filter: { status: 'completed', id: ['5'] })
      expect(stub).to have_been_requested
    end
  end

  describe '#add_activity_to_group' do
    it 'sends POST /automations/{automation}/activity/add-to-group' do
      stub = stub_api(:post, '/automations/1/activity/add-to-group', body: { 'destination_groups' => ['3'], 'filter' => { 'status' => 'active' } })
      automations.add_activity_to_group(automation_id: 1, destination_groups: ['3'], filter: { status: 'active' })
      expect(stub).to have_been_requested
    end
  end

  describe '#cancel_activity' do
    it 'sends POST /automations/{automation}/activity/cancel-automation' do
      stub = stub_api(:post, '/automations/1/activity/cancel-automation', body: { 'filter' => { 'status' => 'active', 'next_step' => 4 } })
      automations.cancel_activity(automation_id: 1, filter: { status: 'active', next_step: 4 })
      expect(stub).to have_been_requested
    end
  end

  describe '#skip_activity_delay' do
    it 'sends POST /automations/{automation}/activity/skip-delay' do
      stub = stub_api(:post, '/automations/1/activity/skip-delay', body: { 'filter' => { 'status' => 'active', 'search' => 'a@b.com' } })
      automations.skip_activity_delay(automation_id: 1, filter: { status: 'active', search: 'a@b.com' })
      expect(stub).to have_been_requested
    end
  end
end
