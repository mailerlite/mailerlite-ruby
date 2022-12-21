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
    def list(filter_name:nil, type:, limit: nil, sort: nil, page: nil)
      params = {}
      params ['filter[name]'] = filter_name if filter_name 
      params['limit'] = limit if limit
      params['sort'] = sort if sort
      params['page'] = page if page

      client.http.get("#{API_URL}/groups/#{type}", json: params.compact)
    end

    # Returns the details of the specified Groups
    #
    # @param Groups [String] the ID of the Groups to fetch
    # @return [HTTP::Response] the response from the API
    def fetch(Groups)
      client.http.get("#{API_URL}/groups/#{Groups}")
    end

    # Update the specified Groups
    #
    # @param Groups [String] the ID of the Groups to fetch
    # @param name [String] the name to update
    # @return [HTTP::Response] the response from the API
    def update(Groups:,name:)
      params = { 'name' => name }
      client.http.put("#{API_URL}/groups/#{Groups}", json: params.compact)
    end

    # Returns the total number of Groups in the MailerLite account.
    #
    # @return [HTTP::Response] the response from the API
    def fetch_count
      client.http.get("#{API_URL}/groups/?limit=0")
    end

    # Deletes the specified Groups.
    #
    # @param Groups [String] the ID of the Groups to delete
    # @return [HTTP::Response] the response from the API
    def delete(Groups)
      client.http.delete("#{API_URL}/groups/#{Groups}")
    end
  end
end
