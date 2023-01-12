# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Campaigns from MailerLite API.
  class Campaigns
    attr_reader :client

    # Inits the `Campaigns` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of Campaigns that match the specified filter criteria.
    #
    # @param filter[:status,:type] [String] the status of the Campaigns to include in the results, must be one of [sent, draft, ready], Defaults to ready.
    # The filter type of the Campaigns to include in the results, must be one of [regular, ab, resend, rss], Defaults to all
    # @param limit [Integer] the maximum number of Campaigns to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get(filter:, limit: nil, page: nil)
      params = { 'filter[status]' => filter[:status] }
      params['filter[type]'] = filter[:type] if filter.key?(:type)
      params['limit'] = limit if limit
      params['page'] = page if page
      uri = URI("#{API_URL}/campaigns")
      uri.query = URI.encode_www_form(params.compact)
      client.http.get(uri)
    end

    # Creates a new campaign with the specified details.
    #
    # @param name [String] Maximum string length of 255 characters
    # @param language_id [integer] Used to define the language in the unsubscribe template. Must be a valid language id. Defaults to english
    # @param type [String] Must be one of the following: regular, ab, resend. Type resend is only available for accounts on growing or advanced plans
    # @param emails [Array] Must contain 1 email object item
    # @param groups [Array] Must contain valid group ids belonging to the account
    # @param segments [Array] Must contain valid segment ids belonging to the account. If both groups and segments are provided, only segments are used
    # @param ab_settings [Array<Array>] only if type is ab -  All items of the array are required
    # @param resend_settings [:test_type,:select_winner_by,:b_value] https://developers.mailerlite.com/docs/campaigns.html#create-a-campaign
    # @return [HTTP::Response] the response from the API
    def create(name:, type:, emails:, language_id: nil, groups: nil, segments: nil, ab_settings: nil, resend_settings: nil)
      params = { 'name' => name }
      params['type'] = type
      params['emails'] = emails
      params['language_id'] = language_id if language_id
      params['groups'] = groups if groups
      params['segments'] = segments if segments
      case type
      when 'ab'
        params['ab_settings'] = {
          test_type: ab_settings[:test_type],
          select_winner_by: ab_settings[:select_winner_by],
          after_time_amount: ab_settings[:after_time_amount],
          after_time_unit: ab_settings[:after_time_unit],
          test_split: ab_settings[:test_split]
        }
        case ab_settings[:test_type]
        when 'subject'
          params['ab_settings']['b_value'] = {
            subject: ab_settings[:b_value][:subject]
          }

        when 'sender'
          params['ab_settings']['b_value'] = {
            from_name: ab_settings[:b_value][:from_name],
            from: ab_settings[:b_value][:from]
          }
        end
      when 'resend'
        params['resend_settings'] = {
          test_type: resend_settings[:test_type],
          select_winner_by: resend_settings[:select_winner_by],
          b_value: {
            subject: resend_settings[:b_value][:subject]
          }
        }
      end

      client.http.post("#{API_URL}/campaigns", body: params.compact.to_json)
    end

    # Update a new campaign with the specified details.
    #
    # @param campaign_id [Integer] the ID of the campaign to update
    # @param name [String] Maximum string length of 255 characters
    # @param language_id [integer] Used to define the language in the unsubscribe template. Must be a valid language id. Defaults to english
    # @param type [String] Must be one of the following: regular, ab, resend. Type resend is only available for accounts on growing or advanced plans
    # @param emails [Array<Array>] Must contain 1 email object item
    # @param groups [Array] Must contain valid group ids belonging to the account
    # @param segments [Array] Must contain valid segment ids belonging to the account. If both groups and segments are provided, only segments are used
    # @param ab_settings [Array<Array>] only if type is ab -  All items of the array are required
    # @param resend_settings [:test_type,:select_winner_by,:b_value] https://developers.mailerlite.com/docs/campaigns.html#update-campaign
    # @return [HTTP::Response] the response from the API
    def update(campaign_id:, name:, type:, emails:, language_id: nil, groups: nil, segments: nil, ab_settings: nil, resend_settings: nil)
      params = { 'name' => name }
      params['emails'] = emails
      params['language_id'] = language_id if language_id
      params['groups'] = groups if groups
      params['segments'] = segments if segments
      case type
      when 'ab'
        params['ab_settings'] = {
          test_type: ab_settings[:test_type],
          select_winner_by: ab_settings[:select_winner_by],
          after_time_amount: ab_settings[:after_time_amount],
          after_time_unit: ab_settings[:after_time_unit],
          test_split: ab_settings[:test_split]
        }
        case ab_settings[:test_type]
        when 'subject'
          params['ab_settings']['b_value'] = {
            subject: ab_settings[:b_value][:subject]
          }

        when 'sender'
          params['ab_settings']['b_value'] = {
            from_name: ab_settings[:b_value][:from_name],
            from: ab_settings[:b_value][:from]
          }

        end
      when 'resend'
        params['resend_settings'] = {
          test_type: resend_settings[:test_type],
          select_winner_by: resend_settings[:select_winner_by],
          b_value: {
            subject: resend_settings[:b_value][:subject]
          }
        }

      end

      client.http.put("#{API_URL}/campaigns/#{campaign_id}", body: params.compact.to_json)
    end

    # Schedules the specified campaign.
    #
    # @param campaign_id [Integer] the ID of the campaign to schedule
    # @param delivery	[String]	yes unless campaign type is rss	Must be one of the following: instant, scheduled, timezone_based
    # @param schedule[:date,:hours,:minutes,:timezone_id]	[Array]	campaign schedule
    # @param resend[:delivery,:date,:hours,:minutes,:timezone_id]	[String]	resend settings
    #        https://developers.mailerlite.com/docs/campaigns.html#schedule-a-campaign
    # @return [HTTP::Response] the response from the API
    def schedule(campaign_id:, delivery:, schedule: nil, resend: nil)
      params = {}
      params['delivery'] = delivery if delivery
      if %w[scheduled timezone_based].include?(delivery) && schedule
        params['schedule'] = {}
        params['schedule']['date'] = schedule[:date] if (delivery == 'scheduled') && schedule.key?(:date)
        params['schedule']['hours'] = schedule[:hours] if schedule.key?(:hours)
        params['schedule']['minutes'] = schedule[:minutes] if schedule.key?(:minutes)
        params['schedule']['timezone_id'] = schedule[:timezone_id] if schedule.key?(:timezone_id)
      end
      params['resend'] = {} if resend
      params['resend']['delivery'] = resend[:delivery] if resend&.key?(:delivery)
      params['resend']['date'] = resend[:date] if resend&.key?(:date)
      params['resend']['hours'] = resend[:hours] if resend&.key?(:hours)
      params['resend']['minutes'] = resend[:minutes] if resend&.key?(:minutes)
      params['resend']['timezone_id'] = resend[:timezone_id] if resend&.key?(:timezone_id)

      client.http.post("#{API_URL}/campaigns/#{campaign_id}/schedule", body: params.compact.to_json)
    end

    # Returns the details of the specified Campaigns
    #
    # @param campaign_id [String] the ID of the campaign to fetch
    # @return [HTTP::Response] the response from the API
    def fetch(campaign_id)
      client.http.get("#{API_URL}/campaigns/#{campaign_id}")
    end

    # Cancels the specified campaign.
    #
    # @param campaign_id [String] the ID of the campaign to delete
    # @return [HTTP::Response] the response from the API
    def cancel(campaign_id)
      client.http.post("#{API_URL}/campaigns/#{campaign_id}/cancel")
    end

    # Deletes the specified campaign.
    #
    # @param campaign_id [String] the ID of the campaign to delete
    # @return [HTTP::Response] the response from the API
    def delete(campaign_id)
      client.http.delete("#{API_URL}/campaigns/#{campaign_id}")
    end

    # activity the subscriber activity for specified campaign
    #
    # @param campaign_id [Integer] the ID of the campaign to activity
    # @param filter[:type,:search] [String] specify filters
    # @param limit [Integer] the maximum number of campaigns to return
    # @param page [Integer] the page number of the results to return
    #        https://developers.mailerlite.com/docs/campaigns.html#get-subscribers-activity-of-a-sent-campaign
    # @return [HTTP::Response] the response from the API
    def activity(campaign_id:, filter: nil, page: nil, limit: nil, sort: nil)
      params = {}
      params['filter'] = {} if filter
      params['filter']['type'] = filter[:type] if filter.key?(:type)
      params['filter']['search'] = filter[:search] if filter.key?(:search)
      params['page'] = page if page
      params['limit'] = limit if limit
      params['sort'] = sort if sort
      client.http.post("#{API_URL}/campaigns/#{campaign_id}/reports/subscriber-activity", body: params.compact.to_json)
    end

    # Get a list of all campaign languages available
    #
    # @return [HTTP::Response] the response from the API
    def languages
      client.http.get("#{API_URL}/campaigns/languages")
    end
  end
end
