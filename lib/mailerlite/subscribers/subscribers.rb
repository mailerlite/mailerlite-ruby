# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the subscribers from MailerLite API.
  class Subscribers
    attr_reader :client

    # Inits the `Subscribers` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of subscribers that match the specified filter criteria.
    #
    # @param filter[:status] [String] the status of the subscribers to include in the results
    # @param filter[:group] [String] the ID of a group, or several IDs separated with commas
    # @param filter[:automation] [String] the ID of an automation, or several IDs separated with commas
    # @param filter[:form] [String] the ID of a form, or several IDs separated with commas
    # @param filter[:site] [String] the ID of a site, or several IDs separated with commas
    # @param filter[:page] [String] the ID of a landing page, or several IDs separated with commas
    # @param filter[:import] [String] the ID of an import, or several IDs separated with commas
    # @param filter[:post] [String] the ID of a blog post, or several IDs separated with commas
    # @param limit [Integer] the maximum number of subscribers to return
    # @param cursor [String] the cursor for the page of results to return
    # @param sort [String] the field to sort by, prefix with - for descending order
    # @param include [String] the relations to embed, only groups is supported
    # @param start_date [String] only subscribers who signed up on or after this date
    # @param end_date [String] only subscribers who signed up on or before this date
    # @param with_fields [Boolean] return each custom field with its name, value and type
    # @return [HTTP::Response] the response from the API
    def fetch(filter:, limit: nil, cursor: nil, sort: nil, include: nil, start_date: nil, end_date: nil, with_fields: nil)
      params = QueryParams.filter(filter, %i[status group automation form site page import post])

      params['limit'] = limit if limit
      params['cursor'] = cursor if cursor
      params['sort'] = sort if sort
      params['include'] = include if include
      params['start_date'] = start_date if start_date
      params['end_date'] = end_date if end_date
      params['with_fields'] = QueryParams.boolean(with_fields)
      client.http.get(QueryParams.uri("#{MAILERLITE_API_URL}/subscribers", params))
    end

    # Creates a new subscriber with the specified details.
    #
    # @param email [String] the email address of the new subscriber
    # @param fields [Hash] a hash of custom fields and their values for the subscriber
    # @param groups [Array] an array of group IDs to add the subscriber to
    # @param status [String] the status of the new subscriber
    # @param subscribed_at [DateTime] the date and time when the subscriber was added
    # @param ip_address [String] the IP address of the subscriber
    # @param opted_in_at [DateTime] the date and time when the subscriber confirmed their subscription
    # @param optin_ip [String] the IP address of the subscriber when they confirmed their subscription
    # @param unsubscribed_at [DateTime] the date and time when the subscriber was unsubscribed
    # @param resubscribe [Boolean] reactivate the subscriber if they are unsubscribed, bounced or junk
    # @param double_optin [Boolean] send a confirmation email to the new subscriber
    # @param notes [Array] notes to add to the subscriber
    # @return [HTTP::Response] the response from the API
    def create(email:, fields: nil, groups: nil, status: nil, subscribed_at: nil, ip_address: nil, opted_in_at: nil, optin_ip: nil, unsubscribed_at: nil, resubscribe: nil, double_optin: nil, notes: nil)
      params = { 'email' => email }

      params['fields'] = fields if fields
      params['groups'] = groups if groups
      params['status'] = status if status
      params['subscribed_at'] = subscribed_at if subscribed_at
      params['ip_address'] = ip_address if ip_address
      params['opted_in_at'] = opted_in_at if opted_in_at
      params['optin_ip'] = optin_ip if optin_ip
      params['unsubscribed_at'] = unsubscribed_at if unsubscribed_at
      params['resubscribe'] = resubscribe
      params['double_optin'] = double_optin
      params['notes'] = notes if notes

      client.http.post("#{MAILERLITE_API_URL}/subscribers", json: params.compact)
    end

    # Updates an existing subscriber with the specified details.
    #
    # @param subscriber_id [String] the ID of the subscriber to update
    # @param email [String] the email address of the new subscriber
    # @param fields [Hash] a hash of custom fields and their values for the subscriber
    # @param groups [Array] an array of group IDs to add the subscriber to
    # @param status [String] the status of the new subscriber
    # @param subscribed_at [DateTime] the date and time when the subscriber was added
    # @param ip_address [String] the IP address of the subscriber
    # @param opted_in_at [DateTime] the date and time when the subscriber confirmed their subscription
    # @param optin_ip [String] the IP address of the subscriber when they confirmed their subscription
    # @param unsubscribed_at [DateTime] the date and time when the subscriber was unsubscribed
    # @return [HTTP::Response] the response from the API
    def update(subscriber_id, email: nil, fields: nil, groups: nil, status: nil, subscribed_at: nil, ip_address: nil, opted_in_at: nil, optin_ip: nil, unsubscribed_at: nil)
      params = {}

      params['email'] = email if email
      params['fields'] = fields if fields
      params['groups'] = groups if groups
      params['status'] = status if status
      params['subscribed_at'] = subscribed_at if subscribed_at
      params['ip_address'] = ip_address if ip_address
      params['opted_in_at'] = opted_in_at if opted_in_at
      params['optin_ip'] = optin_ip if optin_ip
      params['unsubscribed_at'] = unsubscribed_at if unsubscribed_at

      client.http.put("#{MAILERLITE_API_URL}/subscribers/#{subscriber_id}", json: params.compact)
    end

    # Returns the details of the specified subscribers
    #
    # @param subscriber_id [String] the ID of the subscriber to get
    # @return [HTTP::Response] the response from the API
    def get(subscriber_id)
      client.http.get("#{MAILERLITE_API_URL}/subscribers/#{subscriber_id}")
    end

    # Returns the activity log of the specified subscriber
    #
    # @param subscriber_id [String] the ID of the subscriber
    # @param filter[:log_name] [String] the type of activity to include in the results
    # @param limit [Integer] the maximum number of entries to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def activity_log(subscriber_id:, filter: {}, limit: nil, page: nil)
      params = QueryParams.filter(filter, %i[log_name]).merge('limit' => limit, 'page' => page)
      client.http.get(QueryParams.uri("#{MAILERLITE_API_URL}/subscribers/#{subscriber_id}/activity-log", params))
    end

    # Returns the details of the specified subscribers
    #
    # @param import_id [String] the ID of the import to fetch report
    # @return [HTTP::Response] the response from the API
    def get_single_import(import_id)
      client.http.get("#{MAILERLITE_API_URL}/subscribers/import/#{import_id}")
    end

    # Returns the total number of subscribers in the MailerLite account.
    #
    # @return [HTTP::Response] the response from the API
    def fetch_count
      client.http.get("#{MAILERLITE_API_URL}/subscribers/?limit=0")
    end

    # Deletes the specified subscriber.
    #
    # @param subscriber_id [String] the ID of the subscriber to delete
    # @return [HTTP::Response] the response from the API
    def delete(subscriber_id)
      client.http.delete("#{MAILERLITE_API_URL}/subscribers/#{subscriber_id}")
    end

    # Forgets the specified subscriber.
    #
    # @param subscriber_id [String] the ID of the subscriber to forget
    # @return [HTTP::Response] the response from the API
    def forget(subscriber_id)
      client.http.post("#{MAILERLITE_API_URL}/subscribers/#{subscriber_id}/forget")
    end
  end
end
