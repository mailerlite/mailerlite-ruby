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

    # Returns the ID as a String for the URL path.
    #
    # @param value [String, Integer] the ID
    # @param name [String] the name of the argument, for the error message
    # @return [String] the ID
    # @raise [TypeError] if the ID is not a String or an Integer
    # @raise [MailerLite::EmptyIdError] if the ID is nil or empty
    # @raise [MailerLite::InvalidIdError] if the ID does not contain only the digits 0-9
    def path_id(value, name)
      raise EmptyIdError, "`#{name}` must not be empty." if value.nil? || value == ''

      raise TypeError, "`#{name}` type is not valid. Expected String or Integer, got #{value.class}." unless value.is_a?(String) || value.is_a?(Integer)

      id = value.to_s
      # match? raises for a String with invalid bytes, so check the encoding first.
      raise InvalidIdError, "`#{name}` must contain only the digits 0-9, got #{id.inspect}." unless id.valid_encoding? && id.ascii_only? && id.match?(ID_PATTERN)

      id
    end

    # Returns the etag for the body of a write.
    #
    # @param value [String] the etag from the last response for the email
    # @return [String] the etag
    # @raise [MailerLite::EmptyEtagError] if the etag is nil or empty
    # @raise [TypeError] if the etag is not a String
    def etag(value)
      raise EmptyEtagError, '`etag` must not be empty.' if value.nil? || value == ''
      raise TypeError, "`etag` type is not valid. Expected String, got #{value.class}." unless value.is_a?(String)

      value
    end

    # Returns the value if it is a Hash.
    #
    # @param value [Hash] the value to check
    # @param name [String] the name of the argument, for the error message
    # @return [Hash] the value
    # @raise [TypeError] if the value is not a Hash
    def require_hash(value, name)
      raise TypeError, "`#{name}` type is not valid. Expected Hash, got #{value.class}." unless value.is_a?(Hash)

      value
    end

    # Returns the String value if it is a String.
    #
    # @param value [String] the value to check
    # @param name [String] the name of the argument, for the error message
    # @return [String] the value
    # @raise [TypeError] if the value is not a String
    def require_string(value, name)
      raise TypeError, "`#{name}` type is not valid. Expected String, got #{value.class}." unless value.is_a?(String)

      value
    end

    # Positions of a block that use `block_id`.
    SIBLING_POSITIONS = %w[before after].freeze

    # Returns a copy of the placement of a block with String keys.
    # For `before` and `after`, it checks `block_id`. For the other positions, the API discards `block_id`
    # without a check, so the copy does not contain it.
    #
    # @param placement [Hash] `position` and, for `before` and `after`, `block_id`
    # @return [Hash] a new Hash. The Hash of the caller does not change.
    # @raise [TypeError] if the placement is not a Hash, or `block_id` is not a String or an Integer
    # @raise [ArgumentError] if a key is in the Hash as a Symbol and as a String
    # @raise [MailerLite::EmptyIdError] if the position is `before` or `after` and `block_id` is nil or empty
    # @raise [MailerLite::InvalidIdError] if the position is `before` or `after` and `block_id` does not contain
    #   only the digits 0-9
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

    # Returns the settings of an email, if they do not contain an etag.
    #
    # @param settings [Hash] the settings to send
    # @return [Hash] the settings
    # @raise [TypeError] if the settings are not a Hash
    # @raise [ArgumentError] if the settings contain an `etag` key
    def settings(settings)
      require_hash(settings, 'settings')
      # The body has the settings and the etag at the same level. An etag key in the settings can hide the etag argument.
      raise ArgumentError, '`settings` must not contain `etag`. Use the `etag` argument.' if settings.key?(:etag) || settings.key?('etag')

      settings
    end

    # Returns the query parameters for a request. It drops nil values and keeps empty Strings.
    #
    # @param filter [Hash, nil] the filter values, sent as `filter[key]`
    # @param params [Hash] the other query parameters
    # @return [Hash] the query parameters
    # @raise [TypeError] if the filter is not a Hash
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

    # Returns the headers for an idempotency key.
    #
    # @param key [String, nil] the idempotency key
    # @return [Hash] the `Idempotency-Key` header, or an empty Hash if the key is nil
    # @raise [TypeError] if the key is not a String
    # @raise [MailerLite::InvalidIdempotencyKeyError] if the key is not valid
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
