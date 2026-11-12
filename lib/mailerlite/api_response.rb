# frozen_string_literal: true

module MailerLite
  # Helpers that `Emails`, `BrandStyles` and `Files` add to each `HTTP::Response` that they return.
  #
  # The response is still an `HTTP::Response`. Use `response.code` for the status code,
  # `response.headers` for the headers and `response.parse` for the decoded body.
  module ApiResponse
    # Returns true if the API returned the stored response of an earlier request with the same idempotency key.
    #
    # @return [Boolean] true if the `Idempotent-Replayed` header is "true"
    def idempotent_replay?
      # A proxy can change the case of the value, or send the header two times.
      headers.get('Idempotent-Replayed').any? { |value| value.strip.casecmp?('true') }
    end

    # Returns the error of the response.
    #
    # @return [MailerLite::ApiError, nil] nil for a 2xx status, otherwise an error that you can raise
    def api_error
      status.success? ? nil : ApiError.from_response(self)
    end
  end
end
