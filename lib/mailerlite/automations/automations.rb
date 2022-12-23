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
    # @param filter[status] [Boolean] Must be one of the following: true (for active) and false (for inactive). Defaults to return all automations
    # @param filter[name] [String] must be a text
    # @param filter[group] [String] Must be a valid group id. Returns all automations that use the group in their trigger configuration
    # @param limit [Integer] the maximum number of Automations to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get(limit: nil, page: nil, filter: {})
      params = {}
      params['filter[status]'] = filter['status'] if filter.key?('status')
      params['filter[name]'] = filter['name'] if filter.key?('name')
      params['filter[group]'] = filter['group'] if filter.key?('group')
      params['limit'] = limit if limit
      params['page'] = page if page

      client.http.get("#{API_URL}/automations", json: params.compact)
    end

    # fetch the specified Automation
    #
    # @param automation [String] the ID of the Automation to fetch
    # @return [HTTP::Response] the response from the API
    def fetch(automation_id)
      client.http.get("#{API_URL}/automations/#{automation_id}")
    end

    # get_subscriber_activity the subscriber activity for specified Automation
    #
    # @param automation_id [Integer] the ID of the Automation to get_subscriber_activity
    # @param filter[status] [String] Must be one of the following: completed, active, canceled, failed
    # @param filter[date_from] [DateTime] Must be in the format Y-m-d
    # @param filter[date_to] [DateTime] Must be in the format Y-m-d
    # @param filter[scheduled_from] [DateTime] Must be in the format Y-m-d
    # @param filter[scheduled_to] [DateTime] Must be in the format Y-m-d
    # @param filter[keyword] [String] Must be a subscriber email
    # @param limit [Integer] the maximum number of Automations to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get_subscriber_activity(automation_id:, filter: {}, page: nil, limit: nil)
      params = { 'filter[status]' => filter['status'] }
      params['filter[date_from]'] = filter['date_from'] if filter.key?('date_from')
      params['filter[date_to]'] = filter['date_to'] if filter.key?('date_to')
      params['filter[scheduled_from]'] = filter['scheduled_from'] if filter.key?('scheduled_from')
      params['filter[scheduled_to]'] = filter['scheduled_to'] if filter.key?('scheduled_to')
      params['filter[keyword]'] = filter['keyword'] if filter.key?('keyword')
      params['page'] = page if page
      params['limit'] = limit if limit
      client.http.get("#{API_URL}/automations/#{automation_id}/activity", json: params.compact)
    end
  end
end
