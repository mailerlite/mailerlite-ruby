# frozen_string_literal: true

require 'http'
require 'dotenv/load'

MAILERLITE_API_URL = 'https://connect.mailerlite.com/api'

Dotenv.require_keys('MAILERLITE_API_TOKEN')

# mailerlite-ruby is a gem that integrates all endpoints from MailerLite API
module MailerLite
  attr_reader :api_token

  # Inits the client.
  class Client
    def initialize(api_token = ENV.fetch('MAILERLITE_API_TOKEN', nil))
      @api_token = api_token
    end

    def headers
      {
        'User-Agent' => "MailerLite-client-ruby/#{MailerLite::VERSION}",
        'Accept' => 'application/json',
        'Content-type' => 'application/json'
      }
    end

    def http
      HTTP
        .timeout(connect: 15, read: 30)
        .auth("Bearer #{@api_token}")
        .headers(headers)
    end
  end
end
