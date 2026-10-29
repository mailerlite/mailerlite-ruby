# frozen_string_literal: true

require 'json'

module MailerLite
  # The base class of the errors of the SDK.
  class Error < StandardError; end

  # An error response (4xx or 5xx) from the API.
  #
  # The SDK does not raise it. Get it with `response.api_error` and raise it if you want to.
  # It is not an `HTTP::Error`, so code that retries on network errors does not also retry an API error.
  # It keeps only plain values, so `Marshal.dump` works.
  #
  # Note: `HTTP::Response#code` is the numeric status. `ApiError#code` is the String code of the API,
  # for example `"version_conflict"`. The numeric status is in `ApiError#status`.
  class ApiError < Error
    # @return [Integer] the HTTP status code, for example 409
    attr_reader :status
    # @return [String, nil] the error code of the API, for example "version_conflict"
    attr_reader :code
    # @return [String, nil] the current etag of the email, for a 409 version conflict
    attr_reader :etag
    # @return [Hash, nil] the error messages for each field, for some 422 responses
    attr_reader :errors
    # @return [String, nil] the message of the API
    attr_reader :api_message
    # @return [String] the response body as it is
    attr_reader :body
    # @return [Hash] the response headers
    attr_reader :headers

    # Makes an error from a response. It works for the responses of all methods of the SDK.
    # A body that is not a JSON object gives nil fields.
    #
    # @param response [HTTP::Response] the response
    # @return [MailerLite::ApiError] the error
    def self.from_response(response)
      body = response.body.to_s
      data = parse(body)
      new(status: response.code, reason: response.reason, body: body, headers: response.headers.to_h,
          code: data['code'], etag: data['etag'], errors: data['errors'], api_message: data['message'])
    end

    def self.parse(body)
      data = JSON.parse(body)
      data.is_a?(Hash) ? data : {}
    rescue JSON::ParserError, EncodingError
      {}
    end
    private_class_method :parse

    # @param status [Integer] the HTTP status code
    # @param reason [String, nil] the reason phrase of the status
    # @param code [String, nil] the error code of the API
    # @param etag [String, nil] the current etag of the email
    # @param errors [Hash, nil] the error messages for each field
    # @param api_message [String, nil] the message of the API
    # @param body [String] the response body
    # @param headers [Hash] the response headers
    def initialize(status:, reason: nil, code: nil, etag: nil, errors: nil, api_message: nil, body: '', headers: {})
      @status = status
      @code = code
      @etag = etag
      @errors = errors
      @api_message = api_message
      @body = body
      @headers = headers
      super(build_message(reason))
    end

    private

    # For example "409 Conflict (version_conflict): The email was changed."
    def build_message(reason)
      text = [status, reason].compact.join(' ')
      text += " (#{code})" if code
      text += ": #{api_message}" if api_message
      text
    end
  end

  # An ID for the URL path is empty. The SDK sends no request.
  class EmptyIdError < ArgumentError; end

  # An ID for the URL path does not contain only the digits 0-9. The SDK sends no request.
  class InvalidIdError < ArgumentError; end

  # The etag of a write is empty. The SDK sends no request.
  class EmptyEtagError < ArgumentError; end

  # The idempotency key is empty, longer than 255 characters, contains a character that is not printable ASCII,
  # or starts or ends with a space. The SDK sends no request.
  class InvalidIdempotencyKeyError < ArgumentError; end
end
