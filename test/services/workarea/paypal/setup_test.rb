require 'test_helper'

module Workarea
  class Paypal::SetupTest < Workarea::TestCase
    delegate :gateway, to: Workarea::Paypal

    def context
      @context ||= stub_everything(request: stub_everything)
    end

    def user
      @user ||= User.new
    end

    def address
      @address ||= Address.new(
        first_name:   'Ben',
        last_name:    'Crouse',
        street:       '22 S. 3rd St.',
        city:         'Philadelphia',
        region:       'PA',
        country:      'US',
        postal_code:  '19106',
        phone_number: '2159251800'
      )
    end

    def shipping
      @shipping ||= Shipping.new(address: address)
    end

    def order
      @order ||= create_order.tap do |order|
        product = create_product(
          variants: [{ sku: 'SKU1', regular: 5.to_m }]
        )

        create_order_total_discount(
          name: 'Test Order Discount',
          amount_type: :flat,
          amount: 3
        )
        order.add_item(
          product_id: product.id,
          sku: product.skus.first,
          quantity: 2
        )
        Pricing.perform(order)
        order.save!
      end
    end

    def setup
      @setup ||= Paypal::Setup.new(order, user, shipping, context)
    end

    def test_paypal_response_asks_the_paypal_gateway_to_setup_the_auth
      response = mock

      gateway
        .expects(:setup_authorization)
        .returns(response)

      assert_equal(response, setup.paypal_response)
    end

    def test_items_includes_order_items_and_discounts
      assert_equal([
        { name: nil, quantity: 2, amount: 650 },
        { name: 'Test Order Discount', quantity: 1, amount: -300 },
        { name: 'Test Order Discount', quantity: 1, amount: -300 }
      ], setup.items)

      assert_equal(700, setup.subtotal)
    end

    def test_shpping_address_uses_order_shipping_address_when_order_has_shipping_address
      assert_equal(
        {
          name:     'Ben Crouse',
          address1: '22 S. 3rd St.',
          address2: nil,
          city:     'Philadelphia',
          state:    'PA',
          country:  Country['US'],
          zip:      '19106',
          phone:    '2159251800'
        },
        setup.shipping_address
      )
    end

    def test_shipping_address_uses_the_users_default_shipping_address_when_no_shipping_address
      shipping.update_attributes!(address: nil)
      user.expects(:default_shipping_address).returns(address)

      assert_equal(
        {
          name:     'Ben Crouse',
          address1: '22 S. 3rd St.',
          address2: nil,
          city:     'Philadelphia',
          state:    'PA',
          country:  Country['US'],
          zip:      '19106',
          phone:    '2159251800'
        },
        setup.shipping_address
      )
    end

    def test_redirect_url_asks_the_paypal_gateway_for_the_redirect_url
      url = 'http://paypal.com'
      setup.expects(:paypal_response).returns(mock(token: '1243'))
      gateway.expects(:redirect_url_for).with('1243').returns(url)

      assert_equal(url, setup.redirect_url)
    end
  end
end
