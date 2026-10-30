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
    # @param filter[:name] the name of the Groups to include in the results
    # @param limit [Integer] the maximum number of Groups to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get(filter: {}, limit: nil, sort: nil, page: nil)
      params = {}
      params['filter[name]'] = filter[:name] if filter.key?(:name)
      params['limit'] = limit if limit
      params['sort'] = sort if sort
      params['page'] = page if page
      uri = URI("#{MAILERLITE_API_URL}/groups")
      uri.query = URI.encode_www_form(params.compact)
      client.http.get(uri)
    end

    # create a Group
    #
    # @param name [String] the name to update
    # @return [HTTP::Response] the response from the API
    def create(name:)
      params = { 'name' => name }
      client.http.post("#{MAILERLITE_API_URL}/groups", json: params.compact)
    end

    # Update the specified Group
    #
    # @param group_id [String] the ID of the Groups to update
    # @param name [String] the name to update
    # @return [HTTP::Response] the response from the API
    def update(group_id:, name:)
      params = { 'name' => name }
      client.http.put("#{MAILERLITE_API_URL}/groups/#{group_id}", json: params.compact)
    end

    # Get Subscribers assigned to the specified group.
    # @param group_id [Integer] The id of existing group belonging to the account
    # @param filter[:status] [String] Must be one of the possible statuses: active, unsubscribed, unconfirmed, bounced or junk. Defaults to active.
    # @param limit [Integer] the maximum number of subscribers to return
    # @param cursor [String] the cursor for the page of results to return
    # @param include [String] the relations to embed, only groups is supported
    # @return [HTTP::Response] the response from the API
    def get_subscribers(group_id:, filter: {}, limit: nil, cursor: nil, sort: nil, include: nil)
      params = QueryParams.filter(filter, %i[status]).merge('limit' => limit, 'sort' => sort, 'cursor' => cursor, 'include' => include)
      client.http.get(QueryParams.uri("#{MAILERLITE_API_URL}/groups/#{group_id}/subscribers", params))
    end

    # Imports subscribers into the specified group.
    # @param group_id [Integer] The id of existing group belonging to the account
    # @param subscribers [Array] the subscribers to import, each a hash with email, and optional name and fields
    # @param resubscribe [Boolean] reactivate unsubscribed subscribers, bounced and junk subscribers are not reactivated
    # @param trigger_automations [Boolean] start the automations the import qualifies for
    # @return [HTTP::Response] the response from the API
    def import_subscribers(group_id:, subscribers:, resubscribe: nil, trigger_automations: nil)
      params = { 'subscribers' => subscribers, 'resubscribe' => resubscribe, 'trigger_automations' => trigger_automations }
      client.http.post("#{MAILERLITE_API_URL}/groups/#{group_id}/import-subscribers", json: params.compact)
    end

    # Assign Subscriber to the specified group.
    # @param group_id [Integer] The id of existing group belonging to the account
    # @param subscriber [Integer] The id of existing subscriber belonging to the account
    # @return [HTTP::Response] the response from the API
    def assign_subscriber(group_id:, subscriber:)
      client.http.post("#{MAILERLITE_API_URL}/subscribers/#{subscriber}/groups/#{group_id}")
    end

    # Unassign Subscriber to the specified group.
    # @param group_id [Integer] The id of existing group belonging to the account
    # @param subscriber [Integer] The id of existing subscriber belonging to the account
    # @return [HTTP::Response] the response from the API
    def unassign_subscriber(group_id:, subscriber:)
      client.http.delete("#{MAILERLITE_API_URL}/subscribers/#{subscriber}/groups/#{group_id}")
    end

    # Deletes the specified Groups.
    #
    # @param group_id [String] the ID of the Groups to delete
    # @return [HTTP::Response] the response from the API
    def delete(group_id)
      client.http.delete("#{MAILERLITE_API_URL}/groups/#{group_id}")
    end
  end
end
