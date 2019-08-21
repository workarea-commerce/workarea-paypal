require 'test_helper'

module Workarea
  module Storefront
    class PaypalIntengrationTest < Workarea::IntegrationTest
      delegate :gateway, to: Workarea::Paypal

      setup :stub_paypal_setup_redirect_url

      def test_start_starts_checkout_when_guest
        add_item_to_cart
        Workarea::Checkout.any_instance.expects(:start_as).with(:guest)
        get storefront.start_paypal_path
      end

      def test_start_starts_checkout_when_logged_in
        add_item_to_cart
        user = User.new

        Workarea::Storefront::PaypalController
          .any_instance
          .stubs(:current_user)
          .returns(user)

        Workarea::Checkout.any_instance.expects(:start_as).with(user)
        get storefront.start_paypal_path
      end

      def test_start_does_not_start_checkout_from_checkout
        add_item_to_cart
        Workarea::Checkout.any_instance.expects(:start_as).never

        get storefront.start_paypal_path, params: { from_checkout: 'from_checkout' }
      end

      def test_start_prices_the_order
        add_item_to_cart
        Workarea::Pricing.expects(:perform)

        get storefront.start_paypal_path
      end

      def test_start_uses_setup_to_redirect
        add_item_to_cart
        get storefront.start_paypal_path
        assert_redirected_to('http://paypal.com')
      end

      def test_start_redirects_to_cart_if_empty
        get storefront.start_paypal_path
        assert_redirected_to(storefront.cart_path)
      end

      def test_start_rdirects_to_cart_if_inventory_is_not_available
        product = create_product(variants: [{ sku: 'SKU', regular: 5 }])

        post storefront.cart_items_path, params: {
          product_id: product.id,
          sku: product.skus.first,
          quantity: 1
        }

        create_inventory(
          id: product.skus.first,
          policy: 'standard',
          available: 0
        )

        get storefront.start_paypal_path
        assert_redirected_to(storefront.cart_path)
      end

      def test_complete_sets_the_current_order
        add_item_to_cart
        stub_paypal_update_apply
        Workarea::Storefront::PaypalController
          .any_instance
          .expects(:current_order=)
        get storefront.complete_paypal_path(order_id: order.id)
      end

      def test_complete_applies_a_paupal_update
        add_item_to_cart
        Workarea::Paypal::Update
          .any_instance
          .expects(:apply)

        get storefront.complete_paypal_path(order_id: order.id)
      end

      def test_complete_redirects_to_checkout_path
        add_item_to_cart
        stub_paypal_update_apply
        Workarea::Checkout
          .any_instance
          .stubs(:complete?)
          .returns(true)
        get storefront.complete_paypal_path(order_id: order.id)
        assert_redirected_to(storefront.checkout_payment_path)
      end

      def test_complete_redirects_to_payment_as_purchasable
        shipping_method = create_shipping_service
        product = create_product(variants: [{ sku: 'SKU', regular: 49.to_m }])

        post storefront.cart_items_path, params: {
          product_id: product.id,
          sku: product.skus.first,
          quantity: 2
        }

        order = Workarea::Order.last

        Workarea::Shipping.find_or_create_by(id: order.id)
        Workarea::Payment.find_or_create_by(id: order.id)

        checkout = Workarea::Checkout.new(order)
        checkout.update(
          shipping_address: {
            first_name: 'Test',
            last_name: 'User',
            street: '1 Main St',
            street_2: nil,
            city: 'San Jose',
            region: 'CA',
            postal_code: '95131',
            country: 'US'
          },
          billing_address: {
            first_name: 'Test',
            last_name: 'User',
            street: '1 Main St',
            street_2: nil,
            city: 'San Jose',
            region: 'CA',
            postal_code: '95131',
            country: 'US'
          },
          shipping_method_id: shipping_method.id,
          payment: 'paypal'
        )

        gateway.expects(:details_for).returns(details)

        get storefront.complete_paypal_path(order_id: order.id)

        assert_redirected_to(storefront.checkout_payment_path)
      end

      def test_complete_redirects_to_address_if_paypal_address_invalid
        details.params['PaymentDetails']['ShipToAddress'] = {
          'Name' => 'Test User',
          'Street1' => 'PO Box 123',
          'Street2' => nil,
          'CityName' => 'San Jose',
          'StateOrProvince' => 'CA',
          'Country' => 'US',
          'CountryName' => 'United States',
          'Phone' => '610-867-5309',
          'PostalCode' => '95131',
          'AddressID' => nil,
          'AddressOwner' => 'PayPal',
          'ExternalAddressID' => nil,
          'AddressStatus' => 'Confirmed'
        }

        gateway.expects(:details_for).returns(details)

        product = create_product(variants: [{ sku: 'SKU', regular: 5 }])

        post storefront.cart_items_path, params: {
          product_id: product.id,
          sku: product.skus.first,
          quantity: 1
        }

        order = Order.first

        get storefront.complete_paypal_path(order_id: order.id)
        assert_redirected_to(storefront.checkout_addresses_path)
      end

      private

      def order
        @order ||= create_order
      end

      def product
        @product ||= create_product(
          variants: [{ sku: 'SKU1', regular: 6.to_m, tax_code: '001' }]
        )
      end

      def details
        @details ||= stub(
          email: 'bcrouse@workarea.com',
          token: 'EC-3LX76108SH791964A',
          payer_id: 'MDJZZYJ9SZJ52',
          params: {
            'timestamp' => '2012-02-16T15:22:17Z',
            'ack' => 'Success',
            'correlation_id' => 'e5e29daee048a',
            'version' => '62.0',
            'build' => '2571254',
            'token' => 'EC-3LX76108SH791964A',
            'payer' => 'bcrouse@workarea.com',
            'payer_id' => 'MDJZZYJ9SZJ52',
            'payer_status' => 'verified',
            'salutation' => nil,
            'first_name' => 'Test',
            'middle_name' => nil,
            'last_name' => 'User',
            'suffix' => nil,
            'payer_country' => 'US',
            'payer_business' => nil,
            'name' => 'Test Product 866',
            'street1' => '1 Main St',
            'street2' => nil,
            'city_name' => 'San Jose',
            'state_or_province' => 'CA',
            'country' => 'US',
            'country_name' => 'United States',
            'postal_code' => '95131',
            'address_owner' => 'PayPal',
            'address_status' => 'Confirmed',
            'order_total' => '98.00',
            'order_total_currency_id' => 'USD',
            'item_total' => '98.00',
            'item_total_currency_id' => 'USD',
            'shipping_total' => '0.00',
            'shipping_total_currency_id' => 'USD',
            'handling_total' => '0.00',
            'handling_total_currency_id' => 'USD',
            'tax_total' => '0.00',
            'tax_total_currency_id' => 'USD',
            'phone' => nil,
            'address_id' => nil,
            'external_address_id' => nil,
            'quantity' => '2',
            'tax' => '0.00',
            'tax_currency_id' => 'USD',
            'amount' => '49.00',
            'amount_currency_id' => 'USD',
            'ebay_item_payment_details_item' => nil,
            'insurance_total' => '0.00',
            'insurance_total_currency_id' => 'USD',
            'shipping_discount' => '0.00',
            'shipping_discount_currency_id' => 'USD',
            'insurance_option_offered' => 'false',
            'seller_details' => nil,
            'payment_request_id' => nil,
            'order_url' => nil,
            'soft_descriptor' => nil,
            'checkout_status' => 'PaymentActionNotInitiated',
            'Token' => 'EC-3LX76108SH791964A',
            'PayerInfo' => {
              'Payer' => 'bcrouse@workarea.com',
              'PayerID' => 'MDJZZYJ9SZJ52',
              'PayerStatus' => 'verified',
              'PayerName' => {
                'Salutation' => nil,
                'FirstName' => 'Test',
                'MiddleName' => nil,
                'LastName' => 'User',
                'Suffix' => nil
              },
              'PayerCountry' => 'US',
              'PayerBusiness' => nil,
              'Address' => {
                'Name' => 'Test User',
                'Street1' => '1 Main St',
                'Street2' => nil,
                'CityName' => 'San Jose',
                'StateOrProvince' => 'CA',
                'Country' => 'US',
                'CountryName' => 'United States',
                'PostalCode' => '95131',
                'AddressOwner' => 'PayPal',
                'AddressStatus' => 'Confirmed'
              }
            },
            'PaymentDetails' => {
              'OrderTotal' => '98.00',
              'ItemTotal' => '98.00',
              'ShippingTotal' => '0.00',
              'HandlingTotal' => '0.00',
              'TaxTotal' => '0.00',
              'ShipToAddress' => {
                'Name' => 'Test User',
                'Street1' => '1 Main St',
                'Street2' => nil,
                'CityName' => 'San Jose',
                'StateOrProvince' => 'CA',
                'Country' => 'US',
                'CountryName' => 'United States',
                'PostalCode' => '95131',
                'AddressID' => nil,
                'AddressOwner' => 'PayPal',
                'ExternalAddressID' => nil,
                'AddressStatus' => 'Confirmed'
              },
              'PaymentDetailsItem' => {
                'Name' => 'Test Product 866',
                'Quantity' => '2',
                'Tax' => '0.00',
                'Amount' => '49.00',
                'EbayItemPaymentDetailsItem' => nil
              },
              'InsuranceTotal' => '0.00',
              'ShippingDiscount' => '0.00',
              'InsuranceOptionOffered' => 'false',
              'SellerDetails' => nil,
              'PaymentRequestID' => nil,
              'OrderURL' => nil,
              'SoftDescriptor' => nil
            },
            'CheckoutStatus' => 'PaymentActionNotInitiated'
          }
        )
      end

      def add_item_to_cart
        post storefront.cart_items_path, params: {
          product_id: product.id,
          sku: product.skus.first,
          quantity: 2
        }
      end

      def stub_paypal_setup_redirect_url
        Workarea::Paypal::Setup
          .any_instance
          .stubs(:redirect_url)
          .returns('http://paypal.com')
      end

      def stub_paypal_update_apply
        Workarea::Paypal::Update
          .any_instance
          .stubs(:apply)
      end
    end
  end
end
