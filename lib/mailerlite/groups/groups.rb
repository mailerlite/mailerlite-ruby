# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Groups from MailerLite API.
  class Groups
    attr_reader :client

    # Inits the `Groups` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of Groups that match the specified filter criteria.
    #
    # @param filter_name [String] the name of the Groups to include in the results
    # @param limit [Integer] the maximum number of Groups to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get(filter_name: nil, limit: nil, sort: nil, page: nil)
      params = {}
      params['filter[name]'] = filter_name if filter_name
      params['limit'] = limit if limit
      params['sort'] = sort if sort
      params['page'] = page if page

      client.http.get("#{API_URL}/groups", json: params.compact)
    end

    # create a Group
    #
    # @param group [String] the ID of the Groups to create
    # @param name [String] the name to update
    # @return [HTTP::Response] the response from the API
    def create(name:)
      params = { 'name' => name }
      client.http.post("#{API_URL}/groups", json: params.compact)
    end

    # Update the specified Group
    #
    # @param group [String] the ID of the Groups to update
    # @param name [String] the name to update
    # @return [HTTP::Response] the response from the API
    def update(group:, name:)
      params = { 'name' => name }
      client.http.put("#{API_URL}/groups/#{group}", json: params.compact)
    end

    # Get Subscribers assigned to the specified group.
    # @param group [Integer] The id of existing group belonging to the account
    # @param filter_status [String] Must be one of the possible statuses: active, unsubscribed, unconfirmed, bounced or junk. Defaults to active.
    # @param limit [Integer] the maximum number of subscribers to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get_subscribers(group:, filter_status: nil, limit: nil, page: nil, sort: nil)
      params = {}
      params['filter[status]'] = filter_status if filter_status
      params['limit'] = limit if limit
      params['sort'] = sort if sort
      params['page'] = page if page
      client.http.get("#{API_URL}/groups/#{group}/subscribers", json: params.compact)
    end

    # Assign Subscriber to the specified group.
    # @param group [Integer] The id of existing group belonging to the account
    # @param subscriber [Integer] The id of existing subscriber belonging to the account
    # @return [HTTP::Response] the response from the API
    def assign_subscriber(group:, subscriber:)
      client.http.post("#{API_URL}/subscribers/#{subscriber}/groups/#{group}")
    end

    # Unassign Subscriber to the specified group.
    # @param group [Integer] The id of existing group belonging to the account
    # @param subscriber [Integer] The id of existing subscriber belonging to the account
    # @return [HTTP::Response] the response from the API
    def unassign_subscriber(group:, subscriber:)
      client.http.delete("#{API_URL}/subscribers/#{subscriber}/groups/#{group}")
    end

    # Deletes the specified Groups.
    #
    # @param group [String] the ID of the Groups to delete
    # @return [HTTP::Response] the response from the API
    def delete(group)
      client.http.delete("#{API_URL}/groups/#{group}")
    end
  end
end
