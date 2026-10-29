# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'json'
require_relative 'support/json_fixture'

RSpec.describe MailerLite::Emails do
  let(:client) { MailerLite::Client.new }
  let(:emails) { described_class.new(client: client) }

  # Stubs one request. The stub matches only the exact raw body, the Authorization header,
  # and the Idempotency-Key header (or no such header when `key` is nil).
  def stub_api(method, path, body: '', response: {}, status: 200, query: nil, key: nil)
    pattern = { headers: { 'Authorization' => 'Bearer dummy_token' } }
    pattern[:query] = query if query
    stub_request(method, "#{MAILERLITE_API_URL}#{path}")
      .with(**pattern) { |req| req.body == body && req.headers['Idempotency-Key'] == key }
      .to_return(status: status, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  def decoded(response)
    JSON.parse(response.body.to_s)
  end

  # Each value raises the error before the request.
  def invalid_ids
    [
      ['', MailerLite::EmptyIdError], [nil, MailerLite::EmptyIdError],
      ['123/html', MailerLite::InvalidIdError], ['123%2Fhtml', MailerLite::InvalidIdError],
      ["123\n", MailerLite::InvalidIdError], ['²', MailerLite::InvalidIdError], ['١٢', MailerLite::InvalidIdError],
      [-5, MailerLite::InvalidIdError], [(+"12\xFF").force_encoding('UTF-8'), MailerLite::InvalidIdError],
      [true, TypeError], [1.5, TypeError]
    ]
  end

  def expect_invalid_ids(name)
    invalid_ids.each do |value, error|
      expect { yield value }.to raise_error(error, /`#{name}`/)
    end
    expect(a_request(:any, /.*/)).not_to have_been_made
  end

  describe 'constants' do
    it 'has the values of the API' do
      expect(described_class::VERSION_CONFLICT).to eq 'version_conflict'
      block_types = described_class::BlockType
      expect([block_types::BLOCKQUOTE, block_types::BULLETED_LIST, block_types::BUTTON, block_types::CODE,
              block_types::DIVIDER, block_types::HEADING, block_types::IMAGE, block_types::NUMBERED_LIST,
              block_types::PARAGRAPH, block_types::SOCIAL_ICON, block_types::TITLE, block_types::VIDEO])
        .to eq %w[blockquote bulleted_list button code divider heading image numbered_list paragraph social_icon title video]
      positions = described_class::BlockPosition
      expect([positions::AT_START, positions::AT_END, positions::BEFORE, positions::AFTER]).to eq %w[start end before after]
      modes = described_class::BrandMode
      expect([modes::ACCOUNT, modes::TEMPLATE, modes::CUSTOM]).to eq %w[account template custom]
    end
  end

  describe '#get' do
    it 'gets the email' do
      stub = stub_api(:get, '/emails/123', response: load_fixture('email'))

      response = emails.get('123')

      expect(stub).to have_been_requested
      expect(response).to be_a(HTTP::Response)
      expect(response.code).to eq 200
      data = decoded(response)
      expect(data['etag']).to eq '42'
      expect(data['data']['id']).to eq '123'
      expect(data['data']['type']).to eq 'builder_inline_email'
      expect(data['data']['emailable_type']).to eq 'campaigns'
      expect(data['data']['settings']['brand']['mode']).to eq 'account'
      expect(data['data']['settings']['footer']['show_preferences']).to be(false)
      expect(data['data']['settings']['footer']['social_links'][0]['link_id']).to eq 7
      expect(data['data']['blocks'][0]['editor_content']['attrs']['textAlign']).to eq 'left'
      expect(data['data']['blocks'][1]['children'][0]['id']).to eq '3'
    end

    it 'accepts an Integer ID' do
      stub = stub_api(:get, '/emails/123', response: load_fixture('email'))

      emails.get(123)

      expect(stub).to have_been_requested
    end

    it 'returns the error response and does not raise' do
      stub_api(:get, '/emails/123', status: 404, response: { message: 'Resource not found.' })

      response = emails.get('123')

      expect(response).to be_a(HTTP::Response)
      expect(response.code).to eq 404
      expect(response.api_error.api_message).to eq 'Resource not found.'
    end

    it 'checks the email ID and sends no request' do
      expect_invalid_ids('email_id') { |id| emails.get(id) }
    end
  end

  describe '#get_html' do
    it 'gets the HTML of the email' do
      stub = stub_api(:get, '/emails/123/html', response: load_fixture('email_html'))

      response = emails.get_html('123')

      expect(stub).to have_been_requested
      data = decoded(response)
      expect(data['data']['html']).to eq '<!doctype html><html><body><p>Hello</p></body></html>'
      expect(data['etag']).to eq '42'
    end

    it 'returns a 503 with an HTML body and does not raise' do
      stub_request(:get, "#{MAILERLITE_API_URL}/emails/123/html")
        .to_return(status: 503, body: '<html><body>Service Unavailable</body></html>', headers: { 'Content-Type' => 'text/html' })

      response = emails.get_html('123')

      expect(response.code).to eq 503
      expect(response.api_error.status).to eq 503
      expect(response.api_error.api_message).to be_nil
    end

    it 'checks the email ID and sends no request' do
      expect_invalid_ids('email_id') { |id| emails.get_html(id) }
    end
  end

  describe '#get_block' do
    it 'gets the block and its placement' do
      stub = stub_api(:get, '/emails/123/blocks/57', response: load_fixture('email_block'))

      response = emails.get_block(email_id: '123', block_id: 57)

      expect(stub).to have_been_requested
      data = decoded(response)
      expect(data['etag']).to eq '43'
      expect(data['data']['id']).to eq '57'
      expect(data['data']['type']).to eq 'paragraph'
      expect(data['data']['editor_content']['attrs']['textAlign']).to eq 'left'
      expect(data['data']['placement']['after']).to eq '56'
      expect(data['data']['placement']).to have_key('before')
      expect(data['data']['placement']['before']).to be_nil
    end

    it 'checks the IDs and sends no request' do
      expect_invalid_ids('email_id') { |id| emails.get_block(email_id: id, block_id: '57') }
      expect_invalid_ids('block_id') { |id| emails.get_block(email_id: '123', block_id: id) }
    end
  end

  describe '#create_block' do
    let(:content) { { attrs: { textAlign: 'center' }, content: [{ type: 'text', text: 'Hi' }] } }

    it 'inserts the block with the placement and the etag' do
      body = '{"type":"paragraph","editor_content":{"attrs":{"textAlign":"center"},"content":[{"type":"text","text":"Hi"}]},' \
             '"placement":{"position":"after","block_id":"57"},"etag":"42"}'
      stub = stub_api(:post, '/emails/123/blocks', body: body, status: 201, response: load_fixture('email_block_created'))
      placement = { position: described_class::BlockPosition::AFTER, block_id: 57 }

      response = emails.create_block(email_id: '123', etag: '42', type: described_class::BlockType::PARAGRAPH,
                                     editor_content: content, placement: placement)

      expect(stub).to have_been_requested
      expect(response.code).to eq 201
      data = decoded(response)
      expect(data['etag']).to eq '43'
      expect(data['data']['id']).to eq '58'
      expect(data['data']['editor_content']['attrs']['textAlign']).to eq 'center'
      expect(data['data']['placement']['after']).to eq '57'
      expect(placement).to eq(position: 'after', block_id: 57)
    end

    it 'sends no placement without a placement, and accepts empty content' do
      stub = stub_api(:post, '/emails/123/blocks', body: '{"type":"divider","editor_content":{},"etag":"42"}',
                                                   status: 201, response: load_fixture('email_block_created'))

      emails.create_block(email_id: 123, etag: '42', type: 'divider', editor_content: {})

      expect(stub).to have_been_requested
    end

    it 'returns a version conflict with the code and the current etag' do
      stub_api(:post, '/emails/123/blocks', body: '{"type":"divider","editor_content":{},"etag":"41"}', status: 409,
                                            response: { message: 'The email was changed.', code: 'version_conflict', etag: '42' })

      response = emails.create_block(email_id: '123', etag: '41', type: 'divider', editor_content: {})

      expect(response.code).to eq 409
      expect(response.api_error.status).to eq 409
      expect(response.api_error.code).to eq described_class::VERSION_CONFLICT
      expect(response.api_error.etag).to eq '42'
    end

    it 'returns the field errors of a 422' do
      stub_api(:post, '/emails/123/blocks', body: '{"type":"title","editor_content":{},"etag":"42"}', status: 422,
                                            response: { message: 'The selected type is invalid.', errors: { type: ['The selected type is invalid.'] } })

      response = emails.create_block(email_id: '123', etag: '42', type: 'title', editor_content: {})

      expect(response.api_error.errors).to eq('type' => ['The selected type is invalid.'])
    end

    it 'checks the email ID and the block_id of the placement, and sends no request' do
      expect_invalid_ids('email_id') { |id| emails.create_block(email_id: id, etag: '42', type: 'divider', editor_content: {}) }
      expect_invalid_ids('block_id') do |id|
        emails.create_block(email_id: '123', etag: '42', type: 'divider', editor_content: {}, placement: { position: 'after', block_id: id })
      end
      expect_invalid_ids('block_id') do |id|
        emails.create_block(email_id: '123', etag: '42', type: 'divider', editor_content: {}, placement: { 'position' => 'after', 'block_id' => id })
      end
    end

    it 'checks the etag and the types, and sends no request' do
      expect { emails.create_block(email_id: '123', etag: '', type: 'divider', editor_content: {}) }.to raise_error(MailerLite::EmptyEtagError)
      expect { emails.create_block(email_id: '123', etag: nil, type: 'divider', editor_content: {}) }.to raise_error(MailerLite::EmptyEtagError)
      expect { emails.create_block(email_id: '123', etag: 42, type: 'divider', editor_content: {}) }.to raise_error(TypeError, /`etag`/)
      expect { emails.create_block(email_id: '123', etag: '42', type: 1, editor_content: {}) }.to raise_error(TypeError, /`type`/)
      expect { emails.create_block(email_id: '123', etag: '42', type: 'divider', editor_content: nil) }.to raise_error(TypeError, /`editor_content`/)
      expect { emails.create_block(email_id: '123', etag: '42', type: 'divider', editor_content: {}, placement: 'end') }
        .to raise_error(TypeError, /`placement`/)
      expect(a_request(:any, /.*/)).not_to have_been_made
    end
  end

  describe '#update_block' do
    it 'sends a PATCH request with the content and the etag' do
      body = '{"editor_content":{"content":[{"type":"text","text":"Hello again"}]},"etag":"43"}'
      stub = stub_api(:patch, '/emails/123/blocks/57', body: body, response: load_fixture('email_block_updated'))

      response = emails.update_block(email_id: '123', block_id: '57', etag: '43',
                                     editor_content: { content: [{ type: 'text', text: 'Hello again' }] })

      expect(stub).to have_been_requested
      data = decoded(response)
      expect(data['etag']).to eq '44'
      expect(data['data']['editor_content']['content'][0]['text']).to eq 'Hello again'
      expect(data['data']['placement']).to eq('after' => '56', 'before' => '58')
    end

    it 'checks the arguments and sends no request' do
      expect_invalid_ids('email_id') { |id| emails.update_block(email_id: id, block_id: '57', etag: '43', editor_content: {}) }
      expect_invalid_ids('block_id') { |id| emails.update_block(email_id: '123', block_id: id, etag: '43', editor_content: {}) }
      expect { emails.update_block(email_id: '123', block_id: '57', etag: '', editor_content: {}) }.to raise_error(MailerLite::EmptyEtagError)
      expect { emails.update_block(email_id: '123', block_id: '57', etag: '43', editor_content: []) }
        .to raise_error(TypeError, /`editor_content`/)
      expect(a_request(:any, /.*/)).not_to have_been_made
    end
  end

  describe '#delete_block' do
    it 'sends a DELETE request with the etag in the body, and returns the new etag' do
      stub = stub_api(:delete, '/emails/123/blocks/57', body: '{"etag":"44"}', response: load_fixture('email_etag'))

      response = emails.delete_block(email_id: '123', block_id: '57', etag: '44')

      expect(stub).to have_been_requested
      expect(response).to be_a(HTTP::Response)
      expect(decoded(response)).to eq('etag' => '45')
    end

    it 'checks the arguments and sends no request' do
      expect_invalid_ids('email_id') { |id| emails.delete_block(email_id: id, block_id: '57', etag: '44') }
      expect_invalid_ids('block_id') { |id| emails.delete_block(email_id: '123', block_id: id, etag: '44') }
      expect { emails.delete_block(email_id: '123', block_id: '57', etag: nil) }.to raise_error(MailerLite::EmptyEtagError)
      expect(a_request(:any, /.*/)).not_to have_been_made
    end
  end

  describe '#move_block' do
    it 'sends the placement and the etag' do
      stub = stub_api(:post, '/emails/123/blocks/57/move', body: '{"placement":{"position":"before","block_id":"1"},"etag":"45"}',
                                                           response: load_fixture('email_block_moved'))

      response = emails.move_block(email_id: '123', block_id: '57', etag: '45',
                                   placement: { 'position' => described_class::BlockPosition::BEFORE, 'block_id' => 1 })

      expect(stub).to have_been_requested
      data = decoded(response)
      expect(data['etag']).to eq '46'
      expect(data['data']['placement']).to have_key('after')
      expect(data['data']['placement']['after']).to be_nil
      expect(data['data']['placement']['before']).to eq '1'
    end

    it 'sends a placement without a block_id' do
      stub = stub_api(:post, '/emails/123/blocks/57/move', body: '{"placement":{"position":"start"},"etag":"45"}',
                                                           response: load_fixture('email_block_moved'))

      emails.move_block(email_id: '123', block_id: '57', etag: '45', placement: { position: described_class::BlockPosition::AT_START })

      expect(stub).to have_been_requested
    end

    it 'checks the arguments and sends no request' do
      expect_invalid_ids('email_id') { |id| emails.move_block(email_id: id, block_id: '57', etag: '45', placement: { position: 'end' }) }
      expect_invalid_ids('block_id') { |id| emails.move_block(email_id: '123', block_id: id, etag: '45', placement: { position: 'end' }) }
      expect_invalid_ids('block_id') do |id|
        emails.move_block(email_id: '123', block_id: '57', etag: '45', placement: { position: 'after', block_id: id })
      end
      expect_invalid_ids('block_id') do |id|
        emails.move_block(email_id: '123', block_id: '57', etag: '45', placement: { 'position' => 'after', 'block_id' => id })
      end
      expect { emails.move_block(email_id: '123', block_id: '57', etag: '', placement: { position: 'end' }) }.to raise_error(MailerLite::EmptyEtagError)
      expect { emails.move_block(email_id: '123', block_id: '57', etag: '45', placement: nil) }.to raise_error(TypeError, /`placement`/)
      expect(a_request(:any, /.*/)).not_to have_been_made
    end
  end

  describe '#validate_block' do
    it 'sends the block without an etag and returns a valid result' do
      body = '{"type":"button","editor_content":{"attrs":{"href":"https://example.com"}},"placement":{"position":"end"}}'
      stub = stub_api(:post, '/emails/blocks/validate', body: body, response: load_fixture('email_block_validation_valid'))

      response = emails.validate_block(type: 'button', editor_content: { attrs: { href: 'https://example.com' } },
                                       placement: { position: described_class::BlockPosition::AT_END })

      expect(stub).to have_been_requested
      data = decoded(response)
      expect(data['valid']).to be(true)
      expect(data['errors']).to eq({})
      expect(data['schema']['version']).to eq '2.73.2'
    end

    it 'returns an invalid result as a 200 response' do
      stub = stub_api(:post, '/emails/blocks/validate', body: '{"type":"unknown","editor_content":{}}',
                                                        response: load_fixture('email_block_validation_invalid'))

      response = emails.validate_block(type: 'unknown', editor_content: {})

      expect(stub).to have_been_requested
      expect(response.api_error).to be_nil
      data = decoded(response)
      expect(data['valid']).to be(false)
      expect(data['errors']).to eq('type' => ['The selected type is invalid.'])
    end

    it 'checks the arguments and sends no request' do
      expect_invalid_ids('block_id') { |id| emails.validate_block(type: 'divider', editor_content: {}, placement: { position: 'after', block_id: id }) }
      expect { emails.validate_block(type: nil, editor_content: {}) }.to raise_error(TypeError, /`type`/)
      expect { emails.validate_block(type: 'divider', editor_content: 'x') }.to raise_error(TypeError, /`editor_content`/)
      expect(a_request(:any, /.*/)).not_to have_been_made
    end
  end
end
