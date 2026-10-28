# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'json'

RSpec.describe MailerLite::Ecommerce do
  let(:client) { MailerLite::Client.new }
  let(:api) { MAILERLITE_API_URL }
  let(:shop) { "#{MAILERLITE_API_URL}/ecommerce/shops/1" }
  let(:variant) { { name: 'Large', attributes: { size: 'L' } } }

  def expect_request(method, url, body: nil)
    stub = stub_request(method, url)
    stub = stub.with(body: body.to_json) if body
    stub.to_return(status: 200, body: '{}')
    yield
    expect(stub).to have_been_requested
  end

  it 'calls the shop endpoints' do
    shops = MailerLite::Ecommerce::Shops.new(client: client)

    expect_request(:get, "#{api}/ecommerce/shops?limit=10") { shops.list(limit: 10) }
    expect_request(:get, shop) { shops.get('1') }
    expect_request(:post, "#{api}/ecommerce/shops", body: { name: 'Shop' }) { shops.create({ name: 'Shop' }) }
    expect_request(:put, shop, body: { name: 'New' }) { shops.update(shop_id: '1', params: { name: 'New' }) }
    expect_request(:delete, shop) { shops.delete('1') }
    expect_request(:get, "#{shop}/reports/stats?start_date=2026-10-01&end_date=2026-10-31") do
      shops.stats(shop_id: '1', start_date: '2026-10-01', end_date: '2026-10-31')
    end
  end

  it 'calls the product and variant endpoints' do
    products = MailerLite::Ecommerce::Products.new(client: client)
    variants = MailerLite::Ecommerce::ProductVariants.new(client: client)

    expect_request(:get, "#{shop}/products?filter%5Benabled%5D=true&sort=-name") do
      products.list(shop_id: '1', filter: { enabled: true }, sort: '-name')
    end
    expect_request(:get, "#{shop}/products/7") { products.get(shop_id: '1', product_id: '7') }
    expect_request(:post, "#{shop}/products", body: { name: 'Hat' }) { products.create(shop_id: '1', params: { name: 'Hat' }) }
    expect_request(:put, "#{shop}/products/7", body: { name: 'Cap' }) { products.update(shop_id: '1', product_id: '7', params: { name: 'Cap' }) }
    expect_request(:delete, "#{shop}/products/7") { products.delete(shop_id: '1', product_id: '7') }
    expect_request(:put, "#{shop}/products/7/change-status", body: { status: false }) do
      products.change_status(shop_id: '1', product_id: '7', enabled: false)
    end
    expect_request(:put, "#{shop}/products/7/categories/multiple", body: { categories: ['5'], replace: true }) do
      products.assign_categories(shop_id: '1', product_id: '7', category_ids: ['5'], replace: true)
    end

    expect_request(:get, "#{shop}/products/7/variants") { variants.list(shop_id: '1', product_id: '7') }
    expect_request(:post, "#{shop}/products/7/variants", body: [variant]) { variants.sync(shop_id: '1', product_id: '7', variants: [variant]) }
    expect_request(:put, "#{shop}/products/7/variants/3", body: variant) do
      variants.update(shop_id: '1', product_id: '7', variant_id: '3', params: variant)
    end
    expect_request(:delete, "#{shop}/products/7/variants/3") { variants.delete(shop_id: '1', product_id: '7', variant_id: '3') }
  end

  it 'calls the category endpoints' do
    categories = MailerLite::Ecommerce::Categories.new(client: client)

    expect_request(:get, "#{shop}/categories") { categories.list(shop_id: '1') }
    expect_request(:get, "#{shop}/categories/5") { categories.get(shop_id: '1', category_id: '5') }
    expect_request(:post, "#{shop}/categories", body: { name: 'Hats' }) { categories.create(shop_id: '1', params: { name: 'Hats' }) }
    expect_request(:put, "#{shop}/categories/5", body: { name: 'Caps' }) { categories.update(shop_id: '1', category_id: '5', params: { name: 'Caps' }) }
    expect_request(:delete, "#{shop}/categories/5") { categories.delete(shop_id: '1', category_id: '5') }
    expect_request(:get, "#{shop}/categories/5/products") { categories.products(shop_id: '1', category_id: '5') }
    expect_request(:put, "#{shop}/categories/5/products/7") { categories.assign_product(shop_id: '1', category_id: '5', product_id: '7') }
    expect_request(:delete, "#{shop}/categories/5/products/7") { categories.unassign_product(shop_id: '1', category_id: '5', product_id: '7') }
  end

  it 'calls the customer, order and cart endpoints' do
    customers = MailerLite::Ecommerce::Customers.new(client: client)
    orders = MailerLite::Ecommerce::Orders.new(client: client)
    carts = MailerLite::Ecommerce::Carts.new(client: client)
    items = MailerLite::Ecommerce::CartItems.new(client: client)

    expect_request(:get, "#{shop}/customers?filter%5Bemail%5D=a%40b.test") { customers.list(shop_id: '1', filter: { email: 'a@b.test' }) }
    expect_request(:get, "#{shop}/customers/3") { customers.get(shop_id: '1', customer_id: '3') }
    expect_request(:post, "#{shop}/customers", body: { email: 'a@b.test' }) { customers.create(shop_id: '1', params: { email: 'a@b.test' }) }
    expect_request(:put, "#{shop}/customers/3", body: { name: 'Jane' }) { customers.update(shop_id: '1', customer_id: '3', params: { name: 'Jane' }) }
    expect_request(:delete, "#{shop}/customers/3") { customers.delete(shop_id: '1', customer_id: '3') }

    expect_request(:get, "#{shop}/orders?filter%5Battributed%5D=true&filter%5Bemail_id%5D=55") do
      orders.list(shop_id: '1', filter: { attributed: true, email_id: '55' })
    end
    expect_request(:get, "#{shop}/orders/9") { orders.get(shop_id: '1', order_id: '9') }
    expect_request(:put, "#{shop}/orders/9", body: { status: 'complete' }) { orders.update(shop_id: '1', order_id: '9', params: { status: 'complete' }) }
    expect_request(:delete, "#{shop}/orders/9") { orders.delete(shop_id: '1', order_id: '9') }

    expect_request(:get, "#{shop}/carts") { carts.list(shop_id: '1') }
    expect_request(:get, "#{shop}/carts/4") { carts.get(shop_id: '1', cart_id: '4') }
    expect_request(:put, "#{shop}/carts/4", body: { cart_total: 10 }) { carts.update(shop_id: '1', cart_id: '4', params: { cart_total: 10 }) }
    expect_request(:get, "#{shop}/carts/4/items") { items.list(shop_id: '1', cart_id: '4') }
    expect_request(:get, "#{shop}/carts/4/items/8") { items.get(shop_id: '1', cart_id: '4', item_id: '8') }
    expect_request(:post, "#{shop}/carts/4/items", body: { ecommerce_product_id: '7' }) do
      items.create(shop_id: '1', cart_id: '4', params: { ecommerce_product_id: '7' })
    end
    expect_request(:put, "#{shop}/carts/4/items/8", body: { quantity: 2 }) { items.update(shop_id: '1', cart_id: '4', item_id: '8', params: { quantity: 2 }) }
    expect_request(:delete, "#{shop}/carts/4/items/8") { items.delete(shop_id: '1', cart_id: '4', item_id: '8') }
  end

  it 'calls the import and settings endpoints' do
    imports = MailerLite::Ecommerce::Imports.new(client: client)

    expect_request(:post, "#{shop}/products/import", body: [{ name: 'Hat' }]) { imports.products(shop_id: '1', products: [{ name: 'Hat' }]) }
    expect_request(:post, "#{shop}/categories/import", body: [{ name: 'Hats' }]) { imports.categories(shop_id: '1', categories: [{ name: 'Hats' }]) }
    expect_request(:post, "#{shop}/customers/import", body: [{ email: 'a@b.test' }]) { imports.customers(shop_id: '1', customers: [{ email: 'a@b.test' }]) }
    expect_request(:get, "#{api}/ecommerce/settings") { MailerLite::Ecommerce::Settings.new(client: client).get }
  end

  it 'calls the revenue report endpoints' do
    campaigns = MailerLite::Campaigns.new(client: client)
    subscribers = MailerLite::Subscribers.new(client: client)
    automations = MailerLite::Automations.new(client: client)

    expect_request(:get, "#{api}/campaigns/2/reports/ecommerce?shop_id=1") { campaigns.ecommerce_stats(campaign_id: '2', shop_id: '1') }
    expect_request(:get, "#{api}/campaigns/2/reports/ecommerce/orders?shop_id=1&page=2") { campaigns.ecommerce_orders(campaign_id: '2', shop_id: '1', page: 2) }
    expect_request(:get, "#{api}/subscribers/6/reports/ecommerce?shop_id=1") { subscribers.ecommerce_stats(subscriber_id: '6', shop_id: '1') }
    expect_request(:get, "#{api}/subscribers/6/reports/ecommerce/orders?shop_id=1") { subscribers.ecommerce_orders(subscriber_id: '6', shop_id: '1') }
    expect_request(:get, "#{api}/automations/8/monthly-totals/ecommerce") { automations.ecommerce_stats(automation_id: '8') }
    expect_request(:get, "#{api}/automations/8/emails/9/ecommerce-overview-stats?shop_id=1") do
      automations.email_ecommerce_stats(automation_id: '8', email_id: '9', shop_id: '1')
    end
    expect_request(:get, "#{api}/automations/8/order-activity?time_frame=all_time") { automations.ecommerce_orders(automation_id: '8', time_frame: 'all_time') }
  end
end
