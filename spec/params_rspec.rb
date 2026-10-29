# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailerLite::Params do
  describe 'error classes' do
    it 'makes the client-side errors subclasses of ArgumentError' do
      expect(MailerLite::EmptyIdError.ancestors).to include(ArgumentError)
      expect(MailerLite::InvalidIdError.ancestors).to include(ArgumentError)
      expect(MailerLite::EmptyEtagError.ancestors).to include(ArgumentError)
      expect(MailerLite::InvalidIdempotencyKeyError.ancestors).to include(ArgumentError)
    end

    it 'has a base error class for the SDK' do
      expect(MailerLite::Error.ancestors).to include(StandardError)
    end
  end

  describe '.path_id' do
    it 'returns a String of digits as it is' do
      expect(described_class.path_id('123', 'email_id')).to eq '123'
    end

    it 'returns an Integer as a String' do
      expect(described_class.path_id(123, 'email_id')).to eq '123'
    end

    it 'raises EmptyIdError for an empty String and for nil' do
      expect { described_class.path_id('', 'email_id') }.to raise_error(MailerLite::EmptyIdError, /`email_id`/)
      expect { described_class.path_id(nil, 'email_id') }.to raise_error(MailerLite::EmptyIdError, /`email_id`/)
    end

    ['123/html', '123%2Fhtml', "123\n", ' 123', '²', '١٢', '1.5', '-5'].each do |value|
      it "raises InvalidIdError for #{value.inspect}" do
        expect { described_class.path_id(value, 'block_id') }.to raise_error(MailerLite::InvalidIdError, /`block_id`/)
      end
    end

    it 'raises InvalidIdError for a negative Integer' do
      expect { described_class.path_id(-5, 'email_id') }.to raise_error(MailerLite::InvalidIdError)
    end

    it 'raises InvalidIdError for a String with invalid bytes' do
      value = (+"12\xFF").force_encoding('UTF-8')
      expect { described_class.path_id(value, 'email_id') }.to raise_error(MailerLite::InvalidIdError)
    end

    it 'raises InvalidIdError for a String in an encoding that is not ASCII compatible' do
      expect { described_class.path_id('12'.encode('UTF-16LE'), 'email_id') }.to raise_error(MailerLite::InvalidIdError)
    end

    [true, false, 1.5, :'123', ['1']].each do |value|
      it "raises TypeError for #{value.inspect}" do
        expect { described_class.path_id(value, 'email_id') }.to raise_error(TypeError, /`email_id`/)
      end
    end
  end

  describe '.etag' do
    it 'returns the etag' do
      expect(described_class.etag('42')).to eq '42'
    end

    it 'raises EmptyEtagError for an empty String and for nil' do
      expect { described_class.etag('') }.to raise_error(MailerLite::EmptyEtagError)
      expect { described_class.etag(nil) }.to raise_error(MailerLite::EmptyEtagError)
    end

    it 'raises TypeError for a value that is not a String' do
      expect { described_class.etag(42) }.to raise_error(TypeError, /`etag`/)
    end
  end

  describe '.require_hash' do
    it 'returns the Hash' do
      value = { 'a' => 1 }
      expect(described_class.require_hash(value, 'settings')).to be value
    end

    [nil, 'image', [], 1].each do |value|
      it "raises TypeError for #{value.inspect}" do
        expect { described_class.require_hash(value, 'filter') }.to raise_error(TypeError, /`filter`/)
      end
    end
  end

  describe '.require_string' do
    it 'returns the String' do
      expect(described_class.require_string('paragraph', 'type')).to eq 'paragraph'
    end

    [nil, 1, :paragraph].each do |value|
      it "raises TypeError for #{value.inspect}" do
        expect { described_class.require_string(value, 'type') }.to raise_error(TypeError, /`type`/)
      end
    end
  end

  describe '.placement' do
    it 'returns the placement with String keys' do
      expect(described_class.placement({ position: 'end' })).to eq('position' => 'end')
    end

    it 'sends an Integer block_id as a String' do
      expect(described_class.placement({ position: 'after', block_id: 57 }))
        .to eq('position' => 'after', 'block_id' => '57')
    end

    it 'accepts a String key for block_id' do
      expect(described_class.placement({ 'position' => 'before', 'block_id' => '57' }))
        .to eq('position' => 'before', 'block_id' => '57')
    end

    it 'does not change the Hash of the caller' do
      placement = { position: 'after', block_id: 57 }
      described_class.placement(placement)
      expect(placement).to eq(position: 'after', block_id: 57)
    end

    [:block_id, 'block_id'].each do |key|
      it "checks the block_id with a #{key.class} key" do
        expect { described_class.placement({ position: 'after', key => '' }) }.to raise_error(MailerLite::EmptyIdError)
        expect { described_class.placement({ position: 'after', key => nil }) }.to raise_error(MailerLite::EmptyIdError)
        expect { described_class.placement({ position: 'after', key => '1/2' }) }.to raise_error(MailerLite::InvalidIdError)
        expect { described_class.placement({ position: 'after', key => "1\n" }) }.to raise_error(MailerLite::InvalidIdError)
        expect { described_class.placement({ position: 'after', key => true }) }.to raise_error(TypeError)
      end
    end

    it 'raises ArgumentError when a key is there as a Symbol and as a String' do
      expect { described_class.placement({ block_id: '1', 'block_id' => '2' }) }.to raise_error(ArgumentError, /block_id/)
      expect { described_class.placement({ position: 'end', 'position' => 'start' }) }.to raise_error(ArgumentError, /position/)
    end

    it 'raises TypeError for a placement that is not a Hash' do
      expect { described_class.placement('end') }.to raise_error(TypeError, /`placement`/)
    end
  end

  describe '.settings' do
    it 'returns the settings' do
      settings = { brand: { mode: 'account' } }
      expect(described_class.settings(settings)).to eq settings
    end

    it 'raises ArgumentError for an etag key' do
      expect { described_class.settings({ etag: '1' }) }.to raise_error(ArgumentError, /etag/)
      expect { described_class.settings({ 'etag' => '1' }) }.to raise_error(ArgumentError, /etag/)
    end

    it 'raises TypeError for settings that are not a Hash' do
      expect { described_class.settings(nil) }.to raise_error(TypeError, /`settings`/)
    end
  end

  describe '.query' do
    it 'returns an empty Hash with no values' do
      expect(described_class.query).to eq({})
    end

    it 'adds a filter[key] value for each filter key' do
      expect(described_class.query(filter: { name: 'summer sale', type: 'image' }, sort: '-size'))
        .to eq('filter[name]' => 'summer sale', 'filter[type]' => 'image', 'sort' => '-size')
    end

    it 'drops nil values, also in the filter' do
      expect(described_class.query(filter: { name: nil, type: 'pdf' }, page: nil, limit: 10))
        .to eq('filter[type]' => 'pdf', 'limit' => 10)
    end

    it 'keeps empty String values' do
      expect(described_class.query(filter: { type: '' }, sort: ''))
        .to eq('filter[type]' => '', 'sort' => '')
    end

    it 'raises TypeError for a filter that is not a Hash' do
      expect { described_class.query(filter: 'image') }.to raise_error(TypeError, /`filter`/)
    end
  end

  describe '.idempotency_headers' do
    it 'returns no headers without a key' do
      expect(described_class.idempotency_headers(nil)).to eq({})
    end

    it 'returns the header for a valid key' do
      expect(described_class.idempotency_headers('key-1')).to eq('Idempotency-Key' => 'key-1')
    end

    it 'accepts a key with 255 characters and a space in the middle' do
      expect(described_class.idempotency_headers('a' * 255)).to eq('Idempotency-Key' => 'a' * 255)
      expect(described_class.idempotency_headers('a b')).to eq('Idempotency-Key' => 'a b')
    end

    ['', 'a' * 256, "a\nb", "a\tb", 'é', "\x7F", ' k', 'k ', (+"k\xFF").force_encoding('UTF-8')].each do |key|
      it "raises InvalidIdempotencyKeyError for #{key.inspect[0, 20]}" do
        expect { described_class.idempotency_headers(key) }.to raise_error(MailerLite::InvalidIdempotencyKeyError)
      end
    end

    it 'raises TypeError for a key that is not a String' do
      expect { described_class.idempotency_headers(1) }.to raise_error(TypeError, /`idempotency_key`/)
    end
  end
end
