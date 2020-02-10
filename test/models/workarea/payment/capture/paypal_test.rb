require 'test_helper'

module Workarea
  class Payment
    class Capture
      class PaypalTest < Workarea::TestCase
        def payment
          @payment ||= create_payment(
            paypal: { paypal_id: '123', approved: true }
          )
        end

        def test_complete!
          transaction = payment.paypal.build_transaction(action: 'capture')

          Paypal.new(payment.paypal, transaction).complete!

          refute(transaction.success?)
          assert_includes(
            transaction.message,
            I18n.t('workarea.payment.paypal_capture')
          )
        end
      end
    end
  end
end
