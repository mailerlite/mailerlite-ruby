# frozen_string_literal: true

module MailerLite
  # This is a class for reading the Automation reports from MailerLite API.
  class AutomationReports
    attr_reader :client

    # Inits the `AutomationReports` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns the run counts of every step of the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @return [HTTP::Response] the response from the API
    def step_run_counts(automation_id)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/steps/run-counts")
    end

    # Returns the run counts of the specified step
    #
    # @param automation_id [String] the ID of the Automation
    # @param step_id [String] the ID of the step
    # @return [HTTP::Response] the response from the API
    def step_run_count(automation_id:, step_id:)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/steps/run-counts/#{step_id}")
    end

    # Returns the run counts of every trigger of the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @return [HTTP::Response] the response from the API
    def trigger_run_counts(automation_id)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/triggers/run-counts")
    end

    # Returns the run counts of the specified trigger
    #
    # @param automation_id [String] the ID of the Automation
    # @param trigger_id [String] the ID of the trigger
    # @return [HTTP::Response] the response from the API
    def trigger_run_count(automation_id:, trigger_id:)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/triggers/run-counts/#{trigger_id}")
    end

    # Returns the stats of every A/B test step of the specified Automation
    #
    # @param automation_id [String] the ID of the Automation
    # @return [HTTP::Response] the response from the API
    def ab_steps_stats(automation_id)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/ab-steps-stats")
    end

    # Returns the stats of the specified A/B test step
    #
    # @param automation_id [String] the ID of the Automation
    # @param step_id [String] the ID of the A/B test step
    # @return [HTTP::Response] the response from the API
    def ab_step_stats(automation_id:, step_id:)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/ab-steps-stats/#{step_id}")
    end

    # Returns the subscribers who reached the specified step
    #
    # @param automation_id [String] the ID of the Automation
    # @param step_id [String] the ID of the step
    # @param status [String] queued or completed
    # @param filter[:date_from,:date_to,:search,:id] [Hash] filters for the subscribers
    # @param limit [Integer] the maximum number of subscribers to return
    # @param page [Integer] the page number of the results to return
    # @param sort [String] the field to sort by, prefix with - for descending order
    # @return [HTTP::Response] the response from the API
    def step_subscribers(automation_id:, step_id:, status:, filter: {}, limit: nil, page: nil, sort: nil)
      activity_subscribers("#{automation_id}/activity/steps/#{step_id}/subscribers", status: status, filter: filter, limit: limit, page: page, sort: sort)
    end

    # Returns the subscribers who passed the specified trigger
    #
    # @param automation_id [String] the ID of the Automation
    # @param trigger_id [String] the ID of the trigger
    # @param status [String] queued or completed
    # @param filter[:date_from,:date_to,:search,:id] [Hash] filters for the subscribers
    # @param limit [Integer] the maximum number of subscribers to return
    # @param page [Integer] the page number of the results to return
    # @param sort [String] the field to sort by, prefix with - for descending order
    # @return [HTTP::Response] the response from the API
    def trigger_subscribers(automation_id:, trigger_id:, status:, filter: {}, limit: nil, page: nil, sort: nil)
      activity_subscribers("#{automation_id}/activity/triggers/#{trigger_id}/subscribers", status: status, filter: filter, limit: limit, page: page, sort: sort)
    end

    # Returns the email totals of the specified Automation per month
    #
    # @param automation_id [String] the ID of the Automation
    # @param start_date [String] the first day, together with end_date
    # @param end_date [String] the last day, included
    # @param shop_id [String] report on one shop only, e-commerce figures only
    # @param excel [Boolean] only used by export endpoints
    # @return [HTTP::Response] the response from the API
    def email_monthly_totals(automation_id:, start_date: nil, end_date: nil, shop_id: nil, excel: nil)
      params = QueryParams.report(start_date: start_date, end_date: end_date, shop_id: shop_id, excel: excel)
      client.http.get(QueryParams.uri("#{MAILERLITE_API_URL}/automations/#{automation_id}/monthly-totals/email", params))
    end

    private

    def activity_subscribers(path, status:, filter:, **query)
      params = { 'status' => status, **query.transform_keys(&:to_s) }.merge(QueryParams.filter(filter, %i[date_from date_to search id]))
      client.http.get(QueryParams.uri("#{MAILERLITE_API_URL}/automations/#{path}", params))
    end
  end
end
