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
    # @param filter_status [String] the status of the Campaigns to include in the results, must be one of [sent, draft, ready], Defaults to ready
    # @param filter_type [String] the filter type of the Campaigns to include in the results, must be one of [regular, ab, resend, rss], Defaults to all
    # @param limit [Integer] the maximum number of Campaigns to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def get(filter_status:, filter_type: nil, limit: nil, page: nil)
      params = { 'filter[status]' => filter_status }

      params['filter[type]'] = filter_type if filter_type 
      params['limit'] = limit if limit
      params['page'] = page if page

      client.http.get("#{API_URL}/campaigns", json: params.compact)
    end

    # Creates a new campaign with the specified details.
    #
    # @param name [String] Maximum string length of 255 characters
    # @param language_id [integer] Used to define the language in the unsubscribe template. Must be a valid language id. Defaults to english
    # @param type [String] Must be one of the following: regular, ab, resend. Type resend is only available for accounts on growing or advanced plans
    # @param emails [Array] Must contain 1 email object item
    # @param emails.*.subject [String] Maximum string length of 255 characters
    # @param emails.*.from_name [String] Maximum string length of 255 characters
    # @param emails.*. from [String] Must be a valid email address that has been already verified on MailerLite
    # @param emails.*.content [String] Must be a valid html content and account must be on growing or advanced plan
    # @param groups [Array] Must contain valid group ids belonging to the account
    # @param segments [Array] Must contain valid segment ids belonging to the account. If both groups and segments are provided, only segments are used
    # @param ab_settings [Array] only if type is ab -  All items of the array are required
    # @param ab_settings[test_type] [String] only if type is ab -  Must be one of the following: subject, sender
    # @param ab_settings[select_winner_by] [String] only if type is ab -  Must be one of the following: o (for opens), c (for clicks)
    # @param ab_settings[after_time_amount] [integer] only if type is ab -  Defines the amount of wait time for the ab testing
    # @param ab_settings[after_time_unit] [String] only if type is ab -  Defines the unit of the wait time. Must be one of the following: h (for hours) or d (for days)
    # @param ab_settings[test_split] [integer] only if type is ab -  Must be between 5 and 25
    # @param ab_settings[b_value] [Array] only if type is ab -  Must contain the items for the b version of the campaign
    # @param ab_settings[b_value][subject] [String] only if ab test type is subject - Maximum string length of 255 characters
    # @param ab_settings[b_value][from_name] [String] only if ab test type is sender =  Maximum string length of 255 characters
    # @param ab_settings[b_value][from] [String] only if ab test type is sender =  Must be a valid email address that has been already verified on MailerLite
    # @param resend_settings [Array] only if type is resend -  All items of the array are required
    # @param resend_settings[test_type] [String] only if type is resend -  Must be one of the following: subject
    # @param resend_settings[select_winner_by] [String] only if type is resend -  Defines the metric on which the recipients of the second email are selected. Must be one of the following: o (didt open the email), c (didt click the email)
    # @param resend_settings[b_value] [Array] only if type is resend -  Must contain the items for the auto resend of the campaign
    # @param resend_setings[b_value][subject] [String] only if type is resend -  Maximum string length of 255 characters
    # @return [HTTP::Response] the response from the API
    def create(name:, language_id: nil, type:, emails:, groups: nil, segments: nil, ab_settings: nil, resend_settings: nil)
      params = { 'name' => name }
      params['type'] = type 
      params['emails'] = emails 
      params['language_id'] = language_id if language_id
      params['groups'] = groups if groups
      params['segments'] = segments if segments
      if type == "ab"
        params['ab_settings[test_type]'] = ab_settings['test_type']
        params['ab_settings[select_winner_by]'] = ab_settings['select_winner_by']
        params['ab_settings[after_time_amount]'] = ab_settings['after_time_amount']
        params['ab_settings[after_time_unit]'] = ab_settings['after_time_unit']
        params['ab_settings[test_split]'] = ab_settings['test_split']
        if ab_settings['test_type'] == "subject"
          params['ab_settings[b_value][subject]'] = ab_settings['b_value']['subject']
        elsif ab_settings['test_type'] == "sender"
          params['ab_settings[b_value][from_name]'] = ab_settings['b_value']['from_name']
          params['ab_settings[b_value][from]'] = ab_settings['b_value']['from']
        end
      elsif type == "resend"
        params['resend_settings[test_type]'] = resend_settings['test_type']
        params['resend_settings[select_winner_by]'] = resend_settings['select_winner_by']
        params['resend_settings[b_value][subject]'] = resend_settings['b_value']['subject']
      end
      
      client.http.post("#{API_URL}/campaigns", json: params.compact)
    end

    # Update a new campaign with the specified details.
    #
    # @param name [String] Maximum string length of 255 characters
    # @param language_id [integer] Used to define the language in the unsubscribe template. Must be a valid language id. Defaults to english
    # @param type [String] Must be one of the following: regular, ab, resend. Type resend is only available for accounts on growing or advanced plans
    # @param emails [Array] Must contain 1 email object item
    # @param emails.*.subject [String] Maximum string length of 255 characters
    # @param emails.*.from_name [String] Maximum string length of 255 characters
    # @param emails.*. from [String] Must be a valid email address that has been already verified on MailerLite
    # @param emails.*.content [String] Must be a valid html content and account must be on growing or advanced plan
    # @param groups [Array] Must contain valid group ids belonging to the account
    # @param segments [Array] Must contain valid segment ids belonging to the account. If both groups and segments are provided, only segments are used
    # @param ab_settings [Array] only if type is ab -  All items of the array are required
    # @param ab_settings[test_type] [String] only if type is ab -  Must be one of the following: subject, sender
    # @param ab_settings[select_winner_by] [String] only if type is ab -  Must be one of the following: o (for opens), c (for clicks)
    # @param ab_settings[after_time_amount] [integer] only if type is ab -  Defines the amount of wait time for the ab testing
    # @param ab_settings[after_time_unit] [String] only if type is ab -  Defines the unit of the wait time. Must be one of the following: h (for hours) or d (for days)
    # @param ab_settings[test_split] [integer] only if type is ab -  Must be between 5 and 25
    # @param ab_settings[b_value] [Array] only if type is ab -  Must contain the items for the b version of the campaign
    # @param ab_settings[b_value][subject] [String] only if ab test type is subject - Maximum string length of 255 characters
    # @param ab_settings[b_value][from_name] [String] only if ab test type is sender =  Maximum string length of 255 characters
    # @param ab_settings[b_value][from] [String] only if ab test type is sender =  Must be a valid email address that has been already verified on MailerLite
    # @param resend_settings [Array] only if type is resend -  All items of the array are required
    # @param resend_settings[test_type] [String] only if type is resend -  Must be one of the following: subject
    # @param resend_settings[select_winner_by] [String] only if type is resend -  Defines the metric on which the recipients of the second email are selected. Must be one of the following: o (didt open the email), c (didt click the email)
    # @param resend_settings[b_value] [Array] only if type is resend -  Must contain the items for the auto resend of the campaign
    # @param resend_setings[b_value][subject] [String] only if type is resend -  Maximum string length of 255 characters
    # @return [HTTP::Response] the response from the API
    def update(campaign:,name:, language_id: nil, type:, emails:, groups: nil, segments: nil, ab_settings: nil, resend_settings: nil)
      params = { 'name' => name }
      params['emails'] = emails  
      params['language_id'] = language_id if language_id
      params['groups'] = groups if groups
      params['segments'] = segments if segments
      if type == "ab"
        params['ab_settings[test_type]'] = ab_settings['test_type']
        params['ab_settings[select_winner_by]'] = ab_settings['select_winner_by']
        params['ab_settings[after_time_amount]'] = ab_settings['after_time_amount']
        params['ab_settings[after_time_unit]'] = ab_settings['after_time_unit']
        params['ab_settings[test_split]'] = ab_settings['test_split']
        if ab_settings['test_type'] == "subject"
          params['ab_settings[b_value][subject]'] = ab_settings['b_value']['subject']
        elsif ab_settings['test_type'] == "sender"
          params['ab_settings[b_value][from_name]'] = ab_settings['b_value']['from_name']
          params['ab_settings[b_value][from]'] = ab_settings['b_value']['from']
        end
      elsif type == "resend"
        params['resend_settings[test_type]'] = resend_settings['test_type']
        params['resend_settings[select_winner_by]'] = resend_settings['select_winner_by']
        params['resend_settings[b_value][subject]'] = resend_settings['b_value']['subject']
      end
      
      client.http.put("#{API_URL}/campaigns/#{campaign}", json: params.compact)
    end
    
    # Schedules the specified campaign.
    #
    # @param campaign [String] the ID of the campaign to schedule
    # @param delivery	[String]	yes unless campaign type is rss	Must be one of the following: instant, scheduled, timezone_based
    # @param schedule[date]	[String]	only for scheduled delivery type	Must be a date in the future
    # @param schedule[hours]	[String]	only for scheduled or timezone based delivery types	Must be a valid hour in HH format
    # @param schedule[minutes]	[String]	only for scheduled or timezone based delivery types	Must be a valid minute in ii format
    # @param schedule[timezone_id]	[Integer]	no	Must be a valid timezone id, defaults to the account's timezone id
    # @param resend[delivery]	[String]	only for campaign of type auto resend	Must be Must be one of the following: day, scheduled
    # @param resend[date]	[String]	only for campaign of type auto resend	Must be a date in the future
    # @param resend[hours]	[String]	only for campaign of type auto resend	Must be a valid hour in HH format
    # @param resend[minutes]	[String]	only for campaign of type auto resend	Must be a valid minute in ii format
    # @param resend[timezone_id]	[Integer]	no	Must be a valid timezone id, defaults to the account's timezone id
    # @return [HTTP::Response] the response from the API
    def schedule(campaign:, delivery:, schedule:nil, resend:nil)
      params = {}
      params['delivery'] = delivery if delivery
      if (delivery == "scheduled" || delivery == "timezone_based") and schedule
        params['schedule[date]'] = schedule['date'] if delivery == "scheduled" and schedule.key?('date')
        params['schedule[hours]'] = schedule['hours'] if schedule.key?('hours')
        params['schedule[minutes]'] = schedule['minutes'] if schedule.key?('minutes')
        params['schedule[timezone_id]'] = schedule['timezone_id'] if schedule.key?('timezone_id')
      end
      
      params['resend[delivery]'] = resend['delivery'] if resend and resend.key?('delivery')
      params['resend[date]'] = resend['date'] if resend and resend.key?('date')
      params['resend[hours]'] = resend['hours'] if resend and resend.key?('hours')
      params['resend[minutes]'] = resend['minutes'] if resend and resend.key?('minutes')
      params['resend[timezone_id]'] = resend['timezone_id'] if resend and resend.key?('timezone_id')
      client.http.post("#{API_URL}/campaigns/#{campaign}/schedule", json: params.compact)
    end
    
    # Returns the details of the specified Campaigns
    #
    # @param campaign [String] the ID of the campaign to fetch
    # @return [HTTP::Response] the response from the API
    def fetch(campaign)
      client.http.get("#{API_URL}/campaigns/#{campaign}")
    end

    # Cancels the specified campaign.
    #
    # @param campaign [String] the ID of the campaign to delete
    # @return [HTTP::Response] the response from the API
    def cancel(campaign)
      client.http.post("#{API_URL}/campaigns/#{campaign}/cancel")
    end

    # Deletes the specified campaign.
    #
    # @param campaign [String] the ID of the campaign to delete
    # @return [HTTP::Response] the response from the API
    def delete(campaign)
      client.http.delete("#{API_URL}/campaigns/#{campaign}")
    end
  end
end