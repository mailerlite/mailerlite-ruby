# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailerLite::AutomationEmails do
  let(:client) { MailerLite::Client.new }
  let(:emails) { described_class.new(client: client) }

  describe '#content' do
    it 'sends GET /automations/{automation}/emails/{email}/content' do
      stub = stub_api(:get, '/automations/1/emails/2/content')
      emails.content(automation_id: 1, email_id: 2)
      expect(stub).to have_been_requested
    end
  end

  describe '#update_content' do
    it 'sends PUT /automations/{automation}/emails/{email}/content' do
      stub = stub_api(:put, '/automations/1/emails/2/content', body: { 'html' => '<p>Hi</p>' })
      emails.update_content(automation_id: 1, email_id: 2, html: '<p>Hi</p>')
      expect(stub).to have_been_requested
    end
  end

  describe '#report_stats' do
    it 'sends GET /automations/{automation}/emails/{email}/report-stats with the query' do
      stub = stub_api(:get, '/automations/1/emails/2/report-stats', query: { 'start_date' => '2026-01-01', 'end_date' => '2026-01-31', 'shop_id' => '3', 'excel' => '0' })
      emails.report_stats(automation_id: 1, email_id: 2, start_date: '2026-01-01', end_date: '2026-01-31', shop_id: '3', excel: false)
      expect(stub).to have_been_requested
    end
  end

  describe '#unsubscribe_reasons' do
    it 'sends GET /automations/{automation}/emails/{email}/unsubscribe-reasons' do
      stub = stub_api(:get, '/automations/1/emails/2/unsubscribe-reasons')
      emails.unsubscribe_reasons(automation_id: 1, email_id: 2)
      expect(stub).to have_been_requested
    end
  end
end
