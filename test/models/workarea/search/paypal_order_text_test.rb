require 'test_helper'

module Workarea
  module Search
    class PaypalOrderTextTest < TestCase
      def test_payment_text
        order = create_order
        payment = Workarea::Payment.create!(id: order.id, paypal: { approved: true })

        assert_equal('PayPal', Search::OrderText.new(order).payment_text)
      end
    end
  end
end
