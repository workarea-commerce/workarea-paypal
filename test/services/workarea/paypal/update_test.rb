require 'test_helper'

module Workarea
  class Paypal::UpdateTest < Workarea::TestCase
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
              'Phone' => '610-867-5309',
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

    def token
      '1234'
    end

    def order
      @order ||= create_order.tap do |order|
        product = create_product
        order.add_item(product_id: product.id, sku: product.skus.first)
        Pricing.perform(order)
      end
    end

    def shipping
      @shipping ||= Shipping.new
    end

    def payment
      @payment ||= Payment.new
    end

    def update
      @update ||= Paypal::Update.new(order, payment, shipping, token)
    end

    setup :create_shipping_service
    setup { Paypal.gateway.stubs(:details_for).returns(details) }
    setup { update.apply }

    def test_when_order_has_no_email_sets_order_email
      assert_equal('bcrouse@workarea.com', order.email)
    end

    def test_when_order_has_an_email_does_not_update_the_order_email
      order.email = 'orderemail@workarea.com'
      assert_equal('orderemail@workarea.com', order.email)
    end

    def test_sets_order_shipping_address
      assert_equal('Test', shipping.address.first_name)
      assert_equal('User', shipping.address.last_name)
      assert_equal('1 Main St', shipping.address.street)
      assert_equal('San Jose', shipping.address.city)
      assert_equal('CA', shipping.address.region)
      assert_equal(Country['US'], shipping.address.country)
      assert_equal('95131', shipping.address.postal_code)
    end

    def test_sets_order_shipping_method
      refute_nil(shipping.shipping_service)
    end

    def test_sets_payment_address
      assert_equal('Test', payment.address.first_name)
      assert_equal('User', payment.address.last_name)
      assert_equal('1 Main St', payment.address.street)
      assert_equal('San Jose', payment.address.city)
      assert_equal('CA', payment.address.region)
      assert_equal(Country['US'], payment.address.country)
      assert_equal('95131', payment.address.postal_code)
    end

    def test_sets_a_paypal_payment
      assert(payment.paypal?)
      assert_equal('EC-3LX76108SH791964A', payment.paypal.token)
      assert_equal('MDJZZYJ9SZJ52', payment.paypal.payer_id)
    end

    def test_clears_existing_credit_card_payment_methods
      payment.set_credit_card(
        number: '4111111111111111',
        month: 1,
        year: Time.now.year - 1,
        cvv: '123',
        amount: 1.to_m
      )

      update.apply
      assert(payment.paypal?)
      assert_nil(payment.credit_card)
    end

    def test_includes_shipping_when_pricing_order
      assert_equal(1.to_m, order.shipping_total, 'shipping')
      assert_equal(5.to_m, order.subtotal_price, 'subtotal')
      assert_equal(6.to_m, order.total_price, 'order total')
    end
  end
end
