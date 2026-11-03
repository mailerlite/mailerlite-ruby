# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Automation from MailerLite API.
  class Automations
    attr_reader :client

    # Inits the `Automations` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of Automations that match the specified filter criteria.
    #
    # @param filter[:status,:name,:group,:folder,:enabled,:automation_state,:drafts_state] [Array] filters for automation
    # @param limit [Integer] the maximum number of Automations to return
    # @param page [Integer] the page number of the results to return
    # @param sort [String] the field to sort by, prefix with - for descending order
    # @param with_steps [Boolean] include the steps of each Automation, defaults to true
    # @return [HTTP::Response] the response from the API
    def get(limit: nil, page: nil, filter: {}, sort: nil, with_steps: nil)
      params = {}
      %i[status name group folder enabled automation_state drafts_state].each do |key|
        params["filter[#{key}]"] = filter[key] if filter.key?(key)
      end
      params['limit'] = limit if limit
      params['page'] = page if page
      params['sort'] = sort if sort
      params['with_steps'] = QueryParams.boolean(with_steps)
      uri = URI("#{MAILERLITE_API_URL}/automations")
      uri.query = URI.encode_www_form(params.compact)
      client.http.get(uri)
    end

    # fetch the specified Automation
    #
    # @param automation_id [String] the ID of the Automation to fetch
    # @return [HTTP::Response] the response from the API
    def fetch(automation_id)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}")
    end

    # Creates an Automation
    #
    # @param name [String] the name of the Automation
    # @return [HTTP::Response] the response from the API
    def create(name:)
      client.http.post("#{MAILERLITE_API_URL}/automations", json: { 'name' => name })
    end

    # Updates the specified Automation
    #
    # @param automation_id [String] the ID of the Automation to update
    # @param name [String] the name of the Automation
    # @param trigger_data [Hash] the settings of the first trigger
    # @param triggers [Array] the triggers of the Automation
    # @return [HTTP::Response] the response from the API
    def update(automation_id:, name:, trigger_data: nil, triggers: nil)
      params = { 'name' => name, 'trigger_data' => trigger_data, 'triggers' => triggers }
      client.http.put("#{MAILERLITE_API_URL}/automations/#{automation_id}", json: params.compact)
    end

    # Deletes the specified Automation
    #
    # @param automation_id [String] the ID of the Automation to delete
    # @return [HTTP::Response] the response from the API
    def delete(automation_id)
      client.http.delete("#{MAILERLITE_API_URL}/automations/#{automation_id}")
    end

    # Copies the specified Automation
    #
    # @param automation_id [String] the ID of the Automation to copy
    # @return [HTTP::Response] the response from the API
    def copy(automation_id)
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/copy")
    end

    # Enables the specified Automation
    #
    # @param automation_id [String] the ID of the Automation to enable
    # @return [HTTP::Response] the response from the API
    def enable(automation_id)
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/enable")
    end

    # Disables the specified Automation
    #
    # @param automation_id [String] the ID of the Automation to disable
    # @return [HTTP::Response] the response from the API
    def disable(automation_id)
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/disable")
    end

    # Sends the emails of the specified Automation to a test address
    #
    # @param automation_id [String] the ID of the Automation to test
    # @param email [String] the address to send the test emails to
    # @return [HTTP::Response] the response from the API
    def test(automation_id:, email:)
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/test", json: { 'email' => email })
    end

    # Adds subscribers to the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @param step_id [Integer] the step to start the subscribers at
    # @param emails [Array] the email addresses of the subscribers to add
    # @param groups [Array] the IDs of the groups whose subscribers to add
    # @return [HTTP::Response] the response from the API
    def add_subscribers(automation_id:, step_id: nil, emails: nil, groups: nil)
      params = { 'step_id' => step_id, 'emails' => emails, 'groups' => groups }
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/add-subscribers", json: params.compact)
    end

    # Adds subscribers back to the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @param readd_subscribers_to [String] last_completed_step, selected_step or last_failed_step
    # @param filter [Hash] the activity to re-add, with status and optional search, date_from, date_to, id and step
    # @param selected_step_id [String] the step to re-add the subscribers to, when readd_subscribers_to is selected_step
    # @return [HTTP::Response] the response from the API
    def readd(automation_id:, readd_subscribers_to:, filter:, selected_step_id: nil)
      params = { 'readd_subscribers_to' => readd_subscribers_to, 'filter' => filter, 'selected_step_id' => selected_step_id }
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/readd", json: params.compact)
    end

    # Adds the subscribers in the activity of the specified Automation to groups
    #
    # @param automation_id [String] the ID of the Automation
    # @param destination_groups [Array] the IDs of the groups to add the subscribers to
    # @param filter [Hash] the activity to act on, with status and optional id, search and date filters
    # @return [HTTP::Response] the response from the API
    def add_activity_to_group(automation_id:, destination_groups:, filter:)
      params = { 'destination_groups' => destination_groups, 'filter' => filter }
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/activity/add-to-group", json: params)
    end

    # Cancels the active runs in the activity of the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @param filter [Hash] the activity to act on, with status active and optional id, search and date filters
    # @return [HTTP::Response] the response from the API
    def cancel_activity(automation_id:, filter:)
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/activity/cancel-automation", json: { 'filter' => filter })
    end

    # Skips the current delay of the active runs in the activity of the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @param filter [Hash] the activity to act on, with status active and optional id, search and date filters
    # @return [HTTP::Response] the response from the API
    def skip_activity_delay(automation_id:, filter:)
      client.http.post("#{MAILERLITE_API_URL}/automations/#{automation_id}/activity/skip-delay", json: { 'filter' => filter })
    end

    # get_subscriber_activity the subscriber activity for specified Automation
    #
    # @param automation_id [Integer] the ID of the Automation to get_subscriber_activity
    # @param filter[:status,:date_from,:date_to,:scheduled_from,:scheduled_to,:search] [Array] Must be one of the following: completed, active, canceled, failed
    # @param filter[:keyword] [String] deprecated, sent as filter[search], use filter[:search]
    # @param limit [Integer] the maximum number of Automations to return
    # @param page [Integer] the page number of the results to return
    # @param sort [String] the field to sort by, prefix with - for descending order
    # @param with_subscribers [Boolean] include the id, email and name of each subscriber
    # @return [HTTP::Response] the response from the API
    def get_subscriber_activity(automation_id:, filter: {}, page: nil, limit: nil, sort: nil, with_subscribers: nil)
      params = { 'filter[status]' => filter[:status] }
      params['filter[date_from]'] = filter[:date_from] if filter.key?(:date_from)
      params['filter[date_to]'] = filter[:date_to] if filter.key?(:date_to)
      params['filter[scheduled_from]'] = filter[:scheduled_from] if filter.key?(:scheduled_from)
      params['filter[scheduled_to]'] = filter[:scheduled_to] if filter.key?(:scheduled_to)
      params['filter[search]'] = filter.fetch(:search, filter[:keyword])
      params['page'] = page if page
      params['limit'] = limit if limit
      params['sort'] = sort if sort
      params['with_subscribers'] = 1 if with_subscribers
      uri = URI("#{MAILERLITE_API_URL}/automations/#{automation_id}/activity")
      uri.query = URI.encode_www_form(params.compact)
      client.http.get(uri)
    end
  end
end
