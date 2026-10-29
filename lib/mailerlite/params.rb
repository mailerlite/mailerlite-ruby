# frozen_string_literal: true

module MailerLite
  # Checks and helpers for the request parameters of the resources.
  # Each check raises before the request, so the SDK sends no request when a value is not valid.
  module Params
    module_function

    # Use \A and \z: `$` and \Z also match before a final new line.
    # Use [0-9]: [[:digit:]] also matches digits that are not ASCII.
    ID_PATTERN = /\A[0-9]+\z/
    # The API accepts 1 to 255 printable ASCII characters.
    IDEMPOTENCY_KEY_PATTERN = /\A[\x20-\x7E]{1,255}\z/

    def path_id(value, name)
      raise EmptyIdError, "`#{name}` must not be empty." if value.nil? || value == ''

      raise TypeError, "`#{name}` type is not valid. Expected String or Integer, got #{value.class}." unless value.is_a?(String) || value.is_a?(Integer)

      id = value.to_s
      # match? raises for a String with invalid bytes, so check the encoding first.
      raise InvalidIdError, "`#{name}` must contain only the digits 0-9, got #{id.inspect}." unless id.valid_encoding? && id.ascii_only? && id.match?(ID_PATTERN)

      id
    end

    def etag(value)
      raise EmptyEtagError, '`etag` must not be empty.' if value.nil? || value == ''
      raise TypeError, "`etag` type is not valid. Expected String, got #{value.class}." unless value.is_a?(String)

      value
    end

    def require_hash(value, name)
      raise TypeError, "`#{name}` type is not valid. Expected Hash, got #{value.class}." unless value.is_a?(Hash)

      value
    end

    def require_string(value, name)
      raise TypeError, "`#{name}` type is not valid. Expected String, got #{value.class}." unless value.is_a?(String)

      value
    end

    # Positions of a block that use `block_id`.
    SIBLING_POSITIONS = %w[before after].freeze

    # For positions other than `before` and `after`, the API discards `block_id` without a check. Drop it.
    def placement(placement)
      require_hash(placement, 'placement')
      result = {}
      placement.each do |key, value|
        name = key.to_s
        # {block_id: 1, 'block_id' => 2} has two keys, but JSON can send only one of them.
        raise ArgumentError, "`placement` contains the key `#{name}` two times." if result.key?(name)

        result[name] = value
      end
      # JSON sends a Symbol position as a String, so compare the String.
      if SIBLING_POSITIONS.include?(result['position'].to_s)
        result['block_id'] = path_id(result['block_id'], 'block_id')
      else
        result.delete('block_id')
      end
      result
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
      raise TypeError, "`idempotency_key` type is not valid. Expected String, got #{key.class}." unless key.is_a?(String)

      # HTTP removes a space at the start and at the end of a header value. Then the API gets a different key.
      unless key.valid_encoding? && key.ascii_only? && key.match?(IDEMPOTENCY_KEY_PATTERN) && key == key.strip
        raise InvalidIdempotencyKeyError,
              '`idempotency_key` must be 1 to 255 printable ASCII characters, without a space at the start or the end.'
      end

      { 'Idempotency-Key' => key }
    end
  end
end
