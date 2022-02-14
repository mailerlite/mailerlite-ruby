# frozen_string_literal: true

module MailerLite
  # This is a class for manipulating the subscribers from MailerLite API.
  class Subscribers
    attr_accessor :client,
                  :filter_status,
                  :limit,
                  :page,
                  :email,
                  :fields,
                  :groups,
                  :status,
                  :subscribed_at,
                  :ip_address,
                  :opted_in_at,
                  :optin_ip,
                  :unsubscribed_at

    def initialize(client = MailerLite::Client.new)
      @client = client
      @filter_status = {}
      @limit = {}
      @page = {}
      @email = {}
      @fields = {}
      @groups = []
      @status = {}
      @subscribed_at = {}
      @ip_address = {}
      @opted_in_at = {}
      @optin_ip = {}
      @unsubscribed_at = {}
    end

    def get(filter_status:, limit: nil, page: nil)
      hash = {
        'filter[status]' => filter_status,
        'limit' => limit,
        'page' => page
      }
      response = client.http.get(URI::HTTPS.build(host: API_BASE_HOST, path: '/api/subscribers',
                                                  query: URI.encode_www_form(hash.delete_if { |_, value| value.to_s.strip == '' || value == [] || value == {} })))
      puts response
    end

    def create(email:, fields: nil, groups: nil, status: nil, subscribed_at: nil, ip_address: nil, opted_in_at: nil, optin_ip: nil, unsubscribed_at: nil)
      hash = {
        'email' => email,
        'fields' => fields,
        'groups' => groups,
        'status' => status,
        'subscribed_at' => subscribed_at,
        'ip_address' => ip_address,
        'opted_in_at' => opted_in_at,
        'optin_ip' => optin_ip,
        'unsubscribed_at' => unsubscribed_at
      }
      response = client.http.post("#{API_URL}/subscribers", json: hash.delete_if { |_, value| value.to_s.strip == '' || value == [] || value == {} })
      puts response
    end
  end
end
