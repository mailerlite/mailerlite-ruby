# frozen_string_literal: true

require 'webmock/rspec'

module RequestStub
  def stub_api(method, path, query: nil, body: nil)
    pattern = {}
    pattern[:query] = query if query
    pattern[:body] = body if body
    stub_request(method, "#{MAILERLITE_API_URL}#{path}")
      .with(**pattern) { |request| body || request.body.to_s.empty? }
      .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
  end

  def capture_raw_uris
    uris = []
    allow_any_instance_of(HTTP::Client).to receive(:perform).and_wrap_original do |method, request, options|
      uris << request.uri.to_s
      method.call(request, options)
    end
    uris
  end
end

RSpec.configure { |config| config.include RequestStub }
