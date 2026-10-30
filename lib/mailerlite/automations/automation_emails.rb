# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Automation emails from MailerLite API.
  class AutomationEmails
    attr_reader :client

    # Inits the `AutomationEmails` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns the HTML content of the specified email
    #
    # @param automation_id [String] the ID of the Automation
    # @param email_id [String] the ID of the email
    # @return [HTTP::Response] the response from the API
    def content(automation_id:, email_id:)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/emails/#{email_id}/content")
    end

    # Updates the HTML content of the specified email
    #
    # @param automation_id [String] the ID of the Automation
    # @param email_id [String] the ID of the email
    # @param html [String] the new HTML content
    # @return [HTTP::Response] the response from the API
    def update_content(automation_id:, email_id:, html:)
      client.http.put("#{MAILERLITE_API_URL}/automations/#{automation_id}/emails/#{email_id}/content", json: { 'html' => html })
    end

    # Returns the report stats of the specified email
    #
    # @param automation_id [String] the ID of the Automation
    # @param email_id [String] the ID of the email
    # @param start_date [String] the first day, together with end_date
    # @param end_date [String] the last day, included
    # @param shop_id [String] report on one shop only, e-commerce figures only
    # @param excel [Boolean] only used by export endpoints
    # @return [HTTP::Response] the response from the API
    def report_stats(automation_id:, email_id:, start_date: nil, end_date: nil, shop_id: nil, excel: nil)
      params = QueryParams.report(start_date: start_date, end_date: end_date, shop_id: shop_id, excel: excel)
      client.http.get(QueryParams.uri("#{MAILERLITE_API_URL}/automations/#{automation_id}/emails/#{email_id}/report-stats", params))
    end

    # Returns the reasons subscribers gave for unsubscribing from the specified email
    #
    # @param automation_id [String] the ID of the Automation
    # @param email_id [String] the ID of the email
    # @return [HTTP::Response] the response from the API
    def unsubscribe_reasons(automation_id:, email_id:)
      client.http.get("#{MAILERLITE_API_URL}/automations/#{automation_id}/emails/#{email_id}/unsubscribe-reasons")
    end
  end
end
