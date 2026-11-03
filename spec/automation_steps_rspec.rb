# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailerLite::AutomationSteps do
  let(:client) { MailerLite::Client.new }
  let(:steps) { described_class.new(client: client) }

  describe '#list' do
    it 'sends GET /automations/{automation}/steps/index' do
      stub = stub_api(:get, '/automations/1/steps/index')
      steps.list(1)
      expect(stub).to have_been_requested
    end
  end

  describe '#create' do
    it 'sends POST /automations/{automation}/steps' do
      stub = stub_api(:post, '/automations/1/steps', body: {
                        'type' => 'action', 'parent_id' => 2, 'branch' => 'yes', 'move_to_branch' => 'no',
                        'data' => { 'action_type' => 'copy_to_group', 'group_id' => '3' }
                      })
      steps.create(automation_id: 1, type: 'action', parent_id: 2, branch: 'yes', move_to_branch: 'no',
                   data: { 'action_type' => 'copy_to_group', 'group_id' => '3' })
      expect(stub).to have_been_requested
    end
  end

  describe '#fetch' do
    it 'sends GET /automations/{automation}/steps/{step}' do
      stub = stub_api(:get, '/automations/1/steps/2')
      steps.fetch(automation_id: 1, step_id: 2)
      expect(stub).to have_been_requested
    end
  end

  describe '#update' do
    it 'sends PUT /automations/{automation}/steps/{step}' do
      stub = stub_api(:put, '/automations/1/steps/2', body: { 'parent_id' => 3, 'data' => { 'value' => 2 }, 'reschedule_waiting_subscribers' => true })
      steps.update(automation_id: 1, step_id: 2, parent_id: 3, data: { 'value' => 2 }, reschedule_waiting_subscribers: true)
      expect(stub).to have_been_requested
    end
  end

  describe '#delete' do
    it 'sends DELETE /automations/{automation}/steps/{step} with branch_to_delete' do
      stub = stub_api(:delete, '/automations/1/steps/2', query: { 'branch_to_delete' => 'yes' })
      steps.delete(automation_id: 1, step_id: 2, branch_to_delete: 'yes')
      expect(stub).to have_been_requested
    end
  end

  describe '#copy' do
    it 'sends POST /automations/{automation}/steps/{step}/copy' do
      stub = stub_api(:post, '/automations/1/steps/2/copy', body: { 'parent_id' => 3, 'branch' => 'a_path', 'move_to_branch' => 'yes' })
      steps.copy(automation_id: 1, step_id: 2, parent_id: 3, branch: 'a_path', move_to_branch: 'yes')
      expect(stub).to have_been_requested
    end
  end

  describe '#reorder' do
    it 'sends POST /automations/{automation}/steps/reorder' do
      stub = stub_api(:post, '/automations/1/steps/reorder', body: { 'dragged_step_id' => 2, 'new_parent_step_id' => 3, 'branch' => 'no', 'branch_for_child' => 'yes' })
      steps.reorder(automation_id: 1, dragged_step_id: 2, new_parent_step_id: 3, branch: 'no', branch_for_child: 'yes')
      expect(stub).to have_been_requested
    end
  end

  describe '#select_ab_test_winner' do
    it 'sends PUT /automations/{automation}/steps/{step}/select-ab-test-winner' do
      stub = stub_api(:put, '/automations/1/steps/2/select-ab-test-winner', body: { 'ab_test_winner' => 'b_path' })
      steps.select_ab_test_winner(automation_id: 1, step_id: 2, ab_test_winner: 'b_path')
      expect(stub).to have_been_requested
    end
  end
end
