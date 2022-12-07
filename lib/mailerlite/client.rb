# frozen_string_literal: true

require 'http'
require 'dotenv/load'

API_URL = 'https://connect.mailerlite.com/api'
API_BASE_HOST = 'connect.mailerlite.com'

Dotenv.require_keys('MAILERLITE_API_TOKEN')

# mailerlite-ruby is a gem that integrates all endpoints from MailerLite API
module MailerLite
  attr_reader :api_token

  class Client
    HEADERS = {
      'User-Agent' => "MailerLite-client-ruby/#{MailerLite::VERSION}",
      'Accept' => 'application/json',
      'Content-type' => 'application/json'
    }

    def initialize(api_token = ENV.fetch('MAILERLITE_API_TOKEN', nil))
      @api_token = api_token
    end

    def http
      HTTP
        .timeout(connect: 15, read: 30)
        .auth_bearer(@api_token)
        .headers(HEADERS)
    end
  end
end
