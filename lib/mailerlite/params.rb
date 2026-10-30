# frozen_string_literal: true

module MailerLite
  # Checks and helpers for the request parameters of the resources.
  # The SDK checks only the IDs in the URL path and the values that its code reads. The API checks all other values.
  # Each check raises before the request, so the SDK sends no request when a value is not valid.
  module Params
    module_function

    # Use \A and \z: `$` and \Z also match before a final new line.
    # Use [0-9]: [[:digit:]] also matches digits that are not ASCII.
    ID_PATTERN = /\A[0-9]+\z/

    def path_id(value, name)
      raise EmptyIdError, "`#{name}` must not be empty." if value.nil? || value == ''

      raise TypeError, "`#{name}` type is not valid. Expected String or Integer, got #{value.class}." unless value.is_a?(String) || value.is_a?(Integer)

      id = value.to_s
      # match? raises for a String with invalid bytes, so check the encoding first.
      raise InvalidIdError, "`#{name}` must contain only the digits 0-9, got #{id.inspect}." unless id.valid_encoding? && id.ascii_only? && id.match?(ID_PATTERN)

      id
    end

    def require_hash(value, name)
      raise TypeError, "`#{name}` type is not valid. Expected Hash, got #{value.class}." unless value.is_a?(Hash)

      value
    end

    def settings(settings)
      require_hash(settings, 'settings')
      # The body has the settings and the etag at the same level. An etag key in the settings can hide the etag argument.
      raise ArgumentError, '`settings` must not contain `etag`. Use the `etag` argument.' if settings.key?(:etag) || settings.key?('etag')

      settings
    end

    # It drops nil values and keeps empty Strings.
    def query(filter: nil, **params)
      query = {}
      unless filter.nil?
        require_hash(filter, 'filter').each do |key, value|
          query["filter[#{key}]"] = value unless value.nil?
        end
      end
      params.each { |key, value| query[key.to_s] = value unless value.nil? }
      query
    end

    def idempotency_headers(key)
      return {} if key.nil?

      { 'Idempotency-Key' => key }
    end
  end
end
