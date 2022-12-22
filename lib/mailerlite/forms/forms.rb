# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Forms from MailerLite API.
  class Forms
    attr_reader :client

    # Inits the `Forms` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of Forms that match the specified filter criteria.
    #
    # @param filter_name [String] the name of the Forms to include in the results
    # @param limit [Integer] the maximum number of Forms to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def list(type:, filter_name: nil, limit: nil, sort: nil, page: nil)
      params = {}
      params['filter[name]'] = filter_name if filter_name
      params['limit'] = limit if limit
      params['sort'] = sort if sort
      params['page'] = page if page

      client.http.get("#{API_URL}/forms/#{type}", json: params.compact)
    end

    # Returns the details of the specified Forms
    #
    # @param forms [String] the ID of the forms to fetch
    # @return [HTTP::Response] the response from the API
    def fetch(form)
      client.http.get("#{API_URL}/forms/#{form}")
    end

    # Returns the subscribers who signed up to a specific form
    #
    # @param form [String] the ID of the forms to fetch
    # @return [HTTP::Response] the response from the API
    def fetch_subscribers(form)
      client.http.get("#{API_URL}/forms/#{form}/subscribers")
    end

    # Update the specified Forms
    #
    # @param forms [String] the ID of the forms to fetch
    # @param name [String] the name to update
    # @return [HTTP::Response] the response from the API
    def update(form:, name:)
      params = { 'name' => name }
      client.http.put("#{API_URL}/forms/#{form}", json: params.compact)
    end

    # Returns the total number of Forms in the MailerLite account.
    #
    # @return [HTTP::Response] the response from the API
    def fetch_count
      client.http.get("#{API_URL}/forms/?limit=0")
    end

    # Deletes the specified forms.
    #
    # @param forms [String] the ID of the forms to delete
    # @return [HTTP::Response] the response from the API
    def delete(form)
      client.http.delete("#{API_URL}/forms/#{form}")
    end
  end
end
