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
    def list(limit: nil, page: nil)
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
    def update(segment_id:, name:)
      params = { 'name' => name }
      client.http.put("#{API_URL}/segments/#{segment_id}", json: params.compact)
    end

    # Get Subscribers assigned to the specified Segment.
    # @param Segment [Integer] The id of existing Segment belonging to the account
    # @param filter[status] [String] Must be one of the possible statuses: active, unsubscribed, unconfirmed, bounced or junk. Defaults to active.
    # @param limit [Integer] the maximum number of subscribers to return
    # @param after [Integer] The last subscriber id, available in meta.last
    # @return [HTTP::Response] the response from the API
    def get_subscribers(segment_id:, filter: {}, limit: nil, after: nil)
      params = {}
      params['filter[status]'] = filter[:status] if filter.key?(:status)
      params['limit'] = limit if limit
      params['after'] = after if after
      uri = URI("#{API_URL}/segments/#{segment_id}/subscribers")
      uri.query = URI.encode_www_form(params.compact)
      client.http.get(uri)
    end

    # Deletes the specified Segments.
    #
    # @param Segment [String] the ID of the Segments to delete
    # @return [HTTP::Response] the response from the API
    def delete(segment_id)
      client.http.delete("#{API_URL}/segments/#{segment_id}")
    end
  end
end
