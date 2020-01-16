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
          transaction = payment.paypal.build_transaction(action: 'refund')

          Paypal.new(payment.paypal, transaction).complete!

          assert(transaction.success?)
          assert_equal(
            I18n.t('workarea.payment.paypal_capture'),
            transaction.message
          )
        end

        def test_cancel!
          transaction = payment.paypal.build_transaction(action: 'refund')

          Paypal.new(payment.paypal, transaction).cancel!

          assert(transaction.success?)
          assert_equal(
            I18n.t('workarea.payment.paypal_capture'),
            transaction.message
          )
        end
      end
    end
  end
end
