# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Webhooks from MailerLite API.
  class Webhooks
    attr_reader :client

    # Inits the `Webhooks` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of Webhooks
    #
    # @return [HTTP::Response] the response from the API
    def list
      client.http.get("#{MAILERLITE_API_URL}/webhooks")
    end

    # Returns the details of the specified webhooks
    #
    # @param webhook_id [String] the ID of the webhooks to fetch
    # @return [HTTP::Response] the response from the API
    def get(webhook_id)
      client.http.get("#{MAILERLITE_API_URL}/webhooks/#{webhook_id}")
    end

    # Create a Webhook
    #
    # @param name [String] the name of the Webhook to create
    # @param events [Array] the events, must one from the list of supported events
    # @param url [String] the events, can be text, number or date
    # @return [HTTP::Response] the response from the API
    def create(events:, url:, name: nil)
      params = { 'events' => events, 'url' => url }
      params['name'] = name if name
      client.http.post("#{MAILERLITE_API_URL}/webhooks", json: params.compact)
    end

    # Update the specified Webhook
    #
    # @param webhook_id [String] the ID of the Webhook to update
    # @param name [String] the name to update
    # @param events [Array] the events to update
    # @param url [String] the url to update
    # @param enabled [Boolean] the enabled to update
    # @return [HTTP::Response] the response from the API
    def update(webhook_id:, events: nil, name: nil, url: nil, enabled: nil)
      params = {}
      params['events'] = events if events
      params['name'] = name if name
      params['url'] = url if url
      params['enabled'] = enabled if enabled
      client.http.put("#{MAILERLITE_API_URL}/webhooks/#{webhook_id}", json: params.compact)
    end

    # Deletes the specified Webhook.
    #
    # @param webhook_id [String] the ID of the Webhook to delete
    # @return [HTTP::Response] the response from the API
    def delete(webhook_id)
      client.http.delete("#{MAILERLITE_API_URL}/webhooks/#{webhook_id}")
    end
  end
end
