# frozen_string_literal: true

require 'uri'

module MailerLite
  # Encodes values for the query string of the MailerLite API.
  module QueryParams
    module_function

    def boolean(value)
      return if value.nil?

      value ? 1 : 0
    end

    def filter(filter, keys)
      filter.each_with_object({}) do |(key, value), params|
        params["filter[#{key}]"] = value.is_a?(Array) ? value.join(',') : value if keys.include?(key)
      end
    end

    def report(start_date:, end_date:, shop_id:, excel:)
      { 'start_date' => start_date, 'end_date' => end_date, 'shop_id' => shop_id, 'excel' => boolean(excel) }
    end

    def uri(url, params)
      uri = URI(url)
      query = URI.encode_www_form(params.compact)
      uri.query = query unless query.empty?
      uri
    end
  end
end
