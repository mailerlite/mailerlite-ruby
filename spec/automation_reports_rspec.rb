# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailerLite::AutomationReports do
  let(:client) { MailerLite::Client.new }
  let(:reports) { described_class.new(client: client) }

  describe '#step_run_counts' do
    it 'sends GET /automations/{automation}/steps/run-counts' do
      stub = stub_api(:get, '/automations/1/steps/run-counts')
      reports.step_run_counts(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#step_run_count' do
    it 'sends GET /automations/{automation}/steps/run-counts/{step}' do
      stub = stub_api(:get, '/automations/1/steps/run-counts/2')
      reports.step_run_count(automation_id: 1, step_id: 2)
      expect(stub).to have_been_requested
    end
  end

  describe '#trigger_run_counts' do
    it 'sends GET /automations/{automation}/triggers/run-counts' do
      stub = stub_api(:get, '/automations/1/triggers/run-counts')
      reports.trigger_run_counts(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#trigger_run_count' do
    it 'sends GET /automations/{automation}/triggers/run-counts/{trigger}' do
      stub = stub_api(:get, '/automations/1/triggers/run-counts/2')
      reports.trigger_run_count(automation_id: 1, trigger_id: 2)
      expect(stub).to have_been_requested
    end
  end

  describe '#ab_steps_stats' do
    it 'sends GET /automations/{automation}/ab-steps-stats' do
      stub = stub_api(:get, '/automations/1/ab-steps-stats')
      reports.ab_steps_stats(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#ab_step_stats' do
    it 'sends GET /automations/{automation}/ab-steps-stats/{step}' do
      stub = stub_api(:get, '/automations/1/ab-steps-stats/2')
      reports.ab_step_stats(automation_id: 1, step_id: 2)
      expect(stub).to have_been_requested
    end
  end

  describe '#step_subscribers' do
    it 'sends GET /automations/{automation}/activity/steps/{step}/subscribers with the query' do
      stub = stub_api(:get, '/automations/1/activity/steps/2/subscribers', query: {
                        'status' => 'queued', 'limit' => '10', 'page' => '2', 'sort' => '-id',
                        'filter[date_from]' => '2026-01-01', 'filter[date_to]' => '2026-01-31', 'filter[search]' => 'a@b.com', 'filter[id]' => '5'
                      })
      reports.step_subscribers(automation_id: 1, step_id: 2, status: 'queued', limit: 10, page: 2, sort: '-id',
                               filter: { date_from: '2026-01-01', date_to: '2026-01-31', search: 'a@b.com', id: '5' })
      expect(stub).to have_been_requested
    end
  end

  describe '#step_subscribers with an Array filter[:id]' do
    it 'sends the ids as one comma-separated value' do
      stub = stub_api(:get, '/automations/1/activity/steps/2/subscribers', query: { 'status' => 'queued', 'filter[id]' => '5,6' })
      reports.step_subscribers(automation_id: 1, step_id: 2, status: 'queued', filter: { id: %w[5 6] })
      expect(stub).to have_been_requested
    end
  end

  describe '#trigger_subscribers' do
    it 'sends GET /automations/{automation}/activity/triggers/{trigger}/subscribers with the query' do
      stub = stub_api(:get, '/automations/1/activity/triggers/2/subscribers', query: { 'status' => 'completed', 'filter[search]' => 'a@b.com' })
      reports.trigger_subscribers(automation_id: 1, trigger_id: 2, status: 'completed', filter: { search: 'a@b.com' })
      expect(stub).to have_been_requested
    end
  end

  describe '#email_monthly_totals' do
    it 'sends GET /automations/{automation}/monthly-totals/email with the query' do
      stub = stub_api(:get, '/automations/1/monthly-totals/email', query: { 'start_date' => '2026-01-01', 'end_date' => '2026-06-30', 'shop_id' => '3', 'excel' => '1' })
      reports.email_monthly_totals(automation_id: 1, start_date: '2026-01-01', end_date: '2026-06-30', shop_id: '3', excel: true)
      expect(stub).to have_been_requested
    end
  end
end
