# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailerLite::AutomationTemplates do
  let(:client) { MailerLite::Client.new }
  let(:templates) { described_class.new(client: client) }

  describe '#list' do
    it 'sends GET /automation-templates with the query' do
      stub = stub_api(:get, '/automation-templates', query: { 'filter[type]' => 'ecommerce', 'filter[category]' => '2', 'limit' => '10', 'page' => '3' })
      templates.list(filter: { type: 'ecommerce', category: 2 }, limit: 10, page: 3)
      expect(stub).to have_been_requested
    end
  end

  describe '#select_template' do
    it 'sends POST /automations/select-template/{automationTemplate}' do
      stub = stub_api(:post, '/automations/select-template/welcome')
      templates.select_template('welcome')
      expect(stub).to have_been_requested
    end
  end
end
