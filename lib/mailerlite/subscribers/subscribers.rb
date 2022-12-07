# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the subscribers from MailerLite API.
  class Subscribers
    attr_reader :client

    # Inits the `Subscribers` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of subscribers that match the specified filter criteria.
    #
    # @param filter_status [String] the status of the subscribers to include in the results
    # @param limit [Integer] the maximum number of subscribers to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get(filter_status:, limit: nil, page: nil)
      params = { 'filter[status]' => filter_status }

      params['limit'] = limit if limit
      params['page'] = page if page

      client.http.get(URI::HTTPS.build(
                        host: API_BASE_HOST,
                        path: '/api/subscribers',
                        query: URI.encode_www_form(params.compact)
                      ))
    end

    # Creates a new subscriber with the specified details.
    #
    # @param email [String] the email address of the new subscriber
    # @param fields [Hash] a hash of custom fields and their values for the subscriber
    # @param groups [Array] an array of group IDs to add the subscriber to
    # @param status [String] the status of the new subscriber
    # @param subscribed_at [DateTime] the date and time when the subscriber was added
    # @param ip_address [String] the IP address of the subscriber
    # @param opted_in_at [DateTime] the date and time when the subscriber confirmed their subscription
    # @param optin_ip [String] the IP address of the subscriber when they confirmed their subscription
    # @param unsubscribed_at [DateTime] the date and time when the subscriber was unsubscribed
    # @return [HTTP::Response] the response from the API
    def create(email:, fields: nil, groups: nil, status: nil, subscribed_at: nil, ip_address: nil, opted_in_at: nil, optin_ip: nil, unsubscribed_at: nil)
      params = { 'email' => email }

      params['fields'] = fields if fields
      params['groups'] = groups if groups
      params['status'] = status if status
      params['subscribed_at'] = subscribed_at if subscribed_at
      params['ip_address'] = ip_address if ip_address
      params['opted_in_at'] = opted_in_at if opted_in_at
      params['optin_ip'] = optin_ip if optin_ip
      params['unsubscribed_at'] = unsubscribed_at if unsubscribed_at

      client.http.post("#{API_URL}/subscribers", json: params.compact)
    end

    # Returns the details of the specified subscribers
    #
    # @param subscriber [String] the ID of the subscriber to fetch
    # @return [HTTP::Response] the response from the API
    def fetch(subscriber)
      client.http.get("#{API_URL}/subscribers/#{subscriber}")
    end

    # Returns the total number of subscribers in the MailerLite account.
    #
    # @return [HTTP::Response] the response from the API
    def fetch_count
      client.http.get("#{API_URL}/subscribers/?limit=0")
    end

    # Deletes the specified subscriber.
    #
    # @param subscriber [String] the ID of the subscriber to delete
    # @return [HTTP::Response] the response from the API
    def delete(subscriber)
      client.http.delete("#{API_URL}/subscribers/#{subscriber}")
    end
  end
end
