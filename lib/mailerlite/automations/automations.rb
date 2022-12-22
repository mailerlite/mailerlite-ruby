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
    # @param filter_status [Boolean] Must be one of the following: true (for active) and false (for inactive). Defaults to return all automations
    # @param filter_name [String] must be a text
    # @param filter_group [String] Must be a valid group id. Returns all automations that use the group in their trigger configuration
    # @param limit [Integer] the maximum number of Automations to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get(limit: nil, page: nil, filter_status: nil, filter_name: nil, filter_group: nil)
      params = {}
      params["filter[status]"] = filter_status if filter_status
      params["filter[name]"] = filter_name if filter_name
      params["filter[group]"] = filter_group if filter_group
      params["limit"] = limit if limit
      params["page"] = page if page

      client.http.get("#{API_URL}/automations", json: params.compact)
    end

    # fetch the specified Automation
    #
    # @param automation [String] the ID of the Automation to fetch
    # @return [HTTP::Response] the response from the API
    def fetch(automation)
      client.http.get("#{API_URL}/automations/#{automation}")
    end

    # get_subscriber_activity the subscriber activity for specified Automation
    #
    # @param automation [Integer] the ID of the Automation to get_subscriber_activity
    # @param filter_status [String] Must be one of the following: completed, active, canceled, failed
    # @param filter_date_from [DateTime] Must be in the format Y-m-d
    # @param filter_date_to [DateTime] Must be in the format Y-m-d
    # @param filter_scheduled_from [DateTime] Must be in the format Y-m-d
    # @param filter_scheduled_to [DateTime] Must be in the format Y-m-d
    # @param filter_keyword [String] Must be a subscriber email
    # @param limit [Integer] the maximum number of Automations to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get_subscriber_activity(automation:, filter_status:, filter_date_from: nil, filter_date_to: nil, filter_scheduled_from: nil, filter_scheduled_to: nil, filter_keyword: nil, page: nil, limit: nil)
      params = { "filter[status]" => filter_status }
      params["filter[date_from]"] = filter_date_from if filter_date_from
      params["filter[date_to]"] = filter_date_to if filter_date_to
      params["filter[scheduled_from]"] = filter_scheduled_from if filter_scheduled_from
      params["filter[scheduled_to]"] = filter_scheduled_to if filter_scheduled_to
      params["filter[keyword]"] = filter_keyword if filter_keyword
      params["page"] = page if page
      params["limit"] = limit if limit
      client.http.get("#{API_URL}/automations/#{automation}/activity", json: params.compact)
    end
  end
end
