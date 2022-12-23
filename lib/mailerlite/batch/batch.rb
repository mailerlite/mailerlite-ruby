# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Batch from MailerLite API.
  class Batch
    attr_reader :client

    # Inits the `Batch` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Create a Webhook
    #
    # @param name [String] the name of the Webhook to create
    # @param events [Array] the events, must one from the list of supported events
    # @param url [String] the events, can be text, number or date
    # @return [HTTP::Response] the response from the API
    def request(requests:)
      params = { requests: requests }
      client.http.post("#{API_URL}/batch", body: params.to_json)
    end
  end
end
