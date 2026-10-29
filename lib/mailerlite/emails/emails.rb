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

    # Returns the HTML that the email sends, and the etag of the email.
    # The API can return a temporary 503 error. Then try again later.
    #
    # @param email_id [String, Integer] the ID of the email
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError, TypeError] if the ID is not valid
    def get_html(email_id)
      email_id = Params.path_id(email_id, 'email_id')
      Request.call(client, :get, "/emails/#{email_id}/html")
    end

    # Returns the block and its place in the email, and the etag of the email.
    # `placement` has the IDs of the blocks `after` and `before` it, or nil.
    #
    # @param email_id [String, Integer] the ID of the email
    # @param block_id [String, Integer] the ID of the block
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError, TypeError] if an ID is not valid
    def get_block(email_id:, block_id:)
      email_id = Params.path_id(email_id, 'email_id')
      block_id = Params.path_id(block_id, 'block_id')
      Request.call(client, :get, "/emails/#{email_id}/blocks/#{block_id}")
    end

    # Inserts a block in the email. Returns the new block and the new etag of the email.
    #
    # @param email_id [String, Integer] the ID of the email
    # @param etag [String] the etag from the last response for the email
    # @param type [String] the block type, see `BlockType`. You cannot insert `title`.
    # @param editor_content [Hash] the content of the block. It can be empty. Its keys are camelCase, for example `textAlign`.
    # @param placement [Hash, nil] `position` (see `BlockPosition`) and, for `before` and `after`, `block_id`.
    #   Without it, the API puts the block at the end of the email.
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError] if an ID is not valid
    # @raise [MailerLite::EmptyEtagError] if the etag is empty
    # @raise [TypeError] if an argument has a type that is not valid
    def create_block(email_id:, etag:, type:, editor_content:, placement: nil)
      email_id = Params.path_id(email_id, 'email_id')
      body = block_body(type, editor_content, placement).merge('etag' => Params.etag(etag))
      Request.call(client, :post, "/emails/#{email_id}/blocks", json: body)
    end

    # Updates a block of the email. The new content replaces the whole content of the block: the API removes the
    # keys that you do not send. Returns the block and the new etag of the email.
    #
    # @param email_id [String, Integer] the ID of the email
    # @param block_id [String, Integer] the ID of the block
    # @param etag [String] the etag from the last response for the email
    # @param editor_content [Hash] the new content of the block. Its keys are camelCase, for example `textAlign`.
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError] if an ID is not valid
    # @raise [MailerLite::EmptyEtagError] if the etag is empty
    # @raise [TypeError] if an argument has a type that is not valid
    def update_block(email_id:, block_id:, etag:, editor_content:)
      email_id = Params.path_id(email_id, 'email_id')
      block_id = Params.path_id(block_id, 'block_id')
      body = { 'editor_content' => Params.require_hash(editor_content, 'editor_content'), 'etag' => Params.etag(etag) }
      Request.call(client, :patch, "/emails/#{email_id}/blocks/#{block_id}", json: body)
    end

    # Deletes a block of the email, and the blocks in it. The response has only the new etag of the email,
    # so the method returns the response and not true.
    #
    # @param email_id [String, Integer] the ID of the email
    # @param block_id [String, Integer] the ID of the block
    # @param etag [String] the etag from the last response for the email
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError] if an ID is not valid
    # @raise [MailerLite::EmptyEtagError] if the etag is empty
    # @raise [TypeError] if an argument has a type that is not valid
    def delete_block(email_id:, block_id:, etag:)
      email_id = Params.path_id(email_id, 'email_id')
      block_id = Params.path_id(block_id, 'block_id')
      Request.call(client, :delete, "/emails/#{email_id}/blocks/#{block_id}", json: { 'etag' => Params.etag(etag) })
    end

    # Moves a block of the email. Returns the block, its new place in the email, and the new etag of the email.
    #
    # @param email_id [String, Integer] the ID of the email
    # @param block_id [String, Integer] the ID of the block to move
    # @param etag [String] the etag from the last response for the email
    # @param placement [Hash] `position` (see `BlockPosition`) and, for `before` and `after`, `block_id`
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError] if an ID is not valid
    # @raise [MailerLite::EmptyEtagError] if the etag is empty
    # @raise [TypeError] if an argument has a type that is not valid
    def move_block(email_id:, block_id:, etag:, placement:)
      email_id = Params.path_id(email_id, 'email_id')
      block_id = Params.path_id(block_id, 'block_id')
      body = { 'placement' => Params.placement(placement), 'etag' => Params.etag(etag) }
      Request.call(client, :post, "/emails/#{email_id}/blocks/#{block_id}/move", json: body)
    end

    # Validates a block before you insert it. It needs no email and no etag. An invalid block is not an error:
    # the response has `valid` set to false and the `errors` for each field.
    #
    # @param type [String] the block type, see `BlockType`
    # @param editor_content [Hash] the content of the block. Its keys are camelCase, for example `textAlign`.
    # @param placement [Hash, nil] `position` (see `BlockPosition`) and, for `before` and `after`, `block_id`
    # @return [HTTP::Response] the response from the API, with `valid`, `errors` and `schema`
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError] if the `block_id` of the placement is not valid
    # @raise [TypeError] if an argument has a type that is not valid
    def validate_block(type:, editor_content:, placement: nil)
      Request.call(client, :post, '/emails/blocks/validate', json: block_body(type, editor_content, placement))
    end

    # Updates the design settings of the email. Returns the settings and the new etag of the email.
    #
    # Send only the keys to change, in the shape of `settings` in the response of `get`. The groups are `brand`,
    # `layout`, `typography`, `button` and `footer`. The SDK sends exactly the keys of the Hash:
    # - a key that is not in the Hash does not change;
    # - an empty String unsets the value;
    # - any other value is the new value. Send style values as Strings, for example '16'.
    #
    # The API stores each value that you send, also a value that the email inherits from the account.
    # `footer.social_links` replaces the whole list: keep the `link_id` of each link to keep its click history.
    # To apply a preset palette, send its `identifier` from `BrandStyles#get` in `brand.style`.
    # The response can have `rejected` when the API removed unsafe values.
    #
    # @param email_id [String, Integer] the ID of the email
    # @param etag [String] the etag from the last response for the email
    # @param settings [Hash] the settings to change, without `etag`
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError] if the ID is not valid
    # @raise [MailerLite::EmptyEtagError] if the etag is empty
    # @raise [ArgumentError] if the settings contain an `etag` key
    # @raise [TypeError] if an argument has a type that is not valid
    def update_settings(email_id:, etag:, settings:)
      email_id = Params.path_id(email_id, 'email_id')
      body = Params.settings(settings).merge('etag' => Params.etag(etag))
      Request.call(client, :patch, "/emails/#{email_id}/settings", json: body)
    end

    # Validates a change to the design settings of the email with the rules of `update_settings`, and saves nothing.
    # It needs no etag. Invalid settings are not an error: the response has `valid` set to false and the `errors`
    # for each field. The response can also have `rejected`.
    #
    # @param email_id [String, Integer] the ID of the email
    # @param settings [Hash] the settings that you want to send to `update_settings`, without `etag`
    # @return [HTTP::Response] the response from the API, with `valid`, `errors` and `schema`
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError] if the ID is not valid
    # @raise [ArgumentError] if the settings contain an `etag` key
    # @raise [TypeError] if an argument has a type that is not valid
    def validate_settings(email_id:, settings:)
      email_id = Params.path_id(email_id, 'email_id')
      Request.call(client, :post, "/emails/#{email_id}/settings/validate", json: Params.settings(settings))
    end

    # Saves the email as a new template with the name. The API cannot delete templates.
    #
    # @param email_id [String, Integer] the ID of the email
    # @param name [String] the name of the template
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError] if the ID is not valid
    # @raise [TypeError] if an argument has a type that is not valid
    def create_template(email_id:, name:)
      email_id = Params.path_id(email_id, 'email_id')
      Request.call(client, :post, "/emails/#{email_id}/templates", json: { 'name' => Params.require_string(name, 'name') })
    end

    # Returns the saved versions of the email, newest first. `current` marks the version that the email has now.
    #
    # @param email_id [String, Integer] the ID of the email
    # @param page [Integer] the page number of the results to return
    # @param limit [Integer] the maximum number of versions to return, from 1 to 100
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError, TypeError] if the ID is not valid
    def list_versions(email_id, page: nil, limit: nil)
      email_id = Params.path_id(email_id, 'email_id')
      Request.call(client, :get, "/emails/#{email_id}/versions", query: Params.query(page: page, limit: limit))
    end

    # Saves the content and the settings of the email as a new version. If nothing changed after the last version,
    # the API saves no new version and returns the last version. The status code (`response.code`) is 201 for a new
    # version and 200 for the last version. Both are a success.
    #
    # @param email_id [String, Integer] the ID of the email
    # @return [HTTP::Response] the response from the API
    # @raise [MailerLite::EmptyIdError, MailerLite::InvalidIdError, TypeError] if the ID is not valid
    def create_version(email_id)
      email_id = Params.path_id(email_id, 'email_id')
      Request.call(client, :post, "/emails/#{email_id}/versions")
    end

    private

    # Returns the body to insert or to validate a block.
    def block_body(type, editor_content, placement)
      body = {
        'type' => Params.require_string(type, 'type'),
        'editor_content' => Params.require_hash(editor_content, 'editor_content')
      }
      body['placement'] = Params.placement(placement) unless placement.nil?
      body
    end
  end
end
