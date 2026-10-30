# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Segments from MailerLite API.
  class Segments
    attr_reader :client

    # Inits the `Segments` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of Segments that match the specified filter criteria.
    #
    # @param limit [Integer] the maximum number of Segments to return
    # @param page [Integer] the page number of the results to return
    # @param sort [String] the field to sort by, prefix with - for descending order
    # @return [HTTP::Response] the response from the API
    def list(limit: nil, page: nil, sort: nil)
      client.http.get(QueryParams.uri("#{MAILERLITE_API_URL}/segments", { 'limit' => limit, 'page' => page, 'sort' => sort }))
    end

    # Update the specified Segment
    #
    # @param segment_id [String] the ID of the Segments to update
    # @param name [String] the name to update
    # @param filter [Array] the segment rules
    # @return [HTTP::Response] the response from the API
    def update(segment_id:, name:, filter: nil)
      params = { 'name' => name, 'filter' => filter }
      client.http.put("#{MAILERLITE_API_URL}/segments/#{segment_id}", json: params.compact)
    end

    # Get Subscribers assigned to the specified Segment.
    # @param segment_id [Integer] The id of existing Segment belonging to the account
    # @param filter[status] [String] Must be one of the possible statuses: active, unsubscribed, unconfirmed, bounced or junk. Defaults to active.
    # @param limit [Integer] the maximum number of subscribers to return
    # @param cursor [String] the cursor for the page of results to return, available in meta.next_cursor
    # @param after [Integer] deprecated, the API ignores it, use cursor
    # @return [HTTP::Response] the response from the API
    def get_subscribers(segment_id:, filter: {}, limit: nil, after: nil, cursor: nil)
      params = {}
      params['filter[status]'] = filter[:status] if filter.key?(:status)
      params['limit'] = limit if limit
      params['cursor'] = cursor if cursor
      params['after'] = after if after
      uri = URI("#{MAILERLITE_API_URL}/segments/#{segment_id}/subscribers")
      uri.query = URI.encode_www_form(params.compact)
      client.http.get(uri)
    end

    # Deletes the specified Segments.
    #
    # @param segment_id [String] the ID of the Segments to delete
    # @return [HTTP::Response] the response from the API
    def delete(segment_id)
      client.http.delete("#{MAILERLITE_API_URL}/segments/#{segment_id}")
    end
  end
end
