# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the Automation templates from MailerLite API.
  class AutomationTemplates
    attr_reader :client

    # Inits the `AutomationTemplates` class with the specified `client`.
    #
    # @param client [MailerLite::Client] the `Client` instance to use
    def initialize(client: MailerLite::Client.new)
      @client = client
    end

    # Returns a list of Automation templates that match the specified filter criteria.
    #
    # @param filter[:type,:category] [Hash] filters for the templates
    # @param limit [Integer] the maximum number of templates to return
    # @param page [Integer] the page number of the results to return
    # @return [HTTP::Response] the response from the API
    def list(filter: {}, limit: nil, page: nil)
      params = QueryParams.filter(filter, %i[type category]).merge('limit' => limit, 'page' => page)
      client.http.get(QueryParams.uri("#{MAILERLITE_API_URL}/automation-templates", params))
    end

    # Creates an Automation from the specified template
    #
    # @param template_id [String] the ID of the Automation template
    # @return [HTTP::Response] the response from the API
    def select_template(template_id)
      client.http.post("#{MAILERLITE_API_URL}/automations/select-template/#{template_id}")
    end
  end
end
