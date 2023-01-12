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
    # @param filter[:status,:name,:group] [Array] filters for automation
    # @param limit [Integer] the maximum number of Automations to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get(limit: nil, page: nil, filter: {})
      params = {}
      params['filter[status]'] = filter[:status] if filter.key?(:status)
      params['filter[name]'] = filter[:name] if filter.key?(:name)
      params['filter[group]'] = filter[:group] if filter.key?(:group)
      params['limit'] = limit if limit
      params['page'] = page if page
      uri = URI("#{API_URL}/automations")
      uri.query = URI.encode_www_form(params.compact)
      client.http.get(uri)
    end

    # fetch the specified Automation
    #
    # @param automation_id [String] the ID of the Automation to fetch
    # @return [HTTP::Response] the response from the API
    def fetch(automation_id)
      client.http.get("#{API_URL}/automations/#{automation_id}")
    end

    # get_subscriber_activity the subscriber activity for specified Automation
    #
    # @param automation_id [Integer] the ID of the Automation to get_subscriber_activity
    # @param filter[:status,:date_from,:date_to,:scheduled_from,:scheduled_to,:keyword] [Array] Must be one of the following: completed, active, canceled, failed
    # @param limit [Integer] the maximum number of Automations to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get_subscriber_activity(automation_id:, filter: {}, page: nil, limit: nil)
      params = { 'filter[status]' => filter[:status] }
      params['filter[date_from]'] = filter[:date_from] if filter.key?(:date_from)
      params['filter[date_to]'] = filter[:date_to] if filter.key?(:date_to)
      params['filter[scheduled_from]'] = filter[:scheduled_from] if filter.key?(:scheduled_from)
      params['filter[scheduled_to]'] = filter[:scheduled_to] if filter.key?(:scheduled_to)
      params['filter[keyword]'] = filter[:keyword] if filter.key?(:keyword)
      params['page'] = page if page
      params['limit'] = limit if limit
      uri = URI("#{API_URL}/automations/#{automation_id}/activity")
      uri.query = URI.encode_www_form(params.compact)
      client.http.get(uri)
    end
  end
end
