# frozen_string_literal: true

require 'http'
require 'dotenv/load'

API_URL = 'https://connect.mailerlite.com/api'
API_BASE_HOST = 'connect.mailerlite.com'

Dotenv.require_keys('MAILERLITE_API_TOKEN')

# mailerlite-ruby is a gem that integrates all endpoints from MailerLite API
module MailerLite
  attr_reader :api_token

  # Inits the client.
  class Client
    def initialize(api_token = ENV['MAILERLITE_API_TOKEN'])
      @api_token = api_token
    end

    def http
      HTTP
        .timeout(connect: 15, read: 30)
        .auth("Bearer #{@api_token}")
        .headers('User-Agent' => 'MailerLite-client-ruby/1.0.0',
                 'Accept' => 'application/json')
    end
  end
end
