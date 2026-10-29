# frozen_string_literal: true

require 'uri'

module MailerLite
  # Sends the requests of `Emails`, `BrandStyles` and `Files`.
  module Request
    module_function

    # It does not raise for a 4xx or 5xx status.
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
