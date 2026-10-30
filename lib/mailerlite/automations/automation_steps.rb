# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Automation steps from MailerLite API.
  class AutomationSteps
    attr_reader :client

    # Inits the `AutomationSteps` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns the steps of the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @return [HTTP::Response] the response from the API
    def list(automation_id)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/steps/index")
    end

    # Adds a step to the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @param type [String] email, condition, delay, action, abtest or webhook
    # @param parent_id [Integer] the ID of the step to add the new step after
    # @param branch [String] the branch of the parent step: yes, no, a_path, b_path or c_path
    # @param move_to_branch [String] the branch of the new step to move the following steps to: yes or no
    # @param data [Hash] the settings of the step
    # @return [HTTP::Response] the response from the API
    def create(automation_id:, type:, parent_id: nil, branch: nil, move_to_branch: nil, data: nil)
      params = { 'type' => type, 'parent_id' => parent_id, 'branch' => branch, 'move_to_branch' => move_to_branch, 'data' => data }
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/steps", json: params.compact)
    end

    # Returns the specified step
    #
    # @param automation_id [String] the ID of the Automation
    # @param step_id [String] the ID of the step
    # @return [HTTP::Response] the response from the API
    def fetch(automation_id:, step_id:)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/steps/#{step_id}")
    end

    # Updates the specified step
    #
    # @param automation_id [String] the ID of the Automation
    # @param step_id [String] the ID of the step
    # @param parent_id [Integer] the ID of the parent step
    # @param data [Hash] the settings of the step
    # @param reschedule_waiting_subscribers [Boolean] reschedule the subscribers waiting on a delay step
    # @return [HTTP::Response] the response from the API
    def update(automation_id:, step_id:, parent_id: nil, data: nil, reschedule_waiting_subscribers: nil)
      params = { 'parent_id' => parent_id, 'data' => data, 'reschedule_waiting_subscribers' => reschedule_waiting_subscribers }
      client.http.put("#{MAILERLITE_API_URL}/automations/#{automation_id}/steps/#{step_id}", json: params.compact)
    end

    # Deletes the specified step
    #
    # @param automation_id [String] the ID of the Automation
    # @param step_id [String] the ID of the step
    # @param branch_to_delete [String] all, yes or no for a condition step; all, a_path, b_path or c_path for an A/B test step
    # @return [HTTP::Response] the response from the API
    def delete(automation_id:, step_id:, branch_to_delete: nil)
      client.http.delete(QueryParams.uri("#{MAILERLITE_API_URL}/automations/#{automation_id}/steps/#{step_id}", { 'branch_to_delete' => branch_to_delete }))
    end

    # Copies the specified step
    #
    # @param automation_id [String] the ID of the Automation
    # @param step_id [String] the ID of the step to copy
    # @param parent_id [Integer] the ID of the step to add the copy after
    # @param branch [String] the branch of the parent step: yes, no, a_path, b_path or c_path
    # @param move_to_branch [String] the branch of the copy to move the following steps to: yes or no
    # @return [HTTP::Response] the response from the API
    def copy(automation_id:, step_id:, parent_id: nil, branch: nil, move_to_branch: nil)
      params = { 'parent_id' => parent_id, 'branch' => branch, 'move_to_branch' => move_to_branch }
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/steps/#{step_id}/copy", json: params.compact)
    end

    # Moves a step to another place in the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @param dragged_step_id [Integer] the ID of the step to move
    # @param new_parent_step_id [Integer] the ID of the step to move it after
    # @param branch [String] the branch of the new parent step: yes, no, a_path, b_path or c_path
    # @param branch_for_child [String] the branch of the moved step to attach the following steps to: yes or no
    # @return [HTTP::Response] the response from the API
    def reorder(automation_id:, dragged_step_id:, new_parent_step_id: nil, branch: nil, branch_for_child: nil)
      params = { 'dragged_step_id' => dragged_step_id, 'new_parent_step_id' => new_parent_step_id, 'branch' => branch, 'branch_for_child' => branch_for_child }
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/steps/reorder", json: params.compact)
    end

    # Selects the winning path of the specified A/B test step
    #
    # @param automation_id [String] the ID of the Automation
    # @param step_id [String] the ID of the A/B test step
    # @param ab_test_winner [String] a_path, b_path or c_path
    # @return [HTTP::Response] the response from the API
    def select_ab_test_winner(automation_id:, step_id:, ab_test_winner:)
      client.http.put("#{MAILERLITE_API_URL}/automations/#{automation_id}/steps/#{step_id}/select-ab-test-winner", json: { 'ab_test_winner' => ab_test_winner })
    end
  end
end
