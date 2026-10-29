# frozen_string_literal: true

module MailerLite
  # The base class of the errors of the SDK.
  class Error < StandardError; end

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
