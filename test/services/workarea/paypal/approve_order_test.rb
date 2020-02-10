require 'test_helper'

module Workarea
  module Paypal
    class ApproveOrderTest < TestCase
      include PaypalSetup

      setup :checkout

      def test_perform
        order_id = VCR.use_cassette('paypal_create_order') do
          CreateOrder.new(checkout).perform.id
        end

        checkout.start_as(:guest)

        VCR.use_cassette('paypal_approve_order') do
          ApproveOrder.new(checkout, order_id).perform
        end

        assert(checkout.complete?)
        assert(checkout.order.email.present?)
        assert(checkout.shipping.shipping_service.valid?)
        assert(checkout.shipping.address.valid?)
        assert(checkout.payment.address.valid?)
        assert(checkout.payment.paypal?)
        assert(checkout.payment.paypal.paypal_id.present?)
        assert(checkout.payment.paypal.payer_id.present?)
        assert(checkout.payment.paypal.details.present?)
        assert(checkout.payment.paypal.approved?)
        assert_equal(checkout.order.total_price, checkout.payment.paypal.amount)
      end
    end
  end
end
