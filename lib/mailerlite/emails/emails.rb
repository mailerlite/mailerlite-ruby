# frozen_string_literal: true

module MailerLite
  # This is a class for the emails built with the simple editor.
  #
  # To create such an email, create a campaign with `editor: 'simple'` in the email.
  # The ID of the email is in `data.emails[0].id` of the response.
  #
  # IDs are Strings of the digits 0-9. You can also give them as Integers. An empty ID raises
  # `MailerLite::EmptyIdError`, and an ID with other characters raises `MailerLite::InvalidIdError`.
  #
  # Each method returns the `HTTP::Response` with the `MailerLite::ApiResponse` methods. The methods do not raise
  # for a 4xx or 5xx status: use `response.api_error`. A check of an argument raises before the request, and then
  # the SDK sends no request.
  #
  # Each write needs the etag from the last response for the email, and returns a new etag. The etag covers the
  # whole email, so send the writes to one email one after another. If the email changed after you read it, the
  # API returns 409 and `response.api_error.code` is `VERSION_CONFLICT`. Then `response.api_error.etag` is the
  # current etag.
  class Emails
    # The error code of a write with an etag that is not the current etag of the email.
    VERSION_CONFLICT = 'version_conflict'

    # Block types. The API can also return types that are not in this list.
    module BlockType
      BLOCKQUOTE = 'blockquote'
      BULLETED_LIST = 'bulleted_list'
      BUTTON = 'button'
      CODE = 'code'
      DIVIDER = 'divider'
      HEADING = 'heading'
      IMAGE = 'image'
      NUMBERED_LIST = 'numbered_list'
      PARAGRAPH = 'paragraph'
      SOCIAL_ICON = 'social_icon'
      # Only reads return this type. You cannot insert a block of this type.
      TITLE = 'title'
      VIDEO = 'video'
    end

    # Positions of a block, for `placement`. `BEFORE` and `AFTER` also need a `block_id`.
    # The names are not `START` and `END`, because `END` is a keyword in Ruby.
    module BlockPosition
      AT_START = 'start'
      AT_END = 'end'
      BEFORE = 'before'
      AFTER = 'after'
    end

    # Where the palette of an email comes from, in `settings[:brand][:mode]`.
    module BrandMode
      ACCOUNT = 'account'
      TEMPLATE = 'template'
      CUSTOM = 'custom'
    end

    attr_reader :client

    # Inits the `Emails` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns the email with its settings and blocks, and the etag of the email.
    #
    # @param email_id [String, Integer] the ID of the email
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError, TypeError] if the ID is not valid
    def get(email_id)
      email_id = Params.path_id(email_id, 'email_id')
      Request.call(client, :get, "/emails/#{email_id}")
    end
  end
end
