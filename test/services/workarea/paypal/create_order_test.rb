require 'test_helper'

module Workarea
  module Paypal
    class CreateOrderTest < TestCase
      include PaypalSetup

      setup :checkout

      def test_perform
        result = VCR.use_cassette('paypal_create_order') do
          CreateOrder.new(checkout).perform
        end

        assert(result.id.present?)
      end

      def test_request_body
        body = CreateOrder.new(checkout).request_body

        context = body[:application_context]
        assert_equal(Workarea.config.site_name, context[:brand_name])
        assert_equal('SET_PROVIDED_ADDRESS', context[:shipping_preference])

        payer = body[:payer]
        assert(payer[:email_address].present?)
        assert(payer[:name].present?)
        assert(payer[:address].present?)

        purchase_unit = body[:purchase_units].first
        assert_equal(checkout.order.id, purchase_unit[:custom_id])
        assert(purchase_unit[:amount].present?)
        assert(purchase_unit[:items].present?)
        assert(purchase_unit[:shipping].present?)
      end

      def test_payer
        payer = CreateOrder.new(checkout).payer

        assert_equal(checkout.order.email, payer[:email_address])
        assert_equal(checkout.payment.address.first_name, payer[:name][:given_name])
        assert_equal(checkout.payment.address.last_name, payer[:name][:surname])
        assert_equal(checkout.payment.address.street, payer[:address][:address_line_1])
        assert_equal(checkout.payment.address.street_2, payer[:address][:address_line_2])
        assert_equal(checkout.payment.address.city, payer[:address][:admin_area_2])
        assert_equal(checkout.payment.address.region, payer[:address][:admin_area_1])
        assert_equal(checkout.payment.address.postal_code, payer[:address][:postal_code])
        assert_equal(checkout.payment.address.country.alpha2, payer[:address][:country_code])

        checkout.order.email = nil
        payer = CreateOrder.new(checkout).payer
        refute(payer.present?)

        checkout.order.email = 'test@workarea.com'
        checkout.payment.address = nil
        payer = CreateOrder.new(checkout).payer

        assert_equal(checkout.order.email, payer[:email_address])
        assert_nil(payer[:name])
        assert_nil(payer[:address])
      end

      def test_amount
        amount = CreateOrder.new(checkout).amount

        assert_equal('11.60', amount[:value])

        breakdown = amount[:breakdown]
        assert_equal('10.00', breakdown[:item_total][:value])
        assert_equal('1.00', breakdown[:shipping][:value])
        assert_equal('0.60', breakdown[:tax_total][:value])
        assert_equal('0.00', breakdown[:discount][:value])

        checkout.payment.build_store_credit(amount: 5.to_m)
        amount = CreateOrder.new(checkout).amount

        assert_equal('6.60', amount[:value])

        breakdown = amount[:breakdown]
        assert_equal('10.00', breakdown[:item_total][:value])
        assert_equal('1.00', breakdown[:shipping][:value])
        assert_equal('0.60', breakdown[:tax_total][:value])
        assert_equal('5.00', breakdown[:discount][:value])
      end

      def test_items
        item = CreateOrder.new(checkout).items.first
        order_item = checkout.order.items.first

        assert_equal(order_item.sku, item[:sku])
        assert_equal('5.00', item[:unit_amount][:value])
        assert_equal('0.30', item[:tax][:value])
        assert_equal(2, item[:quantity])
        assert_equal('PHYSICAL_GOODS', item[:category])

        order_item.fulfillment = 'download'

        item = CreateOrder.new(checkout).items.first
        assert_equal('DIGITAL_GOODS', item[:category])
      end

      def test_shipping_info
        shipping = CreateOrder.new(checkout).shipping_info

        assert_equal('Ground', shipping[:method])
        assert_equal('Ben Crouse', shipping[:name][:full_name])
        assert_equal(checkout.shipping.address.street, shipping[:address][:address_line_1])
        assert_equal(checkout.shipping.address.street_2, shipping[:address][:address_line_2])
        assert_equal(checkout.shipping.address.city, shipping[:address][:admin_area_2])
        assert_equal(checkout.shipping.address.region, shipping[:address][:admin_area_1])
        assert_equal(checkout.shipping.address.postal_code, shipping[:address][:postal_code])
        assert_equal(checkout.shipping.address.country.alpha2, shipping[:address][:country_code])

        checkout.order.items.first.fulfillment = 'download'
        assert(CreateOrder.new(checkout).shipping_info.blank?)

        checkout.order.items.first.fulfillment = 'shipping'
        checkout.shipping.address = nil
        assert(CreateOrder.new(checkout).shipping_info.blank?)

        create_shipping(order_id: checkout.order.id)
        new_checkout = Checkout.new(checkout.order)
        assert_equal(2, new_checkout.shippings.size)
        assert(CreateOrder.new(new_checkout).shipping_info.blank?)
      end
    end
  end
end
