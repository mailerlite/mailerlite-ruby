# frozen_string_literal: true

module MailerLite
  # This is a class for the brand styles from MailerLite API.
  class BrandStyles
    attr_reader :client

    # Inits the `BrandStyles` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns the palettes of the account: `brand` (the brand styles of the account, or nil if it has none),
    # `default` and the `presets`. Match a palette on its `identifier`, not on its `name`.
    # To apply a preset to an email, send its `identifier` in `brand.style` with `Emails#update_settings`.
    #
    # @return [HTTP::Response] the response from the API, with the `MailerLite::ApiResponse` methods
    def get
      Request.call(client, :get, '/brand-styles')
    end
  end
end
