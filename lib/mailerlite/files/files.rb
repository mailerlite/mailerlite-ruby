# frozen_string_literal: true

module MailerLite
  # This is a class for the files of the media library from MailerLite API.
  # The name is `Files`, not `File`, so it does not hide the `File` class of Ruby.
  class Files
    # File types for `filter: { type: ... }`. The API can also return types that are not in this list.
    module FileType
      IMAGE = 'image'
      PDF = 'pdf'
      EPUB = 'epub'
    end

    # Sort values. The values that start with `-` sort in descending order.
    module FileSort
      CREATED_AT = 'created_at'
      CREATED_AT_DESC = '-created_at'
      NAME = 'name'
      NAME_DESC = '-name'
      SIZE = 'size'
      SIZE_DESC = '-size'
    end

    attr_reader :client

    # Inits the `Files` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns the files of the media library. Use their `url` in image blocks.
    # `width` and `height` are nil for files that are not images. The SDK does not send nil values.
    #
    # @param filter [Hash, nil] `name` (a part of the file name) and `type` (see `FileType`)
    # @param sort [String, nil] see `FileSort`. The default is `-created_at`.
    # @param page [Integer, nil] the page number of the results to return
    # @param limit [Integer, nil] the maximum number of files to return, from 1 to 100
    # @return [HTTP::Response] the response from the API, with the `MailerLite::ApiResponse` methods
    # @raise [TypeError] if the filter is not a Hash
    def list(filter: nil, sort: nil, page: nil, limit: nil)
      Request.call(client, :get, '/files', query: Params.query(filter: filter, sort: sort, page: page, limit: limit))
    end
  end
end
