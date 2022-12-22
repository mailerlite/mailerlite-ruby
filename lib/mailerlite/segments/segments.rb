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
    # @return [HTTP::Response] the response from the API
    def get(limit: nil, page: nil)
      params = {}
      params['limit'] = limit if limit
      params['page'] = page if page

      client.http.get("#{API_URL}/segments", json: params.compact)
    end

    # Update the specified Segment
    #
    # @param Segment [String] the ID of the Segments to update
    # @param name [String] the name to update
    # @return [HTTP::Response] the response from the API
    def update(segment:, name:)
      params = { 'name' => name }
      client.http.put("#{API_URL}/segments/#{segment}", json: params.compact)
    end

    # Get Subscribers assigned to the specified Segment.
    # @param Segment [Integer] The id of existing Segment belonging to the account
    # @param filter_status [String] Must be one of the possible statuses: active, unsubscribed, unconfirmed, bounced or junk. Defaults to active.
    # @param limit [Integer] the maximum number of subscribers to return
    # @param after [Integer] The last subscriber id, available in meta.last
    # @return [HTTP::Response] the response from the API
    def get_subscribers(segment:, filter_status: nil, limit: nil, after: nil)
      params = {}
      params['filter[status]'] = filter_status if filter_status
      params['limit'] = limit if limit
      params['after'] = after if after
      client.http.get("#{API_URL}/segments/#{segment}/subscribers", json: params.compact)
    end

    # Deletes the specified Segments.
    #
    # @param Segment [String] the ID of the Segments to delete
    # @return [HTTP::Response] the response from the API
    def delete(segment)
      client.http.delete("#{API_URL}/segments/#{segment}")
    end
  end
end
