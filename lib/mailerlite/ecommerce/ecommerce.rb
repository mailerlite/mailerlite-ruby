# frozen_string_literal: true

module MailerLite
  # Classes for manipulating e-commerce data from MailerLite API.
  module Ecommerce
    # Shared setup for the e-commerce classes.
    class Resource
      attr_reader :client

      # Inits the class with the specified `client`.
      #
      # @param client [MailerLite::Client] the `Client` instance to use
      def initialize(client: MailerLite::Client.new)
        @client = client
      end

      private

      def shop_url(shop_id, path = '')
        "#{MAILERLITE_API_URL}/ecommerce/shops/#{shop_id}#{path}"
      end

      def get_with_query(url, filter: {}, **params)
        query = filter.to_h { |key, value| ["filter[#{key}]", value] }.merge(params.transform_keys(&:to_s)).compact
        uri = URI(url)
        uri.query = URI.encode_www_form(query) unless query.empty?
        client.http.get(uri)
      end
    end

    # Shops from MailerLite API.
    class Shops < Resource
      # @return [HTTP::Response] the response from the API
      def list(page: nil, limit: nil)
        get_with_query("#{MAILERLITE_API_URL}/ecommerce/shops", page: page, limit: limit)
      end

      # @param shop_id [String] the ID of the shop
      # @return [HTTP::Response] the response from the API
      def get(shop_id)
        client.http.get(shop_url(shop_id))
      end

      # @param params [Hash] name, url and currency are required
      # @return [HTTP::Response] the response from the API
      def create(params)
        client.http.post("#{MAILERLITE_API_URL}/ecommerce/shops", json: params)
      end

      # @return [HTTP::Response] the response from the API
      def update(shop_id:, params:)
        client.http.put(shop_url(shop_id), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def delete(shop_id)
        client.http.delete(shop_url(shop_id))
      end

      # @param start_date [String] the first day, e.g. 2026-01-01
      # @param end_date [String] the last day, included
      # @return [HTTP::Response] the response from the API
      def stats(shop_id:, start_date:, end_date:)
        get_with_query(shop_url(shop_id, '/reports/stats'), start_date: start_date, end_date: end_date)
      end
    end

    # Products from MailerLite API.
    class Products < Resource
      # @param filter [Hash] name, type, enabled, category or exclude_from_automations
      # @return [HTTP::Response] the response from the API
      def list(shop_id:, filter: {}, sort: nil, page: nil, limit: nil)
        get_with_query(shop_url(shop_id, '/products'), filter: filter, sort: sort, page: page, limit: limit)
      end

      # @return [HTTP::Response] the response from the API
      def get(shop_id:, product_id:)
        client.http.get(shop_url(shop_id, "/products/#{product_id}"))
      end

      # @return [HTTP::Response] the response from the API
      def create(shop_id:, params:)
        client.http.post(shop_url(shop_id, '/products'), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def update(shop_id:, product_id:, params:)
        client.http.put(shop_url(shop_id, "/products/#{product_id}"), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def delete(shop_id:, product_id:)
        client.http.delete(shop_url(shop_id, "/products/#{product_id}"))
      end

      # @param enabled [Boolean] whether the product is enabled
      # @return [HTTP::Response] the response from the API
      def change_status(shop_id:, product_id:, enabled:)
        client.http.put(shop_url(shop_id, "/products/#{product_id}/change-status"), json: { status: enabled })
      end

      # @param replace [Boolean] also remove the categories that are not listed
      # @return [HTTP::Response] the response from the API
      def assign_categories(shop_id:, product_id:, category_ids:, replace: false)
        client.http.put(shop_url(shop_id, "/products/#{product_id}/categories/multiple"), json: { categories: category_ids, replace: replace })
      end
    end

    # Product variants from MailerLite API.
    class ProductVariants < Resource
      # @return [HTTP::Response] the response from the API
      def list(shop_id:, product_id:)
        client.http.get(shop_url(shop_id, "/products/#{product_id}/variants"))
      end

      # @param variants [Array<Hash>] name and attributes are required
      # @return [HTTP::Response] the response from the API
      def sync(shop_id:, product_id:, variants:)
        client.http.post(shop_url(shop_id, "/products/#{product_id}/variants"), json: variants)
      end

      # @return [HTTP::Response] the response from the API
      def update(shop_id:, product_id:, variant_id:, params:)
        client.http.put(shop_url(shop_id, "/products/#{product_id}/variants/#{variant_id}"), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def delete(shop_id:, product_id:, variant_id:)
        client.http.delete(shop_url(shop_id, "/products/#{product_id}/variants/#{variant_id}"))
      end
    end

    # Categories from MailerLite API.
    class Categories < Resource
      # @return [HTTP::Response] the response from the API
      def list(shop_id:, filter: {}, page: nil, limit: nil)
        get_with_query(shop_url(shop_id, '/categories'), filter: filter, page: page, limit: limit)
      end

      # @return [HTTP::Response] the response from the API
      def get(shop_id:, category_id:)
        client.http.get(shop_url(shop_id, "/categories/#{category_id}"))
      end

      # @return [HTTP::Response] the response from the API
      def create(shop_id:, params:)
        client.http.post(shop_url(shop_id, '/categories'), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def update(shop_id:, category_id:, params:)
        client.http.put(shop_url(shop_id, "/categories/#{category_id}"), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def delete(shop_id:, category_id:)
        client.http.delete(shop_url(shop_id, "/categories/#{category_id}"))
      end

      # @return [HTTP::Response] the response from the API
      def products(shop_id:, category_id:, page: nil, limit: nil)
        get_with_query(shop_url(shop_id, "/categories/#{category_id}/products"), page: page, limit: limit)
      end

      # @return [HTTP::Response] the response from the API
      def assign_product(shop_id:, category_id:, product_id:)
        client.http.put(shop_url(shop_id, "/categories/#{category_id}/products/#{product_id}"))
      end

      # @return [HTTP::Response] the response from the API
      def unassign_product(shop_id:, category_id:, product_id:)
        client.http.delete(shop_url(shop_id, "/categories/#{category_id}/products/#{product_id}"))
      end
    end

    # Customers from MailerLite API.
    class Customers < Resource
      # @param filter [Hash] email
      # @return [HTTP::Response] the response from the API
      def list(shop_id:, filter: {}, sort: nil, page: nil, limit: nil)
        get_with_query(shop_url(shop_id, '/customers'), filter: filter, sort: sort, page: page, limit: limit)
      end

      # @return [HTTP::Response] the response from the API
      def get(shop_id:, customer_id:)
        client.http.get(shop_url(shop_id, "/customers/#{customer_id}"))
      end

      # @return [HTTP::Response] the response from the API
      def create(shop_id:, params:)
        client.http.post(shop_url(shop_id, '/customers'), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def update(shop_id:, customer_id:, params:)
        client.http.put(shop_url(shop_id, "/customers/#{customer_id}"), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def delete(shop_id:, customer_id:)
        client.http.delete(shop_url(shop_id, "/customers/#{customer_id}"))
      end
    end

    # Orders from MailerLite API.
    class Orders < Resource
      # @param filter [Hash] status, customer, attributed or email_id
      # @return [HTTP::Response] the response from the API
      def list(shop_id:, filter: {}, sort: nil, page: nil, limit: nil)
        get_with_query(shop_url(shop_id, '/orders'), filter: filter, sort: sort, page: page, limit: limit)
      end

      # @return [HTTP::Response] the response from the API
      def get(shop_id:, order_id:)
        client.http.get(shop_url(shop_id, "/orders/#{order_id}"))
      end

      # @param params [Hash] customer and cart are required
      # @return [HTTP::Response] the response from the API
      def create(shop_id:, params:)
        client.http.post(shop_url(shop_id, '/orders'), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def update(shop_id:, order_id:, params:)
        client.http.put(shop_url(shop_id, "/orders/#{order_id}"), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def delete(shop_id:, order_id:)
        client.http.delete(shop_url(shop_id, "/orders/#{order_id}"))
      end
    end

    # Carts from MailerLite API.
    class Carts < Resource
      # @return [HTTP::Response] the response from the API
      def list(shop_id:, page: nil, limit: nil)
        get_with_query(shop_url(shop_id, '/carts'), page: page, limit: limit)
      end

      # @return [HTTP::Response] the response from the API
      def get(shop_id:, cart_id:)
        client.http.get(shop_url(shop_id, "/carts/#{cart_id}"))
      end

      # @return [HTTP::Response] the response from the API
      def update(shop_id:, cart_id:, params:)
        client.http.put(shop_url(shop_id, "/carts/#{cart_id}"), json: params)
      end
    end

    # Cart items from MailerLite API.
    class CartItems < Resource
      # @return [HTTP::Response] the response from the API
      def list(shop_id:, cart_id:, page: nil, limit: nil)
        get_with_query(shop_url(shop_id, "/carts/#{cart_id}/items"), page: page, limit: limit)
      end

      # @return [HTTP::Response] the response from the API
      def get(shop_id:, cart_id:, item_id:)
        client.http.get(shop_url(shop_id, "/carts/#{cart_id}/items/#{item_id}"))
      end

      # @return [HTTP::Response] the response from the API
      def create(shop_id:, cart_id:, params:)
        client.http.post(shop_url(shop_id, "/carts/#{cart_id}/items"), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def update(shop_id:, cart_id:, item_id:, params:)
        client.http.put(shop_url(shop_id, "/carts/#{cart_id}/items/#{item_id}"), json: params)
      end

      # @return [HTTP::Response] the response from the API
      def delete(shop_id:, cart_id:, item_id:)
        client.http.delete(shop_url(shop_id, "/carts/#{cart_id}/items/#{item_id}"))
      end
    end

    # Bulk imports from MailerLite API.
    class Imports < Resource
      # @param products [Array<Hash>] the products to import
      # @return [HTTP::Response] the response from the API
      def products(shop_id:, products:)
        client.http.post(shop_url(shop_id, '/products/import'), json: products)
      end

      # @param categories [Array<Hash>] the categories to import
      # @return [HTTP::Response] the response from the API
      def categories(shop_id:, categories:)
        client.http.post(shop_url(shop_id, '/categories/import'), json: categories)
      end

      # @param customers [Array<Hash>] the customers to import
      # @return [HTTP::Response] the response from the API
      def customers(shop_id:, customers:)
        client.http.post(shop_url(shop_id, '/customers/import'), json: customers)
      end

      # @param orders [Array<Hash>] the orders to import
      # @return [HTTP::Response] the response from the API
      def orders(shop_id:, orders:)
        client.http.post(shop_url(shop_id, '/orders/import'), json: { orders: orders })
      end
    end

    # E-commerce tracking settings from MailerLite API.
    class Settings < Resource
      # @return [HTTP::Response] the response from the API
      def get
        client.http.get("#{MAILERLITE_API_URL}/ecommerce/settings")
      end
    end
  end
end
