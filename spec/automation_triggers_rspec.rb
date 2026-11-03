# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailerLite::AutomationTriggers do
  let(:client) { MailerLite::Client.new }
  let(:triggers) { described_class.new(client: client) }

  describe '#list' do
    it 'sends GET /automations/{automation}/triggers' do
      stub = stub_api(:get, '/automations/1/triggers')
      triggers.list(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#create' do
    it 'sends POST /automations/{automation}/triggers' do
      stub = stub_api(:post, '/automations/1/triggers', body: { 'type' => 'subscriber_joins_group', 'data' => { 'group_ids' => ['2'] } })
      triggers.create(automation_id: 1, type: 'subscriber_joins_group', data: { 'group_ids' => ['2'] })
      expect(stub).to have_been_requested
    end
  end

  describe '#fetch' do
    it 'sends GET /automations/{automation}/triggers/{trigger}' do
      stub = stub_api(:get, '/automations/1/triggers/2')
      triggers.fetch(automation_id: 1, trigger_id: 2)
      expect(stub).to have_been_requested
    end
  end

  describe '#update' do
    it 'sends PUT /automations/{automation}/triggers/{trigger}' do
      stub = stub_api(:put, '/automations/1/triggers/2', body: { 'data' => { 'group_ids' => ['3'] } })
      triggers.update(automation_id: 1, trigger_id: 2, data: { 'group_ids' => ['3'] })
      expect(stub).to have_been_requested
    end
  end

  describe '#delete' do
    it 'sends DELETE /automations/{automation}/triggers/{trigger}' do
      stub = stub_api(:delete, '/automations/1/triggers/2')
      triggers.delete(automation_id: 1, trigger_id: 2)
      expect(stub).to have_been_requested
    end
  end
end
