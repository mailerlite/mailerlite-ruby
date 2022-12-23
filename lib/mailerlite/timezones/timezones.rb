# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Timezones from MailerLite API.
  class Timezones
    attr_reader :client

    # Inits the `Timezones` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of Timezones
    #
    # @return [HTTP::Response] the response from the API
    def list
      client.http.get("#{API_URL}/timezones")
    end
  end
end
