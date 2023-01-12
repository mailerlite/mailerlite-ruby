# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Fields from MailerLite API.
  class Fields
    attr_reader :client

    # Inits the `Fields` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of Fields that match the specified filter criteria.
    #
    # @param filter [:keyword, :type] Returns partial matches for fields
    # @param limit [Integer] the maximum number of Fields to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get(limit: nil, page: nil, filter: {}, sort: nil)
      params = {}
      params['filter[keyword]'] = filter[:keyword] if filter.key?(:keyword)
      params['filter[type]'] = filter[:type] if filter.key?(:type)
      params['sort'] = sort if sort
      params['limit'] = limit if limit
      params['page'] = page if page
      uri = URI("#{API_URL}/fields")
      uri.query = URI.encode_www_form(params.compact)
      client.http.get(uri)
    end

    # Update the specified Field
    #
    # @param name [String] the name of the field to create
    # @param type [String] the type, can be text, number or date
    # @return [HTTP::Response] the response from the API
    def create(type:, name:)
      params = { 'name' => name, 'type' => type }
      client.http.post("#{API_URL}/fields", json: params.compact)
    end

    # Update the specified Field
    #
    # @param field_id [Integer] the field_id to update
    # @param name [String] the name to update
    # @return [HTTP::Response] the response from the API
    def update(field_id:, name:)
      params = { 'name' => name }
      client.http.put("#{API_URL}/fields/#{field_id}", json: params.compact)
    end

    # Deletes the specified Field.
    #
    # @param field_id [String] the ID of the Field to delete
    # @return [HTTP::Response] the response from the API
    def delete(field_id)
      client.http.delete("#{API_URL}/fields/#{field_id}")
    end
  end
end
