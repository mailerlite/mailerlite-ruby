# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Automation triggers from MailerLite API.
  class AutomationTriggers
    attr_reader :client

    # Inits the `AutomationTriggers` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns the triggers of the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @return [HTTP::Response] the response from the API
    def list(automation_id)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/triggers")
    end

    # Adds a trigger to the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @param type [String] the trigger type, for example subscriber_joins_group
    # @param data [Hash] the settings of the trigger
    # @return [HTTP::Response] the response from the API
    def create(automation_id:, type:, data: nil)
      params = { 'type' => type, 'data' => data }
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/triggers", json: params.compact)
    end

    # Returns the specified trigger
    #
    # @param automation_id [String] the ID of the Automation
    # @param trigger_id [String] the ID of the trigger
    # @return [HTTP::Response] the response from the API
    def fetch(automation_id:, trigger_id:)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/triggers/#{trigger_id}")
    end

    # Updates the specified trigger
    #
    # @param automation_id [String] the ID of the Automation
    # @param trigger_id [String] the ID of the trigger
    # @param data [Hash] the settings of the trigger
    # @return [HTTP::Response] the response from the API
    def update(automation_id:, trigger_id:, data:)
      client.http.put("#{MAILERLITE_API_URL}/automations/#{automation_id}/triggers/#{trigger_id}", json: { 'data' => data })
    end

    # Deletes the specified trigger
    #
    # @param automation_id [String] the ID of the Automation
    # @param trigger_id [String] the ID of the trigger
    # @return [HTTP::Response] the response from the API
    def delete(automation_id:, trigger_id:)
      client.http.delete("#{MAILERLITE_API_URL}/automations/#{automation_id}/triggers/#{trigger_id}")
    end
  end
end
