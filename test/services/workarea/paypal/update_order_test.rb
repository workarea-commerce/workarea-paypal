require 'test_helper'

module Workarea
  module Paypal
    class UpdateOrderTest < TestCase
      include PaypalSetup

      def test_perform
        order_id = VCR.use_cassette('paypal_create_order') do
          CreateOrder.new(checkout).perform.id
        end

        checkout.payment.build_store_credit(amount: 5.to_m)
        checkout.payment.build_paypal(
          amount: 6.6.to_m,
          paypal_id: order_id,
          approved: true
        )

        response = VCR.use_cassette('paypal_update_order') do
          UpdateOrder.new(checkout).perform
          Workarea::Paypal.gateway.get_order(order_id)
        end

        assert_equal(200, response.status_code)
        assert_equal("6.60", response.result.purchase_units.first.amount.value)
      end

      def test_request_body
        body = UpdateOrder.new(checkout).request_body

        assert_equal(3, body.length)

        part = body.first
        assert_equal('replace', part[:op])
        assert_equal(
          "/purchase_units/@reference_id=='default'/shipping/name",
          part[:path]
        )
        assert_includes(part[:value][:full_name], checkout.shipping.address.first_name)
        assert_includes(part[:value][:full_name], checkout.shipping.address.last_name)

        part = body.second
        assert_equal('replace', part[:op])
        assert_equal(
          "/purchase_units/@reference_id=='default'/shipping/address",
          part[:path]
        )
        assert_equal(checkout.shipping.address.street, part[:value][:address_line_1])
        assert_equal(checkout.shipping.address.street_2, part[:value][:address_line_2])
        assert_equal(checkout.shipping.address.city, part[:value][:admin_area_2])
        assert_equal(checkout.shipping.address.region, part[:value][:admin_area_1])
        assert_equal(checkout.shipping.address.postal_code, part[:value][:postal_code])
        assert_equal(checkout.shipping.address.country.alpha2, part[:value][:country_code])

        part = body.third
        assert_equal('replace', part[:op])
        assert_equal(
          "/purchase_units/@reference_id=='default'/amount",
          part[:path]
        )

        assert_equal('11.60', part[:value][:value])

        breakdown = part[:value][:breakdown]
        assert_equal('10.00', breakdown[:item_total][:value])
        assert_equal('1.00', breakdown[:shipping][:value])
        assert_equal('0.60', breakdown[:tax_total][:value])
        assert_equal('0.00', breakdown[:discount][:value])
      end
    end
  end
end
