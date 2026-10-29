# frozen_string_literal: true

require 'uri'

module MailerLite
  # Sends the requests of the new resources.
  module Request
    module_function

    # Sends a request and returns the response with the `MailerLite::ApiResponse` methods.
    # It does not raise for a 4xx or 5xx status.
    #
    # @param client [MailerLite::Client] the client
    # @param method [Symbol] the HTTP method, for example :patch
    # @param path [String] the path after the base URL, for example "/emails/123"
    # @param json [Hash, nil] the request body. If it is nil, the SDK sends no body.
    # @param query [Hash, nil] the query parameters
    # @param idempotency_key [String, nil] the value of the `Idempotency-Key` header
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::InvalidIdempotencyKeyError] if the idempotency key is not valid
    def call(client, method, path, json: nil, query: nil, idempotency_key: nil)
      headers = Params.idempotency_headers(idempotency_key)
      # Read the constant here, not when the file loads.
      uri = URI("#{MAILERLITE_API_URL}#{path}")
      uri.query = URI.encode_www_form(query) if query && !query.empty?
      options = {}
      # `body: nil.to_json` sends "null", so add `json:` only when there is a body.
      options[:json] = json unless json.nil?
      http = client.http
      http = http.headers(headers) unless headers.empty?
      http.request(method, uri, options).extend(ApiResponse)
    end
  end
end
